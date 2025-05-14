-include .env
export


.DEFAULT_GOAL := help


.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo
	@echo "Available targets:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; \
		       {printf "  %-10s %s\n", $$1, $$2}'


.PHONY: devices
devices: ## Check current devices connected to flutter
	flutter devices


.PHONY: clean
clean: ## Clean the flutter project repo, along with android gradle cache
	sudo rm -rf ~/.gradle
	sudo rm -rf android/.gradle
	flutter clean && flutter pub get


.PHONY: open-android
open-android: ## Open the android build folder
	open ./build/app/outputs/bundle/release/


.PHONY: build-android
build-android: ## Build the app for android and open the android build folder
	flutter build appbundle \
		--dart-define=HOST=$(HOST) \
		--dart-define=GO_HOST=$(GO_HOST) \
		--dart-define=GO_API_KEY=$(GO_API_KEY) \
		--dart-define=API_KEY=$(API_KEY) \
		--dart-define=AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) \
		--dart-define=AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		--dart-define=AWS_S3_BUCKET=$(AWS_S3_BUCKET) \
		--dart-define=OTEL_BACKEND_HOST=$(OTEL_BACKEND_HOST) \
		--dart-define=OTEL_BACKEND_API_KEY=$(OTEL_BACKEND_API_KEY) \
		--dart-define=RC_APPL_API_KEY=$(RC_APPL_API_KEY) \
		--dart-define=RC_GOOG_API_KEY=$(RC_GOOG_API_KEY) \
		--dart-define=RC_ENTITLEMENT_ID=$(RC_ENTITLEMENT_ID)
	$(MAKE) open-android


.PHONY: build-ios
build-ios: ## Build the app for ios and push to the app store
	flutter build ipa \
		--dart-define=HOST=$(HOST) \
		--dart-define=GO_HOST=$(GO_HOST) \
		--dart-define=GO_API_KEY=$(GO_API_KEY) \
		--dart-define=API_KEY=$(API_KEY) \
		--dart-define=AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) \
		--dart-define=AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		--dart-define=AWS_S3_BUCKET=$(AWS_S3_BUCKET) \
		--dart-define=OTEL_BACKEND_HOST=$(OTEL_BACKEND_HOST) \
		--dart-define=OTEL_BACKEND_API_KEY=$(OTEL_BACKEND_API_KEY) \
		--dart-define=RC_APPL_API_KEY=$(RC_APPL_API_KEY) \
		--dart-define=RC_GOOG_API_KEY=$(RC_GOOG_API_KEY) \
		--dart-define=RC_ENTITLEMENT_ID=$(RC_ENTITLEMENT_ID)
	$(MAKE) upload-ios


.PHONY: upload-ios
upload-ios: ## Upload a compiled binary to the ios store
	xcrun altool --upload-app --type ios -f ./build/ios/ipa/*.ipa --apiKey $(APPLE_API_KEY) --apiIssuer $(APPLE_ISSUER_ID)



.PHONY: build-android build-ios
build: build-android build-ios ## Build the application for both stores


.PHONY: screenshot
screenshot: kill-screenshot-server ## Run the screenshot integration tests to take screenshots
	@mkdir -p ./screenshots/raw && rm -rf ./screenshots/raw/*
	@mkdir -p ./screenshots/device && rm -rf ./screenshots/device/*
	@mkdir -p ./screenshots/store-large && rm -rf ./screenshots/store-large/*
	@mkdir -p ./screenshots/store-small && rm -rf ./screenshots/store-small/*
	@echo "Starting screenshot-server..."
	@bash -c 'make screenshot-server &'
	@sleep 5 # Give the server time to start
	@echo "Staring application..."
	@flutter drive \
		--driver test/screenshot/driver.dart \
		test/screenshot/screenshot.dart
	@echo "Stopping screenshot-server..."
	@$(MAKE) kill-screenshot-server
	@./screenshots/convert-to-webp.sh


.PHONY: test
test: ## run unit tests
	flutter test ./test/unit


.PHONY: screenshot-server
screenshot-server: ## Create the screenshot server. This is for running the `screenshot` command
	@if [ ! -d "./venv" ]; then \
		echo "Python venv not found, creating ..."; \
		python3 -m venv ./venv; \
	fi

	@./venv/bin/python -m pip install --upgrade pip setuptools >/dev/null
	@if ! ./venv/bin/python -c "import flask" 2>/dev/null; then \
		echo "Flask not found, installing..."; \
		./venv/bin/pip install flask; \
	fi

	@./venv/bin/python ./hack/screenshot_server.py


.PHONY: kill-screenshot-server
kill-screenshot-server: ## Manually kill the screenshot server
	@pid=$$(ps | grep '/hack/screenshot_server.py' | grep -v 'grep' | head -n 1 | awk '{print $$1}'); \
		if [ -n "$$pid" ]; then kill $$pid; fi