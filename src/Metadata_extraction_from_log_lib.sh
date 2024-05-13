#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <lib_directory> <output_file>"
    exit 1
fi

lib_dir=$1
output_file=$2

# Add header to the output file
echo -e "Library\tContigs_gt200\tNumber_viral_contigs\tNumber_nonviral_contigs\tNumber_no_hit_contigs\tTotal_reads\tReads_mapped_host\tReads_unmapped_host\tReads_mapped_bacter\tPreprocessed_reads\tTotal_assembled_contigs\tContigs_diamond_viral\tContigs_diamond_non_viral\tContigs_diamond_no_hits\tContigs_blastN_viral\tContigs_blastN_non_viral\tContigs_blastN_no_hits" > "$output_file"

# Function to extract numbers based on patterns
extract_numbers() {
    local log_file=$1
    local lib_name=$(basename "$lib_dir")

    # Define regex patterns for each field
    local contigs_gt200=$(grep -Po '# Contigs gt200\s+\K\d+' "$log_file")
    local viral_contigs=$(grep -Po '# Number of contigs \(all\) \[viral\]\s+\K\d+' "$log_file")
    local non_viral_contigs=$(grep -Po '# Number of contigs \(all\) \[non viral\]\s+\K\d+' "$log_file")
    local no_hits_contigs=$(grep -Po '# Number of contigs \(all\) \[no hits\]\s+\K\d+' "$log_file")
    local total_reads=$(grep -Po '# Total reads\s+\K\d+' "$log_file")
    local reads_mapped_host=$(grep -Po '# Reads mapped host\s+\K\d+' "$log_file")
    local reads_unmapped_host=$(grep -Po '# Reads unmapped host\s+\K\d+' "$log_file")
    local reads_mapped_bacter=$(grep -Po '# Reads mapped bacter\s+\K\d+' "$log_file")
    local preprocessed_reads=$(grep -Po '# Preprocessed reads\s+\K\d+' "$log_file")
    local total_assembled_contigs=$(grep -Po '# Total assembled contigs\s+\K\d+' "$log_file")
    local diamond_viral=$(grep -Po '# Number of contigs \(diamond\) \[viral\]\s+\K\d+' "$log_file")
    local diamond_non_viral=$(grep -Po '# Number of contigs \(diamond\) \[non viral\]\s+\K\d+' "$log_file")
    local diamond_no_hits=$(grep -Po '# Number of contigs \(diamond\) \[no hits\]\s+\K\d+' "$log_file")
    local blastN_viral=$(grep -Po '# Number of contigs \(blastN\) \[viral\]\s+\K\d+' "$log_file")
    local blastN_non_viral=$(grep -Po '# Number of contigs \(blastN\) \[non viral\]\s+\K\d+' "$log_file")
    local blastN_no_hits=$(grep -Po '# Number of contigs \(blastN\) \[no hits\]\s+\K\d+' "$log_file")

    # Echo the results for appending to the output file
    echo -e "$lib_name\t${contigs_gt200:-0}\t${viral_contigs:-0}\t${non_viral_contigs:-0}\t${no_hits_contigs:-0}\t${total_reads:-0}\t${reads_mapped_host:-0}\t${reads_unmapped_host:-0}\t${reads_mapped_bacter:-0}\t${preprocessed_reads:-0}\t${total_assembled_contigs:-0}\t${diamond_viral:-0}\t${diamond_non_viral:-0}\t${diamond_no_hits:-0}\t${blastN_viral:-0}\t${blastN_non_viral:-0}\t${blastN_no_hits:-0}"
}

# Process log files in the specified library directory
for log_file in "$lib_dir"/*.log; do
    if [[ -f "$log_file" ]]; then
        extract_numbers "$log_file" >> "$output_file"
    fi
done

echo "Metadata extraction complete. Data saved to $output_file"
