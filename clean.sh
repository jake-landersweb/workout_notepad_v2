#!/bin/bash

# built this script because `flutter clean` does not actually clean everything

sudo rm -rf ~/.gradle

rm -rf android/.gradle

flutter clean && flutter pub get
