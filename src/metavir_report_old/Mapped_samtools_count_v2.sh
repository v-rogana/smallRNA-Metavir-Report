#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <batch_directory> <output_file>"
    exit 1
fi

# Extract the arguments
batch_dir=$1
output_file=$2

# Add header to the output file
echo -e "Run_and_Batch\treads_mapped_viral\treads_mapped_non_viral\treads_mapped_no_hit" > "$output_file"

# Process each library directory within the given batch directory
for library_dir in "$batch_dir"/*/; do
    if [ -d "$library_dir" ]; then
        report_blast_dir="${library_dir}07_reportBlast/"
        run_and_batch=$(basename "$batch_dir")/$(basename "$library_dir")

        # Initialize counts to avoid errors in missing files
        reads_mapped_viral=0
        reads_mapped_non_viral=0
        reads_mapped_no_hit=0

        # Define file paths for SAM files
        viral_sam="${report_blast_dir}all_viral_hits.mapped.sort.sam"
        non_viral_sam="${report_blast_dir}all_non_viral_hits.mapped.sort.sam"
        no_hit_sam="${report_blast_dir}diamond_blastx_NoHits.mapped.sort.sam"

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
        echo -e "$run_and_batch\t$reads_mapped_viral\t$reads_mapped_non_viral\t$reads_mapped_no_hit" >> "$output_file"
    fi
done

echo "Data extraction complete. Output stored in $output_file"

