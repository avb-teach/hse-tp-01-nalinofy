#!/bin/bash
usage() {
    echo "Использование: $0 [опции] <входная_директория> <выходная_директория>"
    echo "Опции:"
    echo "  -max_depth N   Ограничить глубину сканирования до N уровней"
    exit 1
}
max_depth=-1  
while getopts ":m:" opt; do
    case $opt in
        m)
            max_depth=$OPTARG
            ;;
        \?)
            echo "Неверная опция: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Опция -$OPTARG требует аргумента." >&2
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    usage
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория '$input_dir' не существует" >&2
    exit 1
fi

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

echo "Файлы успешно скопированы в $output_dir"
