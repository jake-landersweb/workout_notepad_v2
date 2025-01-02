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
	open ./build/app/outputs/bundle/release/ &

build-ios:
	flutter build ipa
	xcrun altool --upload-app --type ios -f ./build/ios/ipa/*.ipa --apiKey $(APPLE_API_KEY) --apiIssuer $(APPLE_ISSUER_ID)

build: build-android build-ios
