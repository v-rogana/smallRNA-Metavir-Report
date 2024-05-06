
#!/usr/bin/env python3
import csv
import re
from pathlib import Path
import argparse

# Setup command-line argument parsing
parser = argparse.ArgumentParser(description="Extract and report the time elapsed per task from log files.")
parser.add_argument("base_directory", type=str, help="Directory containing the log files.")
parser.add_argument("output_file", type=str, help="Path for the output tab-separated file.")
args = parser.parse_args()

# Convert command-line arguments to Path objects
base_directory = Path(args.base_directory)
output_file = Path(args.output_file)

# Adjust the patterns to search for the tasks and their elapsed time more flexibly
task_patterns = {
    "Blastn": "End of step 'Blastn'",
    "DIAMOND (Blastx)": "End of step 'DIAMOND \(Blastx\)'",
    "Build small RNA profiles": "End of step 'Build small RNA profiles \(for each contig & each feature\)'",
    "Handle FASTA sequences": "End of step 'Handle FASTA sequences'",
    "Running velvet (fixed hash)": "End of step 'Running velvet \(fixed hash\)'",
    "Running velvet optimiser": "End of step 'Run Velvet optmiser \(automatically defined hash\)'",
    "Total time elapsed": "-- THE END --"
}

# Adjust regex for matching "Time elapsed" line more flexibly
time_elapsed_regex = r"Time elapsed: ([\d:]+)"

# Function to extract times for specific tasks from a log file content
def extract_task_times(log_content):
    times = {}
    for task, pattern in task_patterns.items():
        # First, find the task pattern
        task_match = re.search(pattern, log_content, re.MULTILINE)
        if task_match:
            # Then, search for the next occurrence of "Time elapsed" after this task
            time_match = re.search(time_elapsed_regex, log_content[task_match.end():], re.DOTALL)
            if time_match:
                times[task] = time_match.group(1)
            else:
                times[task] = "N/A"
        else:
            times[task] = "N/A"
    return times

# Process log files and extract times
time_data = []

for log_file in base_directory.rglob('*_virome*/*.log'):
    print(f"Processing {log_file}")
    with open(log_file, 'r', encoding='utf-8') as file:
        log_content = file.read()
        times = extract_task_times(log_content)
        # Capture the last two parts of the path as "Run_and_Batch"
        run_and_batch = '/'.join(log_file.parts[-3:-1])  # Adjust indices based on your directory structure
        batch_name = log_file.parts[-3]  # Adjust index based on your directory structure
        dir_name = log_file.parent.name
        # Include "Run_and_Batch," "Directory Name," and "Batch Name" in the row
        time_data.append([run_and_batch, dir_name, batch_name] + [times[task] for task in task_patterns])

# Adjust the headers to include the new columns
headers = ["Run_and_Batch", "Directory Name", "Batch Name"] + list(task_patterns.keys())

# Write the extracted data to a tab-separated file
with open(output_file, 'w', newline='', encoding='utf-8') as tabfile:
    writer = csv.writer(tabfile, delimiter='\t')
    writer.writerow(headers)
    writer.writerows(time_data)

print(f"Time elapsed for tasks written to {output_file}")

