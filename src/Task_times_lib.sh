#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <lib_directory> <output_file>"
    exit 1
fi

lib_directory=$1
output_file=$2

# Define the tasks and their respective end marks in the logs, ordered correctly
declare -A task_patterns=(
    ["Blastn"]="End of step 'Blastn'"
    ["DIAMOND (Blastx)"]="End of step 'DIAMOND \(Blastx\)'"
    ["Build small RNA profiles"]="End of step 'Build small RNA profiles'"
    ["Handle FASTA sequences"]="End of step 'Handle FASTA sequences'"
    ["Running velvet (fixed hash)"]="End of step 'Running velvet \(fixed hash\)'"
    ["Running velvet optimiser"]="End of step 'Run Velvet optimiser'"
    ["Total time elapsed"]="-- THE END --"
)

# Header for the output file
header_line="Library"
for task in "${!task_patterns[@]}"; do
    header_line+=$'\t'"$task"
done
echo "$header_line" > "$output_file"

# Process each log file in the directory
for log_file in "$lib_directory"/*.log; do
    echo "Processing $log_file"
    library_name=$(basename "$lib_directory")
    output_line="$library_name"

    # Extract times for each task using awk
    for task in "${!task_patterns[@]}"; do
        pattern="${task_patterns[$task]}"
        # Use awk to search for pattern and then the next occurrence of 'Time elapsed:'
        time_elapsed=$(awk -v pat="$pattern" -v start=0 '
        $0 ~ pat { start=1; next }
        start && /Time elapsed:/ { print $3; exit }
        ' "$log_file")

        # If time is not found, mark as N/A
        if [[ -z "$time_elapsed" ]]; then
            time_elapsed="N/A"
        fi

        # Append the extracted time to the output line
        output_line+=$'\t'"$time_elapsed"
    done

    # Write the complete line to the output file
    echo "$output_line" >> "$output_file"
done

echo "Time elapsed for tasks written to $output_file"
