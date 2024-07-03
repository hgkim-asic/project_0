#! /bin/bash

FILE_EXTENSIONS=("md")

set -e

for ext in "${FILE_EXTENSIONS[@]}"
do
    for file in $(find . -type f -name "*.${ext}")
    do
        vim -u NONE -S convert_tabs.vim "$file"
    done
done

echo '"convert_tabs.sh" finished successfully.'
