#!/bin/bash

# Check if the required number of arguments is passed
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <batch_base_dir> <script_dir> <final_output_name>"
    exit 1
fi

# Assign arguments to variables
batch_base_dir="$1"
script_dir="$2"
final_output_name="$3"

# Define the output file for the concatenated tabs
concatenated_output="${script_dir}/metavir_data_batch_r2d2.tab"

# Initialize an empty temporary file to store list of all tab files
tab_list="${script_dir}/all_tabs_list.txt"
: > "$tab_list"  # Clear or create empty file

# Loop through each batch directory in the batch base directory
for batch_dir in ${batch_base_dir}batch_*; do
    if [ -d "$batch_dir" ]; then
        batch_name=$(basename "$batch_dir")
        echo "Processing $batch_name..."

        # Process mapped samtools count
        mapped_output="${script_dir}/mapped_samtools_${batch_name}.tab"
        "${script_dir}/Mapped_samtools_count_v2.sh" "$batch_dir" "$mapped_output"
        echo "$mapped_output" >> "$tab_list"

        # Task times
        task_output="${script_dir}/task_times_${batch_name}.tab"
        python3 "${script_dir}/Task_times_v5.py" "$batch_dir" "$task_output"
        echo "$task_output" >> "$tab_list"

        # Subdirectory sizes
        size_output="${script_dir}/size_subdir_${batch_name}.tab"
        python3 "${script_dir}/Subdirectory_sizes_v5.py" "$batch_dir" "$size_output"
        echo "$size_output" >> "$tab_list"

        # Metadata extraction from log
        log_output="${script_dir}/log_${batch_name}.tab"
        python3 "${script_dir}/Metadata_extraction_from_log_v3.py" "$batch_dir" "$log_output"
        echo "$log_output" >> "$tab_list"

        # Classifier metadata
        classifier_output="${script_dir}/classifier_${batch_name}.tab"
        python3 "${script_dir}/Classifier_metadata_v3.py" "$batch_dir" "$classifier_output"
        echo "$classifier_output" >> "$tab_list"
    fi
done

# Concatenate all generated tab files
tab_files=$(cat "$tab_list")
python3 "${script_dir}/unificando_outputs_v3.py" "$concatenated_output" $tab_files

# Reorder final output
final_reorder_output="${script_dir}/${final_output_name}"
python3 "${script_dir}/reorder_final_output_v2.py" "$concatenated_output" "$final_reorder_output"

# Cleanup temporary and intermediate files
rm "$tab_list"
rm $tab_files
rm "$concatenated_output"

echo "All processing completed. Final reordered output is stored in $final_reorder_output"

