#!/usr/bin/env python3
import csv
import os
from pathlib import Path
import argparse

# Setup command-line argument parsing
parser = argparse.ArgumentParser(description="Calculate and report the sizes of subdirectories in a base directory.")
parser.add_argument("base_directory", type=str, help="The base directory to analyze.")
parser.add_argument("output_file", type=str, help="The path for the output tab-separated file.")
args = parser.parse_args()

# Convert command-line arguments to Path objects
base_directory = Path(args.base_directory)
output_file = Path(args.output_file)

# Function to calculate the total size of a directory in megabytes (MB), without rounding up
def get_directory_size(directory):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(directory):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if not os.path.islink(fp):
                total_size += os.path.getsize(fp)
    # Convert bytes to megabytes without rounding up
    return total_size / (1024 * 1024)

# Assuming all "*_virome*" directories have the same set of subdirectories
sample_dir = next(base_directory.glob('*_virome*'), None)
if sample_dir is None:
    print("No *_virome directories found.")
    exit()

# Get a sorted list of subdirectory names
subdirs = sorted([subdir.name for subdir in sample_dir.iterdir() if subdir.is_dir()])

# Prepare the header for tab-separated file, subdirectories sorted alphabetically
csv_header = ["Run_and_Batch", "Total_Size(MB)"] + subdirs

# Prepare data for the tab-separated file
data = []

# Iterate over each entry in the base directory that matches "*_virome*"
for entry in base_directory.glob('*_virome*'):
    # Check if the entry is a directory before processing
    if entry.is_dir():
        print(f"Processing {entry}")
        total_dir_size = get_directory_size(entry)
        # Extract the last two parts of the path as "Run_and_Batch"
        run_and_batch = '/'.join(entry.parts[-2:])
        row = [run_and_batch, f"{total_dir_size:.2f}"]  # Format total size to 2 decimal places
        for subdir_name in subdirs:  # Use the sorted list
            subdir_path = entry / subdir_name
            if subdir_path.is_dir():  # Check if the path is a directory
                dir_size = get_directory_size(subdir_path)
                row.append(f"{dir_size:.2f}")  # Format size to 2 decimal places
            else:
                row.append("N/A")  # In case a subdirectory is missing, mark as N/A
        data.append(row)

# Write the data to a tab-separated file
with open(output_file, 'w', newline='', encoding='utf-8') as tabfile:
    writer = csv.writer(tabfile, delimiter='\t')  # Specify delimiter as tab
    writer.writerow(csv_header)
    writer.writerows(data)

print(f"Subdirectory sizes in MB written to {output_file}")

