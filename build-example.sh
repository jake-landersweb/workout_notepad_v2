#!/bin/sh

AWS_ACCESS_KEY=""
AWS_SECRET_ACCESS_KEY=""

echo Building for iOS...

flutter build ios --enable-impeller \
    --define=AWS_ACCESS_KEY=$AWS_ACCESS_KEY \
    --define=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

echo Building for Android...

flutter build appbundle \
    --define=AWS_ACCESS_KEY=$AWS_ACCESS_KEY \
    --define=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY