#!/bin/sh

set -xe

# source apple envs
source .env

# build android app
flutter build appbundle

# open the android build folder
open ./build/app/outputs/bundle/release/ &

# build the ios app
flutter build ipa

# upload the binary to the app store
xcrun altool --upload-app --type ios -f ./build/ios/ipa/*.ipa --apiKey $APPLE_API_KEY --apiIssuer $APPLE_ISSUER_ID