#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASE_DIR="$SCRIPT_DIR/.."
LIB_DIR="$BASE_DIR/lib"

source $LIB_DIR/parallel.sh

cleanup_djvu_if_converted () {
    # Get the base name (without extension) and the directory of the file
    local base_name=$(basename "$1" .djvu)
    local dir_name=$(dirname "$1")

    # Define the output PDF file path
    local pdf_file="$dir_name/$base_name.pdf"

    if [ -f "$pdf_file" ]; then
        echo "File $pdf_file exists! Removing $1"

        rm -f "$1"
    fi
}

export -f cleanup_djvu_if_converted

find . -type f -name "*.djvu" | run_parallel cleanup_djvu_if_converted