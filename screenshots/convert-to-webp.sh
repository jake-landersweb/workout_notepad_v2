#!/bin/bash

ROOT="${ROOT:-$(git rev-parse --show-toplevel)}"

for folder in $ROOT/screenshots/*; do
    folder_name=$(basename $folder)

    if [ "$folder_name" != "webp" ] && [ -d "$folder" ]; then
        echo "Processing: $folder_name"
        mkdir -p "$ROOT/screenshots/webp/$folder_name"
        cd $folder
        for file in *.png; do
            cwebp "$file" -o "$ROOT/screenshots/webp/$folder_name/${file%.png}.webp"
        done
        cd ..
    fi

done