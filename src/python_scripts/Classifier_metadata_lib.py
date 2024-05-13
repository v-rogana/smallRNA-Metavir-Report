#!/usr/bin/env python3
import argparse
import csv
from collections import defaultdict
from pathlib import Path

# Set up argument parser
parser = argparse.ArgumentParser(description="Count combination of the neural network classification")
parser.add_argument("lib_directory", type=str, help="Library directory containing the target files for classification")
parser.add_argument("output_file_name", type=str, help="Name of the output file")

# Parse arguments
args = parser.parse_args()

# Use the provided arguments
lib_directory = Path(args.lib_directory)
output_file = Path.cwd() / args.output_file_name

# Define the combinations to track in the desired order
combinations = [
    "viral_viral", "viral_eve", "nohit_viral", "nohit_eve",
    "nonviral_viral", "nonviral_eve"
]

# Initialize a list to hold the rows for the output CSV
output_rows = []

# Loop through each CSV file in the specified path
for csv_file in lib_directory.glob('13_virus_eve_classif/*.csv'):
    print(f"Processing {csv_file}")
    # Initialize counts for this file
    counts = defaultdict(int)  # Use defaultdict to initialize counts to 0

    with open(csv_file, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            if len(row) > 51:  # Ensure the row has enough columns
                # Adjust combination keys to match the new format (replace commas with underscores)
                key = f"{row[2]}_{row[51]}".replace(",", "_")
                counts[key] += 1

    # Prepare the row for this directory
    row = [lib_directory.name] + [counts[comb] for comb in combinations]
    output_rows.append(row)

# Write the output TAB file
with open(output_file, mode='w', encoding='utf-8', newline='') as file:
    # Specify the delimiter as a tab character
    writer = csv.writer(file, delimiter='\t')
    # Write the header, converting combinations to the format with underscores
    writer.writerow(["Library"] + combinations)
    # Write the rows
    writer.writerows(output_rows)

print(f"Classifier info written to {output_file}")
