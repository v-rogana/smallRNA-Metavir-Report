#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <lib_directory> <output_file>"
    exit 1
fi

# Extract the arguments
lib_dir=$1
output_file=$2

# Add header to the output file
echo -e "Library\treads_mapped_viral\treads_mapped_non_viral\treads_mapped_no_hit" > "$output_file"

# Process the specific library directory
if [ -d "$lib_dir" ]; then
    report_blast_dir="${lib_dir}07_reportBlast/"
    library_name=$(basename "$lib_dir")

    # Initialize counts to avoid errors in missing files
    reads_mapped_viral=0
    reads_mapped_non_viral=0
    reads_mapped_no_hit=0

    # Define file paths for SAM files
    viral_sam="${report_blast_dir}all_viral_hits.mapped.sort.sam"
    non_viral_sam="${report_blast_dir}all_non_viral_hits.mapped.sort.sam"
    no_hit_sam="${report_blast_dir}contigs_nohits_FINAL_diamond.mapped.sort.sam"

    # Check if SAM files exist and count mapped reads
    if [[ -f "$viral_sam" ]]; then
        reads_mapped_viral=$(samtools view -c -F 4 "$viral_sam")
    fi
    if [[ -f "$non_viral_sam" ]]; then
        reads_mapped_non_viral=$(samtools view -c -F 4 "$non_viral_sam")
    fi
    if [[ -f "$no_hit_sam" ]]; then
        reads_mapped_no_hit=$(samtools view -c -F 4 "$no_hit_sam")
    fi

    # Append data to output file
    echo -e "$library_name\t$reads_mapped_viral\t$reads_mapped_non_viral\t$reads_mapped_no_hit" >> "$output_file"
fi

echo "Data extraction complete. Output stored in $output_file"