#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <lib_directory> <output_file>"
    exit 1
fi

lib_directory=$1
output_file=$2

# Check if the directory exists
if [[ ! -d "$lib_directory" ]]; then
    echo "The specified directory does not exist."
    exit 2
fi

# Get the basename of the library directory
library_name=$(basename "$lib_directory")

# Initialize the header with the library name
header="Library\tTotal_Size(MB)"

# Initialize an array to hold subdirectory names for sorting
declare -a subdirs

# Process each subdirectory to populate names for sorting
for subdir in "$lib_directory"/*/; do
    if [[ -d "$subdir" ]]; then
        subdirs+=("$(basename "$subdir")")
    fi
done

# Sort subdirectory names and append to header
IFS=$'\n' subdirs=($(sort <<<"${subdirs[*]}"))
unset IFS
for subdir_name in "${subdirs[@]}"; do
    header+="\t$subdir_name"
done

# Write the header to the output file
echo -e "$header" > "$output_file"

# Calculate the total size of the library directory in megabytes with two decimal places
total_size=$(du -sk "$lib_directory" | awk '{printf "%.2f", $1 / 1024}')

# Start the output line with the library name and total size
output_line="$library_name\t$total_size"

# Append each subdirectory size to the output line
for subdir_name in "${subdirs[@]}"; do
    subdir_path="$lib_directory/$subdir_name"
    if [[ -d "$subdir_path" ]]; then
        subdir_size=$(du -sk "$subdir_path" | awk '{printf "%.2f", $1 / 1024}')
    else
        subdir_size="N/A"
    fi
    output_line+="\t$subdir_size"
done

# Write the complete line to the output file
echo -e "$output_line" >> "$output_file"

echo "Subdirectory sizes in MB written to $output_file"
