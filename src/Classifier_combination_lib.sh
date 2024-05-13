#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lib_directory> <output_file_name>"
    exit 1
fi

LIB_DIRECTORY=$1
OUTPUT_FILE_NAME=$2

# Define the combinations to track in the desired order
declare -a combinations=("viral_viral" "viral_eve" "nohit_viral" "nohit_eve" "nonviral_viral" "nonviral_eve")

# Initialize an associative array for counts
declare -A counts
for comb in "${combinations[@]}"; do
    counts[$comb]=0
done

# Use awk to process all files and count combinations directly
awk -F',' '
    BEGIN {
        # Define the combinations
        combos["viral_viral"] = "viral_viral";
        combos["viral_eve"] = "viral_eve";
        combos["nohit_viral"] = "nohit_viral";
        combos["nohit_eve"] = "nohit_eve";
        combos["nonviral_viral"] = "nonviral_viral";
        combos["nonviral_eve"] = "nonviral_eve";
    }
    FNR > 1 { # Skip header
        key = $3 "_" $NF; # Form the key from columns
        gsub(/[ ,]/, "_", key); # Clean up the key
        gsub(/ /, "", key);
        if (key in combos) {
            counts[key]++;
        }
    }
    END {
        # Output the counts in the predefined order
        for (combo in combos) {
            printf "%s\t", counts[combo]+0; # +0 to ensure uninitialized counts are treated as 0
        }
        printf "\n";
    }
' $(find "$LIB_DIRECTORY/13_virus_eve_classif" -name '*.csv') > counts.temp

# Prepare the output file header
echo -n "Library" > "$OUTPUT_FILE_NAME"
for comb in "${combinations[@]}"; do
    echo -n -e "\t$comb" >> "$OUTPUT_FILE_NAME"
done
echo "" >> "$OUTPUT_FILE_NAME"

# Append the counts to the output file
echo -n "$LIB_DIRECTORY" >> "$OUTPUT_FILE_NAME"
cat counts.temp >> "$OUTPUT_FILE_NAME"
rm counts.temp

echo "Classifier info written to $OUTPUT_FILE_NAME"
