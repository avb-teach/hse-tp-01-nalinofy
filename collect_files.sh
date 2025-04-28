#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist"
    exit 1
fi

mkdir -p "$output_dir"

copy_files() {
    local src="$1"
    local dest="$2"
    
    find "$src" -type f | while read -r file; do
        filename=$(basename "$file")
        name="${filename%.*}"
        extension="${filename##*.}"
 
        if [ -e "$dest/$filename" ]; then
            counter=1
            while [ -e "$dest/$name$counter.$extension" ]; do
                ((counter++))
            done
            new_filename="$name$counter.$extension"
            cp "$file" "$dest/$new_filename"
        else
            cp "$file" "$dest/$filename"
        fi
    done
}

copy_files "$input_dir" "$output_dir"

