include $(shell sed 's/export //g' .env > .env.make && echo .env.make)
export

devices:
	flutter devices

clean:
	sudo rm -rf ~/.gradle
	sudo rm -rf android/.gradle
	flutter clean && flutter pub get

debug:
	flutter run --debug

release:
	flutter run --release --enable-impeller

build-android:
	flutter build appbundle
	open ./build/app/outputs/bundle/release/

build-ios:
	flutter build ipa
	xcrun altool --upload-app --type ios -f ./build/ios/ipa/*.ipa --apiKey $(APPLE_API_KEY) --apiIssuer $(APPLE_ISSUER_ID)

build: build-android build-ios

.PHONY: screenshot
screenshot: kill-screenshot-server
	@mkdir -p ./screenshots/raw && rm -rf ./screenshots/raw/*
	@mkdir -p ./screenshots/device && rm -rf ./screenshots/device/*
	@mkdir -p ./screenshots/store-large && rm -rf ./screenshots/store-large/*
	@mkdir -p ./screenshots/store-small && rm -rf ./screenshots/store-small/*
	@echo "Starting screenshot-server..."
	@bash -c 'make screenshot-server &'
	@sleep 5 # Give the server time to start
	@echo "Staring application..."
	@flutter drive \
		--driver test/integration/driver.dart \
		test/integration/screenshot/screenshot.dart
	@echo "Stopping screenshot-server..."
	@$(MAKE) kill-screenshot-server


.PHONY: screenshot-server
screenshot-server:
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
kill-screenshot-server:
	@pid=$$(ps | grep '/hack/screenshot_server.py' | grep -v 'grep' | head -n 1 | awk '{print $$1}'); \
		if [ -n "$$pid" ]; then kill $$pid; fi