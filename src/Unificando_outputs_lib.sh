#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <output_file> <tab_file1> <tab_file2> ..."
    exit 1
fi

output_file=$1
shift # Shift the first argument and use the rest as tab files

# Create a temporary file for merging
temp_file=$(mktemp)
touch "$output_file"

# Collect all headers and initialize an associative array for each library
declare -A library_data
headers=("Library")

# Collect headers and data
for file in "$@"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found."
        continue
    fi

    # Read headers
    current_headers=$(head -n 1 "$file")
    IFS=$'\t' read -r -a current_header_array <<< "$current_headers"
    for header in "${current_header_array[@]}"; do
        if [[ ! " ${headers[@]} " =~ " ${header} " ]]; then
            headers+=("$header")
        fi
    done

    # Read data
    while IFS=$'\t' read -r -a line_data; do
        library=${line_data[0]}
        library_data[$library]=$library # Initialize library key in associative array
        for (( i=0; i<${#current_header_array[@]}; i++ )); do
            header="${current_header_array[i]}"
            library_data["$library;$header"]="${line_data[i]}"
        done
    done < <(tail -n +2 "$file") # Skip the header line
done

# Write to output file
# Print the header
{
    printf "%s" "${headers[0]}"
    for (( i=1; i<${#headers[@]}; i++ )); do
        printf ",%s" "${headers[i]}"  # Changed tab to comma for CSV format
    done
    printf "\n"
} > "$output_file"

# Print the data
for key in "${!library_data[@]}"; do
    if [[ "$key" =~ ";" ]]; then
        continue
    fi
    library="$key"
    # Start with the library value, ensuring no leading whitespace
    {
        printf "%s" "$library"
        for header in "${headers[@]:1}"; do  # Skip the first header since it's already printed as the library
            value="${library_data["$library;$header"]}"
            printf ",%s" "${value:-N/A}"  # Changed tab to comma, ensuring no leading spaces
        done
        printf "\n"
    } >> "$output_file"
done

echo "Concatenation complete. Result stored in '$output_file'"
