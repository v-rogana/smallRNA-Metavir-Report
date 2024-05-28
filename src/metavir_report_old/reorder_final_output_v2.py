#!/usr/bin/env python3
import csv
import argparse

def process_file(input_file, output_file):
    # Column name mappings
    column_map = {
        "Directory Name": "Directory_Name",
        "Batch Name": "Batch_Name",
        "Preprocessed_reads": "Reads_unmapped_bacter",
        "Total_Size(MB)": "du_Total_Size",
        "DIAMOND (Blastx)": "DIAMOND",
        "Build small RNA profiles": "Build_small_RNA_profiles",
        "Total time elapsed": "Total_time_elapsed",
        "02_filter_size_gaps_convertion": "du_02_filter_size_gaps_convertion",
        "03_mapping_vector": "du_03_mapping_vector",
        "04_getUnmapped": "du_04_getUnmapped",
        "05_1_assembleUnmapped_opt": "du_05_1_assembleUnmapped_opt",
        "05_2_assembleUnmapped_fix": "du_05_2_assembleUnmapped_fix",
        "05_3_assembleUnmapped_opt_fix": "du_05_3_assembleUnmapped_opt_fix",
        "05_4_assembleUnmapped_opt_20to23": "du_05_4_assembleUnmapped_opt_20to23",
        "05_5_assembleUnmapped_opt_24to30": "du_05_5_assembleUnmapped_opt_24to30",
        "05_6_cap3": "du_05_6_cap3",
        "06_blast": "du_06_blast",
        "07_reportBlast": "du_07_reportBlast",
        "11_profiles": "du_11_profiles",
        "12_z_score_small_rna_features": "du_12_z_score_small_rna_features",
        "13_virus_eve_classif": "du_13_virus_eve_classif",
        "Handle FASTA sequences": "Handle_fasta_sequences",
        "Running velvet (fixed hash)": "Running_velvet",
        "Running velvet optimiser": "Running_velvet_optmiser",
        "reads_mapped_viral": "reads_mapped_viral",
        "reads_mapped_non_viral": "reads_mapped_non_viral",
        "reads_mapped_no_hit": "reads_mapped_no_hit"
    }

    # New column order
    new_order = [
        "Directory_Name", "Batch_Name", "Total_reads", "Reads_mapped_host", "Reads_unmapped_host",
        "Reads_mapped_bacter", "Reads_unmapped_bacter", "Contigs_gt200", "Number_viral_contigs",
        "Number_nonviral_contigs", "Number_no_hit_contigs", "Contigs_blastN_viral",
        "Contigs_blastN_non_viral", "Contigs_blastN_no_hits", "Contigs_diamond_viral",
        "Contigs_diamond_non_viral", "Contigs_diamond_no_hits", "reads_mapped_viral",
        "reads_mapped_non_viral", "reads_mapped_no_hit", "viral_viral", "viral_eve",
        "nohit_viral", "nohit_eve", "nonviral_viral", "nonviral_eve", "du_Total_Size",
        "du_02_filter_size_gaps_convertion", "du_03_mapping_vector", "du_04_getUnmapped",
        "du_05_1_assembleUnmapped_opt", "du_05_2_assembleUnmapped_fix", "du_05_3_assembleUnmapped_opt_fix",
        "du_05_4_assembleUnmapped_opt_20to23", "du_05_5_assembleUnmapped_opt_24to30", "du_05_6_cap3",
        "du_06_blast", "du_07_reportBlast", "du_11_profiles", "du_12_z_score_small_rna_features",
        "du_13_virus_eve_classif", "Handle_fasta_sequences", "Running_velvet",
        "Running_velvet_optmiser", "Blastn", "DIAMOND", "Build_small_RNA_profiles", "Total_time_elapsed"
    ]

    # Read input file
    with open(input_file, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file, delimiter='\t')
        original_headers = reader.fieldnames
        rows = list(reader)

    # Check for any missing expected columns in the input file
    missing_columns = set(column_map.keys()).difference(original_headers)
    if missing_columns:
        print(f"Warning: Missing columns in input file: {missing_columns}")

    # Rename columns according to the map and prepare new row order
    processed_rows = []
    for row in rows:
        new_row = {}
        for old_name, new_name in column_map.items():
            if old_name in row:
                new_row[new_name] = row[old_name]
        # Fill missing mapped columns with 'N/A'
        for column in new_order:
            if column not in new_row:
                new_row[column] = row.get(column, 'N/A')
        processed_rows.append(new_row)

    # Write processed data to output file
    with open(output_file, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=new_order, delimiter='\t')
        writer.writeheader()
        writer.writerows(processed_rows)

    print(f"Processed data written to {output_file}")

# Command-line interface setup
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process and reformat tab-separated file.")
    parser.add_argument("input_file", type=str, help="Path to the input tab-separated file.")
    parser.add_argument("output_file", type=str, help="Path for the processed output tab-separated file.")
    args = parser.parse_args()
    process_file(args.input_file, args.output_file)


