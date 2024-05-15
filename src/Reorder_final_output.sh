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

# Use awk to rename and reorder columns in a tab-separated file
awk -F'\t' '
BEGIN {
    OFS=","; # Define comma as the output field separator
    # Mapping old column names to new column names
    col_rename["Preprocessed_reads"]="Reads_unmapped_bacter";
    col_rename["Total_Size(MB)"]="du_Total_Size";
    col_rename["DIAMOND (Blastx)"]="DIAMOND";
    col_rename["Build small RNA profiles"]="Build_small_RNA_profiles";
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
    # Create a mapping of indices based on the new column names
    for (i=1; i<=NF; i++) {
        if ($i in col_rename) {
            col_index[i] = col_rename[$i];
        } else {
            col_index[i] = $i;
        }
    }
    # Print the reordered header line
    print "Library","Total_reads","Reads_mapped_host","Reads_unmapped_host","Reads_mapped_bacter","Reads_unmapped_bacter","Contigs_gt200","Number_viral_contigs","Number_nonviral_contigs","Number_no_hit_contigs","Contigs_blastN_viral","Contigs_blastN_non_viral","Contigs_blastN_no_hits","Contigs_diamond_viral","Contigs_diamond_non_viral","Contigs_diamond_no_hits","reads_mapped_viral","reads_mapped_non_viral","reads_mapped_no_hit","viral_viral","viral_eve","nohit_viral","nohit_eve","nonviral_viral","nonviral_eve","du_Total_Size","du_02_filter_size_gaps_convertion","du_03_mapping_vector","du_04_getUnmapped","du_05_1_assembleUnmapped_opt","du_05_2_assembleUnmapped_fix","du_05_3_assembleUnmapped_opt_fix","du_05_4_assembleUnmapped_opt_20to23","du_05_5_assembleUnmapped_opt_24to30","du_05_6_cap3","du_06_blast","du_07_reportBlast","du_11_profiles","du_12_z_score_small_rna_features","du_13_virus_eve_classif","Handle_fasta_sequences","Running_velvet","Running_velvet_optmiser","Blastn","DIAMOND","Build_small_RNA_profiles","Total_time_elapsed";
}
NR > 1 {
    # Print data lines with reordered columns
    line = "";
    for (col_name in col_index) {
        line = line ($col_index[col_name] ? $(col_index[col_name]) : "") OFS;
    }
    print substr(line, 1, length(line)-1);
}
' "$input_file" > "$output_file"

echo "Reordering complete. Output written to $output_file"
