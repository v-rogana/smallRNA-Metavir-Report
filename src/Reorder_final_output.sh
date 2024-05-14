#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

input_file=$1
output_file=$2

# Verify if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Input file does not exist."
    exit 2
fi

# Define column mappings and the new column order
declare -A column_map=(
    ["Preprocessed_reads"]="Reads_unmapped_bacter"
    ["Total_Size(MB)"]="du_Total_Size"
    ["DIAMOND (Blastx)"]="DIAMOND"
    ["Build small RNA profiles"]="Build_small_RNA_profiles"
    ["Total time elapsed"]="Total_time_elapsed"
    ["02_filter_size_gaps_convertion"]="du_02_filter_size_gaps_convertion"
    ["03_mapping_vector"]="du_03_mapping_vector"
    ["04_getUnmapped"]="du_04_getUnmapped"
    ["05_1_assembleUnmapped_opt"]="du_05_1_assembleUnmapped_opt"
    ["05_2_assembleUnmapped_fix"]="du_05_2_assembleUnmapped_fix"
    ["05_3_assembleUnmapped_opt_fix"]="du_05_3_assembleUnmapped_opt_fix"
    ["05_4_assembleUnmapped_opt_20to23"]="du_05_4_assembleUnmapped_opt_20to23"
    ["05_5_assembleUnmapped_opt_24to30"]="du_05_5_assembleUnmapped_opt_24to30"
    ["05_6_cap3"]="du_05_6_cap3"
    ["06_blast"]="du_06_blast"
    ["07_reportBlast"]="du_07_reportBlast"
    ["11_profiles"]="du_11_profiles"
    ["12_z_score_small_rna_features"]="du_12_z_score_small_rna_features"
    ["13_virus_eve_classif"]="du_13_virus_eve_classif"
    ["Handle FASTA sequences"]="Handle_fasta_sequences"
    ["Running velvet (fixed hash)"]="Running_velvet"
    ["Running velvet optimiser"]="Running_velvet_optmiser"
    ["reads_mapped_viral"]="reads_mapped_viral"
    ["reads_mapped_non_viral"]="reads_mapped_non_viral"
    ["reads_mapped_no_hit"]="reads_mapped_no_hit"
)

# New column order
new_order=("Library" "Total_reads" "Reads_mapped_host" "Reads_unmapped_host"
        "Reads_mapped_bacter" "Reads_unmapped_bacter" "Contigs_gt200" "Number_viral_contigs"
        "Number_nonviral_contigs" "Number_no_hit_contigs" "Contigs_blastN_viral"
        "Contigs_blastN_non_viral" "Contigs_blastN_no_hits" "Contigs_diamond_viral"
        "Contigs_diamond_non_viral" "Contigs_diamond_no_hits" "reads_mapped_viral"
        "reads_mapped_non_viral" "reads_mapped_no_hit" "viral_viral" "viral_eve"
        "nohit_viral" "nohit_eve" "nonviral_viral" "nonviral_eve" "du_Total_Size"
        "du_02_filter_size_gaps_convertion" "du_03_mapping_vector" "du_04_getUnmapped"
        "du_05_1_assembleUnmapped_opt" "du_05_2_assembleUnmapped_fix" "du_05_3_assembleUnmapped_opt_fix"
        "du_05_4_assembleUnmapped_opt_20to23" "du_05_5_assembleUnmapped_opt_24to30" "du_05_6_cap3"
        "du_06_blast" "du_07_reportBlast" "du_11_profiles" "du_12_z_score_small_rna_features"
        "du_13_virus_eve_classif" "Handle_fasta_sequences" "Running_velvet"
        "Running_velvet_optmiser" "Blastn" "DIAMOND" "Build_small_RNA_profiles" "Total_time_elapsed")

# Read the header and data
{
    read -r header
    oldIFS="$IFS"
    IFS=$'\t' read -ra headers <<< "$header"
    IFS="$oldIFS"

    # Create a new header based on the mapping
    new_header=""
    for col in "${headers[@]}"; do
        if [[ ${column_map[$col]+_} ]]; then
            new_header+="${column_map[$col]}"
        else
            new_header+="$col"
        fi
        new_header+=$'\t'  # Append a real tab character
    done
    new_header=${new_header%$'\t'}  # Remove the trailing tab

    echo "$new_header"  # Output the new header using echo to interpret escape sequences

    # Output the rest of the file
    while IFS= read -r line; do
        echo "$line"
    done
} < "$input_file" > "$output_file"

echo "Header remapping complete. Processed data written to $output_file"