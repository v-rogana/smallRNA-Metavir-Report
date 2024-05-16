#!/bin/bash

# Check if the correct number of arguments was provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lib_directory> <output_file>"
    exit 1
fi

lib_directory=$1
output_file=$2

# Placeholder for Classifier_combination_lib.sh content
# Extract just the library name from the directory path
LIBRARY_NAME=$(basename "$lib_directory")

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
' $(find "$lib_directory/13_virus_eve_classif" -name '*.csv') > counts.temp

# Prepare the output file header
echo -n "Library" > classifier_output.tab
for comb in "${combinations[@]}"; do
    echo -n -e "\t$comb" >> classifier_output.tab
done
echo "" >> classifier_output.tab

# Append the library name and the counts to the output file
echo -n "$LIBRARY_NAME" >> classifier_output.tab
cat counts.temp >> classifier_output.tab

echo "Classifier info written to classifier_output.tab"

# Content of Metadata_extraction_from_log_lib.sh
# Add header to the output file
echo -e "Library\tContigs_gt200\tNumber_viral_contigs\tNumber_nonviral_contigs\tNumber_no_hit_contigs\tTotal_reads\tReads_mapped_host\tReads_unmapped_host\tReads_mapped_bacter\tPreprocessed_reads\tTotal_assembled_contigs\tContigs_diamond_viral\tContigs_diamond_non_viral\tContigs_diamond_no_hits\tContigs_blastN_viral\tContigs_blastN_non_viral\tContigs_blastN_no_hits" > metadata_output.tab

# Function to extract numbers based on patterns
extract_numbers() {
    local log_file=$1
    local lib_name=$(basename "$lib_directory")  # Corrected to use $lib_directory

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
    echo -e "$lib_name\t${contigs_gt200:-0}\t${viral_contigs:-0}\t${non_viral_contigs:-0}\t${no_hits_contigs:-0}\t${total_reads:-0}\t${reads_mapped_host:-0}\t${reads_unmapped_host:-0}\t${reads_mapped_bacter:-0}\t${preprocessed_reads:-0}\t${total_assembled_contigs:-0}\t${diamond_viral:-0}\t${diamond_non_viral:-0}\t${diamond_no_hits:-0}\t${blastN_viral:-0}\t${blastN_non_viral:-0}\t${blastN_no_hits:-0}" >> metadata_output.tab
}

# Process log files in the specified library directory
for log_file in "$lib_directory"/*.log; do
    if [[ -f "$log_file" ]]; then
        echo "Processing file: $log_file"
        extract_numbers "$log_file"
    else
        echo "No log files found in $lib_directory"
    fi
done

echo "Metadata extraction complete. Data saved to metadata_output.tab"

# Add header to the output file
echo -e "Library\treads_mapped_viral\treads_mapped_non_viral\treads_mapped_no_hit" > mapped_output.tab

# Process the specific library directory
if [ -d "$lib_directory" ]; then
    report_blast_dir="${lib_directory}07_reportBlast/"
    library_name=$(basename "$lib_directory")

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
    echo -e "$library_name\t$reads_mapped_viral\t$reads_mapped_non_viral\t$reads_mapped_no_hit" >> mapped_output.tab
fi

echo "Data extraction complete."

# Get the basename of the library directory
library_name=$(basename "$lib_directory")

# Initialize the header with the library name
header="Library\tTotal_Size(MB)"

# Initialize an array to hold subdirectory names for sorting
declare -a subdirs

# Process each subdirectory to populate names for sorting
for subdir in "$lib_directory"/*/; do
    if [[ -d "$subdir" ]]; then
        subdirs+=("$(basename "$subdir")")
    fi
done

# Sort subdirectory names and append to header
IFS=$'\n' subdirs=($(sort <<<"${subdirs[*]}"))
unset IFS
for subdir_name in "${subdirs[@]}"; do
    header+="\t$subdir_name"
done

# Write the header to the output file
echo -e "$header" > disk_usage_output.tab

# Calculate the total size of the library directory in megabytes with two decimal places
total_size=$(du -sk "$lib_directory" | awk '{printf "%.2f", $1 / 1024}')

# Start the output line with the library name and total size
output_line="$library_name\t$total_size"

# Append each subdirectory size to the output line
for subdir_name in "${subdirs[@]}"; do
    subdir_path="$lib_directory/$subdir_name"
    if [[ -d "$subdir_path" ]]; then
        subdir_size=$(du -sk "$subdir_path" | awk '{printf "%.2f", $1 / 1024}')
    else
        subdir_size="N/A"
    fi
    output_line+="\t$subdir_size"
done

# Write the complete line to the output file
echo -e "$output_line" >> disk_usage_output.tab

echo "Subdirectory sizes in MB written"

# Get the basename of the library directory
library_name=$(basename "$lib_directory")

# Find the first log file that matches the pattern *.log
log_file=$(find "$lib_directory" -maxdepth 1 -type f -name "*.log" | head -n 1)

if [[ -z "$log_file" ]]; then
    echo "No log file found in the directory."
    exit 3
fi

# Print the header into the output file
echo -e "Library\tBlastn\tDIAMOND (Blastx)\tBuild small RNA profiles\tHandle FASTA sequences\tRunning velvet (fixed hash)\tRunning velvet optimiser\tTotal time elapsed" > task_times_output.tab

# Execute awk to extract and format the output as a table, and APPEND to the specified output file
awk -v libName="$library_name" -v outFile=task_times_output.tab '
BEGIN {
    # Define array to store times with initial value of "N/A"
    times["Blastn"] = "N/A";
    times["DIAMOND (Blastx)"] = "N/A";
    times["Build small RNA profiles"] = "N/A";
    times["Handle FASTA sequences"] = "N/A";
    times["Running velvet (fixed hash)"] = "N/A";
    times["Run Velvet optmiser (automatically defined hash)"] = "N/A";
    times["Total time elapsed"] = "N/A";
}

/End of step/ {
    step = $0
    if (step ~ /Blastn/) times["Blastn"] = getline_time();
    else if (step ~ /DIAMOND \(Blastx\)/) times["DIAMOND (Blastx)"] = getline_time();
    else if (step ~ /Build small RNA profiles/) times["Build small RNA profiles"] = getline_time();
    else if (step ~ /Handle FASTA sequences/) times["Handle FASTA sequences"] = getline_time();
    else if (step ~ /Running velvet \(fixed hash\)/) times["Running velvet (fixed hash)"] = getline_time();
    else if (step ~ /Run Velvet optmiser \(automatically defined hash\)/) times["Run Velvet optmiser (automatically defined hash)"] = getline_time();
}

/^-- THE END --/ {
    getline; # Move to the "Time elapsed" line
    times["Total time elapsed"] = $3;
}

function getline_time() {
    getline; getline; getline;  # Skip to the "Time elapsed" line
    return $3;
}

END {
    # Append all stored times in order
    print libName "\t" times["Blastn"] "\t" times["DIAMOND (Blastx)"] "\t" times["Build small RNA profiles"] "\t" times["Handle FASTA sequences"] "\t" times["Running velvet (fixed hash)"] "\t" times["Run Velvet optmiser (automatically defined hash)"] "\t" times["Total time elapsed"] >> outFile;
}
' "$log_file"

# Define the comprehensive header once and write it to the output file.
echo -e "Library\tviral_viral\tviral_eve\tnohit_viral\tnohit_eve\tnonviral_viral\tnonviral_eve\tContigs_gt200\tNumber_viral_contigs\tNumber_nonviral_contigs\tNumber_no_hit_contigs\tTotal_reads\tReads_mapped_host\tReads_unmapped_host\tReads_mapped_bacter\tPreprocessed_reads\tTotal_assembled_contigs\tContigs_diamond_viral\tContigs_diamond_non_viral\tContigs_diamond_no_hits\tContigs_blastN_viral\tContigs_blastN_non_viral\tContigs_blastN_no_hits\treads_mapped_viral\treads_mapped_non_viral\treads_mapped_no_hit\tTotal_Size(MB)\t02_filter_size_gaps_convertion\t04_getUnmapped\t05_1_assembleUnmapped_opt\t05_2_assembleUnmapped_fix\t05_3_assembleUnmapped_opt_fix\t05_4_assembleUnmapped_opt_20to23\t05_5_assembleUnmapped_opt_24to30\t05_6_cap3\t06_blast\t07_reportBlast\t11_profiles\t12_z_score_small_rna_features\t13_virus_eve_classif\tBlastn\tDIAMOND (Blastx)\tBuild small RNA profiles\tHandle FASTA sequences\tRunning velvet (fixed hash)\tRunning velvet optimiser\tTotal time elapsed" > merged.tab

# Concatenate the data only, ensuring each script outputs data correctly to its file.
# Assuming each output has one line of data corresponding to the header defined above.
paste <(cat classifier_output.tab) \
      <(cut -f2- metadata_output.tab) \
      <(cut -f2- mapped_output.tab) \
      <(cut -f2- disk_usage_output.tab) \
      <(cut -f2- task_times_output.tab) >> merged.tab

sed -i '2d' merged.tab # Remove duplicate row

echo "Concatenation and initial cleaning complete. Now reordering columns..."

# Rename columns as specified and write to the temporary file
awk -F'\t' -v OFS='\t' '
BEGIN {
    # Mapping old column names to new column names
    col_rename["Preprocessed_reads"]="Reads_unmapped_bacter";
    col_rename["Total_Size(MB)"]="du_Total_Size";
    col_rename["DIAMOND (Blastx)"]="DIAMOND";
    col_rename["Build small RNA profiles"]="Build_small_RNA_profiles";
    col_rename["Total time elapsed"]="Total_time_elapsed";
    col_rename["02_filter_size_gaps_convertion"]="du_02_filter_size_gaps_convertion";
    col_rename["03_mapping_vector"]="du_03_mapping_vector";
    col_rename["04_getUnmapped"]="du_04_getUnmapped";
    col_rename["05_1_assembleUnmapped_opt"]="du_05_1_assembleUnmapped_opt";
    col_rename["05_2_assembleUnmapped_fix"]="du_05_2_assembleUnmapped_fix";
    col_rename["05_3_assembleUnmapped_opt_fix"]="du_05_3_assembleUnmapped_opt_fix";
    col_rename["05_4_assembleUnmapped_opt_20to23"]="du_05_4_assembleUnmapped_opt_20to23";
    col_rename["05_5_assembleUnmapped_opt_24to30"]="du_05_5_assembleUnmapped_opt_24to30";
    col_rename["05_6_cap3"]="du_05_6_cap3";
    col_rename["06_blast"]="du_06_blast";
    col_rename["07_reportBlast"]="du_07_reportBlast";
    col_rename["11_profiles"]="du_11_profiles";
    col_rename["12_z_score_small_rna_features"]="du_12_z_score_small_rna_features";
    col_rename["13_virus_eve_classif"]="du_13_virus_eve_classif";
    col_rename["Handle FASTA sequences"]="Handle_fasta_sequences";
    col_rename["Running velvet (fixed hash)"]="Running_velvet";
    col_rename["Running velvet optimiser"]="Running_velvet_optmiser";
    col_rename["reads_mapped_viral"]="reads_mapped_viral";
    col_rename["reads_mapped_non_viral"]="reads_mapped_non_viral";
    col_rename["reads_mapped_no_hit"]="reads_mapped_no_hit";
}
NR == 1 {
    # Print the new header based on renaming
    for (i=1; i<=NF; i++) {
        if ($i in col_rename)
            printf "%s%s", col_rename[$i], (i<NF ? OFS : "\n");
        else
            printf "%s%s", $i, (i<NF ? OFS : "\n");
    }
    next;
}
{
    # Print the data rows as they are
    print;
}' merged.tab > renamed.tab 

# Define the new order of columns explicitly as shown earlier
new_order=("Library" "Total_reads" "Reads_mapped_host" "Reads_unmapped_host" "Reads_mapped_bacter" "Reads_unmapped_bacter" "Contigs_gt200" "Number_viral_contigs" "Number_nonviral_contigs" "Number_no_hit_contigs" "Contigs_blastN_viral" "Contigs_blastN_non_viral" "Contigs_blastN_no_hits" "Contigs_diamond_viral" "Contigs_diamond_non_viral" "Contigs_diamond_no_hits" "reads_mapped_viral" "reads_mapped_non_viral" "reads_mapped_no_hit" "viral_viral" "viral_eve" "nohit_viral" "nohit_eve" "nonviral_viral" "nonviral_eve" "du_Total_Size" "du_02_filter_size_gaps_convertion" "du_03_mapping_vector" "du_04_getUnmapped" "du_05_1_assembleUnmapped_opt" "du_05_2_assembleUnmapped_fix" "du_05_3_assembleUnmapped_opt_fix" "du_05_4_assembleUnmapped_opt_20to23" "du_05_5_assembleUnmapped_opt_24to30" "du_05_6_cap3" "du_06_blast" "du_07_reportBlast" "du_11_profiles" "du_12_z_score_small_rna_features" "du_13_virus_eve_classif" "Handle_fasta_sequences" "Running_velvet" "Running_velvet_optmiser" "Blastn" "DIAMOND" "Build_small_RNA_profiles" "Total_time_elapsed")

# Script to reorder columns in a file according to a predefined list, with "NA" for missing columns
awk -F'\t' -v OFS='\t' '
BEGIN {
    # Define the desired order of columns explicitly
    split("Library Total_reads Reads_mapped_host Reads_unmapped_host Reads_mapped_bacter Reads_unmapped_bacter Contigs_gt200 Number_viral_contigs Number_nonviral_contigs Number_no_hit_contigs Contigs_blastN_viral Contigs_blastN_non_viral Contigs_blastN_no_hits Contigs_diamond_viral Contigs_diamond_non_viral Contigs_diamond_no_hits reads_mapped_viral reads_mapped_non_viral reads_mapped_no_hit viral_viral viral_eve nohit_viral nohit_eve nonviral_viral nonviral_eve du_Total_Size du_02_filter_size_gaps_convertion du_03_mapping_vector du_04_getUnmapped du_05_1_assembleUnmapped_opt du_05_2_assembleUnmapped_fix du_05_3_assembleUnmapped_opt_fix du_05_4_assembleUnmapped_opt_20to23 du_05_5_assembleUnmapped_opt_24to30 du_05_6_cap3 du_06_blast du_07_reportBlast du_11_profiles du_12_z_score_small_rna_features du_13_virus_eve_classif Handle_fasta_sequences Running_velvet Running_velvet_optmiser Blastn DIAMOND Build_small_RNA_profiles Total_time_elapsed", new_order, " ");
}
FNR == 1 {
    # Create a map from column names to their indices
    for (i=1; i<=NF; i++) {
        header[$i] = i; # Map column names to positions
    }
    # Print the reordered headers
    for (i=1; i<=length(new_order); i++) {
        printf "%s%s", new_order[i], (i<length(new_order) ? OFS : "\n");
    }
}
FNR > 1 {
    # Print each row according to the new header order
    for (i=1; i<=length(new_order); i++) {
        col_name = new_order[i];
        # Check if column exists and print its value, else print "N/A"
        if (col_name in header) {
            printf "%s%s", $(header[col_name]), (i<length(new_order) ? OFS : "\n");
        } else {
            printf "%s%s", "N/A", (i<length(new_order) ? OFS : "\n");
        }
    }
}
' renamed.tab > "$output_file"

# Cleanup
rm classifier_output.tab
rm counts.temp
rm disk_usage_output.tab
rm task_times_output.tab
rm metadata_output.tab
rm mapped_output.tab
rm merged.tab
rm renamed.tab

echo "Reordering complete. Output written to $output_file"