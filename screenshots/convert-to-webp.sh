#!/bin/bash


for folder in ./*/; do
    echo "Processing: $folder"
    mkdir -p "webp/$folder"
    cd $folder
    for file in *.png; do
        cwebp "$file" -o "../webp/$folder${file%.png}.webp"
    done
    cd ..
done