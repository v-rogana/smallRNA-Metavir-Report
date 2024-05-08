#!/usr/bin/env python3
import csv
import argparse
from collections import defaultdict, OrderedDict

# Setup command-line argument parsing
parser = argparse.ArgumentParser(description="Merge multiple tab-separated files into a single file based on Library.")
parser.add_argument("output_file", type=str, help="Path for the merged output tab-separated file.")
parser.add_argument("tab_files", nargs='+', help="A list of paths to tab-separated files to merge.")
args = parser.parse_args()

# Dictionary to hold data for each Library
merged_data = defaultdict(OrderedDict)  # Using OrderedDict to preserve column order

# Set to store all unique headers
all_headers = set()

# First pass: collect all headers and initialize data structure
for file_path in args.tab_files:
    with open(file_path, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file, delimiter='\t')
        all_headers.update(reader.fieldnames)
        for row in reader:
            library = row["Library"]
            if library not in merged_data:
                merged_data[library] = OrderedDict.fromkeys(all_headers, 'N/A')  # Initialize all fields to 'N/A'
            merged_data[library].update(row)

# Second pass: write data to output file
with open(args.output_file, 'w', newline='', encoding='utf-8') as file:
    fieldnames = ["Library"] + list(all_headers - {"Library"})  # Reorder headers putting 'Library' first
    writer = csv.DictWriter(file, fieldnames=fieldnames, delimiter='\t')
    writer.writeheader()
    for data in merged_data.values():
        writer.writerow(data)

print(f"Merged data written to {args.output_file}")
