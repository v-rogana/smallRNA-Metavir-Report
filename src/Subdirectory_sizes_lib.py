#!/usr/bin/env python3
import csv
import os
from pathlib import Path
import argparse

# Setup command-line argument parsing
parser = argparse.ArgumentParser(description="Calculate and report the sizes of subdirectories in a specified directory.")
parser.add_argument("lib_directory", type=str, help="The library directory to analyze.")
parser.add_argument("output_file", type=str, help="The path for the output tab-separated file.")
args = parser.parse_args()

# Convert command-line arguments to Path objects
lib_directory = Path(args.lib_directory)
output_file = Path(args.output_file)

# Function to calculate the total size of a directory in megabytes (MB), without rounding up
def get_directory_size(directory):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(directory):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if not os.path.islink(fp):
                total_size += os.path.getsize(fp)
    return total_size / (1024 * 1024)  # Convert bytes to megabytes

# Get a sorted list of subdirectory names
subdirs = sorted([subdir.name for subdir in lib_directory.iterdir() if subdir.is_dir()])

# Prepare the header for tab-separated file, subdirectories sorted alphabetically
csv_header = ["Library", "Total_Size(MB)"] + subdirs

# Prepare data for the tab-separated file
data = []

# Process the specified library directory
if lib_directory.is_dir():
    print(f"Processing {lib_directory}")
    total_dir_size = get_directory_size(lib_directory)
    row = [lib_directory.name, f"{total_dir_size:.2f}"]  # Format total size to 2 decimal places
    for subdir_name in subdirs:
        subdir_path = lib_directory / subdir_name
        if subdir_path.is_dir():
            dir_size = get_directory_size(subdir_path)
            row.append(f"{dir_size:.2f}")  # Format size to 2 decimal places
        else:
            row.append("N/A")  # In case a subdirectory is missing, mark as N/A
    data.append(row)

# Write the data to a tab-separated file
with open(output_file, 'w', newline='', encoding='utf-8') as tabfile:
    writer = csv.writer(tabfile, delimiter='\t')
    writer.writerow(csv_header)
    writer.writerows(data)

print(f"Subdirectory sizes in MB written to {output_file}")
