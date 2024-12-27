#!/bin/bash

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

cpu_cores=$(sysctl -n hw.logicalcpu)

# Check if GNU Parallel is available
if command -v parallel > /dev/null; then
    echo "GNU Parallel is available. Running in parallel..."
    find . -type f -name "*.djvu" | parallel --ungroup -j $cpu_cores convert_file {}
elif command -v xargs > /dev/null; then
    echo "GNU Parallel not found. Falling back to xargs..."
    find . -type f -name "*.djvu"  | xargs -P $cpu_cores -I {} bash -c 'convert_file "$0"' {}
else
    cat << EOF
Neither 'GNU Parallel' nor 'xargs' were found.
Running it unparallel might take too long. If you continue, conversion would start without parallel support.
EOF

    read -p "Are you sure? (Y/N)" -n 1 -r

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Find all .djvu files and convert them
        find . -type f -name "*.djvu" | while read -r djvu_file; do
            convert_file "$djvu_file"
        done
    else
        exit 0
    fi
fi
