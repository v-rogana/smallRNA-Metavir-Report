#!/bin/bash

# Check the number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <output_file> <tab_file1> <tab_file2> ..."
    exit 1
fi

output_file=$1
shift  # Shift the first argument and use the rest as tab files

# Temporary file to store intermediate results
temp_file=$(mktemp)

# Process each tab-separated file
for tab_file in "$@"; do
    if [ ! -f "$tab_file" ]; then
        echo "File $tab_file does not exist."
        continue
    fi
    if [ ! -s "$temp_file" ]; then
        # If temp_file is empty, initialize it with the header and data from the first file
        awk -F'\t' 'NR == 1 {print "Library\t" $0} NR > 1 {print $0}' "$tab_file" > "$temp_file"
    else
        # Merge current file with temporary file based on 'Library'
        # Using join command to merge files by 'Library' column assumed to be the first column after the header modification
        join -t $'\t' -a 1 -a 2 -e 'N/A' -o auto -1 1 -2 1 "$temp_file" <(awk -F'\t' 'NR == 1 {print "Library\t" $0} NR > 1 {print $0}' "$tab_file" | sort -k1,1) | sort -k1,1 > "${temp_file}.new"
        mv "${temp_file}.new" "$temp_file"
    fi
done

# Add headers from all files, sort them while keeping 'Library' as the first column
awk -F'\t' 'NR == 1 {for (i=1; i<=NF; i++) header[$i] = $i} END {printf "Library\t"; for (h in header) if (h != "Library") printf h "\t"; print ""}' "$temp_file" > "$output_file"

# Add the rest of the data
awk 'NR > 1' "$temp_file" >> "$output_file"

# Clean up the temporary file
rm "$temp_file"

echo "Merged data written to $output_file"
