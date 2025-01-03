#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASE_DIR="$SCRIPT_DIR/.."
LIB_DIR="$BASE_DIR/lib"

source $LIB_DIR/parallel.sh

shopt -s expand_aliases

alias djvu2pdf='docker run --rm -u $(id -u):$(id -g) -v $(pwd):/opt/work nasab187/djvu2pdf'

# Check if djvu2pdf is installed
if ! command -v djvu2pdf &> /dev/null; then
    echo "Error: djvu2pdf command not found. Please install it first."
    exit 1
fi

convert_file() {
    # Get the base name (without extension) and the directory of the file
    local base_name=$(basename "$1" .djvu)
    local dir_name=$(dirname "$1")

    # Define the output PDF file path
    local pdf_file="$dir_name/$base_name.pdf"

    # Convert the .djvu file to .pdf
    echo "Converting: $1 -> $pdf_file"
    djvu2pdf "$1" "$pdf_file"

    # Check if the conversion was successful
    if [[ $? -eq 0 ]]; then
        echo "Successfully converted: $pdf_file"
    else
        echo "Error converting: $1"
    fi
}

export -f convert_file

find . -type f -name "*.djvu" | run_parallel convert_file