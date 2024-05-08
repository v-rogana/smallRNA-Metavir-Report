#!/bin/bash

# This script coordinates the execution of various data processing tasks for a given library directory and outputs a unified report directly to a specified file.

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lib_directory> <final_report.tab>"
    exit 1
fi

# Assign command line arguments to variables
lib_directory=$1
final_output=$2

# Temporary file to hold unified output before final processing
tmp_unified_output="tmp_unified_output.tab"

# Process classifier metadata
echo "Processing classifier metadata..."
classifier_output=$(mktemp)
python3 Classifier_metadata_lib.py "$lib_directory" "$classifier_output"

# Counting mapped reads using samtools
echo "Counting mapped reads using samtools..."
mapped_output=$(mktemp)
bash Mapped_samtools_count_lib.sh "$lib_directory" "$mapped_output"

# Extracting additional metadata from log files
echo "Extracting additional metadata from log files..."
metadata_output=$(mktemp)
python3 Metadata_extraction_from_log_lib.py "$lib_directory" "$metadata_output"

# Calculating subdirectory sizes
echo "Calculating subdirectory sizes..."
size_output=$(mktemp)
python3 Subdirectory_sizes_lib.py "$lib_directory" "$size_output"

# Collecting task times
echo "Collecting task times..."
task_times_output=$(mktemp)
python3 Task_times_lib.py "$lib_directory" "$task_times_output"

# Unifying all outputs into a single temporary file
echo "Unifying all outputs..."
python3 unificando_outputs_lib.py "$tmp_unified_output" "$classifier_output" "$mapped_output" "$metadata_output" "$size_output" "$task_times_output"

# Remove all temporary output files
rm "$classifier_output" "$mapped_output" "$metadata_output" "$size_output" "$task_times_output"

# Reordering and finalizing the report
echo "Reordering and finalizing the report..."
python3 reorder_final_output_lib.py "$tmp_unified_output" "$final_output"
rm "$tmp_unified_output"

echo "Report generation complete. Results stored in $final_output"
