#!/bin/bash

max_depth=-1 

shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    usage
fi

input_dir="$1"
output_dir="$2"


mkdir -p "$output_dir"


get_unique_filename() {
    local base_dir="$1"
    local original_name="$2"
    local counter=1
    
    if [ ! -e "$base_dir/$original_name" ]; then
        echo "$original_name"
        return
    fi

    local name="${original_name%.*}"
    local extension="${original_name##*.}"

    if [[ "$original_name" == "$extension" || "$name" == "" ]]; then
        name="$original_name"
        extension=""
    else
        extension=".$extension"
    fi

    while [[ -e "$base_dir/${name}_${counter}${extension}" ]]; do
        ((counter++))
    done
    
    echo "${name}_${counter}${extension}"
}


copy_files() {
    local src="$1"
    local dest="$2"
    local current_depth="$3"

    if [ $max_depth -ge 0 ] && [ $current_depth -gt $max_depth ]; then
        return
    fi

    for item in "$src"/*; do
        if [ -f "$item" ]; then

            local filename=$(basename "$item")

            local unique_name=$(get_unique_filename "$dest" "$filename")
            
            cp "$item" "$dest/$unique_name"
        elif [ -d "$item" ]; then

            copy_files "$item" "$dest" $((current_depth + 1))
        fi
    done
}


copy_files "$input_dir" "$output_dir" 0

