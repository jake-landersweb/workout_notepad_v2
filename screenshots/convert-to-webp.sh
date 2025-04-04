#!/bin/bash

for folder in ./*/; do
    echo "Processing: $folder"
    cd $folder
    mkdir webp
    for file in *.png; do
        cwebp "$file" -o "./webp/${file%.png}.webp"
    done
    cd ..
done