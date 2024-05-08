#!/usr/bin/env python3
from pathlib import Path
import csv
import re
import argparse

# Setup command-line argument parsing
parser = argparse.ArgumentParser(description="Process virome metadata and log files.")
parser.add_argument("lib_directory", type=str, help="Library directory where the log file is located")
parser.add_argument("output_file", type=str, help="Path for the output tab-separated file")
args = parser.parse_args()

# Assign command-line arguments to variables
lib_directory = Path(args.lib_directory)
output_file = Path(args.output_file)

# New header with updated column names
header = [
    "Library", "Contigs_gt200", "Number_viral_contigs",
    "Number_nonviral_contigs", "Number_no_hit_contigs",
    "Total_reads", "Reads_mapped_host", "Reads_unmapped_host", "Reads_mapped_bacter",
    "Preprocessed_reads", "Total_assembled_contigs", "Contigs_diamond_viral",
    "Contigs_diamond_non_viral", "Contigs_diamond_no_hits",
    "Contigs_blastN_viral", "Contigs_blastN_non_viral",
    "Contigs_blastN_no_hits"
]

def extract_numbers(log_file):
    with open(log_file, encoding='utf-8') as file:
        content = file.read()
        data = {
            'contigs_gt200': re.search(r"# Contigs gt200\s+(\d+)", content),
            'viral_contigs': re.search(r"# Number of contigs \(all\) \[viral\]\s+(\d+)", content),
            'non_viral_contigs': re.search(r"# Number of contigs \(all\) \[non viral\]\s+(\d+)", content),
            'no_hits_contigs': re.search(r"# Number of contigs \(all\) \[no hits\]\s+(\d+)", content),
            'total_reads': re.search(r"# Total reads\s+(\d+)", content),
            'reads_mapped_host': re.search(r"# Reads mapped host\s+(\d+)", content),
            'reads_unmapped_host': re.search(r"# Reads unmapped host\s+(\d+)", content),
            'reads_mapped_bacter': re.search(r"# Reads mapped bacter\s+(\d+)", content),
            'preprocessed_reads': re.search(r"# Preprocessed reads\s+(\d+)", content),
            'total_assembled_contigs': re.search(r"# Total assembled contigs\s+(\d+)", content),
            'diamond_viral': re.search(r"# Number of contigs \(diamond\) \[viral\]\s+(\d+)", content),
            'diamond_non_viral': re.search(r"# Number of contigs \(diamond\) \[non viral\]\s+(\d+)", content),
            'diamond_no_hits': re.search(r"# Number of contigs \(diamond\) \[no hits\]\s+(\d+)", content),
            'blastN_viral': re.search(r"# Number of contigs \(blastN\) \[viral\]\s+(\d+)", content),
            'blastN_non_viral': re.search(r"# Number of contigs \(blastN\) \[non viral\]\s+(\d+)", content),
            'blastN_no_hits': re.search(r"# Number of contigs \(blastN\) \[no hits\]\s+(\d+)", content),
        }
        return [lib_directory.name] + [m.group(1) if m else '0' for m in data.values()]

# Write data to a tab-separated file
with open(output_file, 'w', newline='', encoding='utf-8') as tabfile:
    writer = csv.writer(tabfile, delimiter='\t')
    writer.writerow(header)

    # Process log files in the specified library directory
    for log_file in lib_directory.glob("*.log"):
        if log_file.is_file():
            data_row = extract_numbers(log_file)
            writer.writerow(data_row)

print("Metadata extraction complete. Data saved to", output_file)
