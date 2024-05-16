#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lib_directory> <output_file_name>"
    exit 1
fi

LIB_DIRECTORY=$1
OUTPUT_FILE_NAME=$2

# Extract just the library name from the directory path
LIBRARY_NAME=$(basename "$LIB_DIRECTORY")

# Define the combinations to track in the desired order
declare -a combinations=("viral_viral" "viral_eve" "nohit_viral" "nohit_eve" "nonviral_viral" "nonviral_eve")

# Initialize an associative array for counts
declare -A counts
for comb in "${combinations[@]}"; do
    counts[$comb]=0
done

awk -F',' '
    BEGIN {
        # Initialize counts for each category
        counts["viral_viral"] = 0;
        counts["viral_eve"] = 0;
        counts["nohit_viral"] = 0;
        counts["nohit_eve"] = 0;
        counts["nonviral_viral"] = 0;
        counts["nonviral_eve"] = 0;
    }
    FNR > 1 { # Skip header
        key = $3 "_" $NF; # Form the key from columns
        gsub(/[ ,]/, "_", key); # Clean up the key
        gsub(/ /, "", key);
        if (key in counts) {
            counts[key]++;
        }
    }
    END {
        # Output the counts in the predefined order, not by array iteration
        printf "\t%d", counts["viral_viral"];
        printf "\t%d", counts["viral_eve"];
        printf "\t%d", counts["nohit_viral"];
        printf "\t%d", counts["nohit_eve"];
        printf "\t%d", counts["nonviral_viral"];
        printf "\t%d", counts["nonviral_eve"];
        print ""; # Finish the line
    }
' $(find "$LIB_DIRECTORY/13_virus_eve_classif" -name '*.csv') > counts.temp

# Prepare the output file header
echo -n "Library" > "$OUTPUT_FILE_NAME"
for comb in "${combinations[@]}"; do
    echo -n -e "\t$comb" >> "$OUTPUT_FILE_NAME"
done
echo "" >> "$OUTPUT_FILE_NAME"

# Append the library name and the counts to the output file
echo -n "$LIBRARY_NAME" >> "$OUTPUT_FILE_NAME"
cat counts.temp >> "$OUTPUT_FILE_NAME"
rm counts.temp

echo "Classifier info written to $OUTPUT_FILE_NAME"
