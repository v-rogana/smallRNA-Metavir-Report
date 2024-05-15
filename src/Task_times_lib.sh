#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <lib_directory> <output_file>"
    exit 1
fi

lib_directory=$1
output_file=$2

# Check if the directory exists
if [[ ! -d "$lib_directory" ]]; then
    echo "The specified directory does not exist."
    exit 2
fi

# Get the basename of the library directory
library_name=$(basename "$lib_directory")

# Find the first log file that matches the pattern *.log
log_file=$(find "$lib_directory" -maxdepth 1 -type f -name "*.log" | head -n 1)

if [[ -z "$log_file" ]]; then
    echo "No log file found in the directory."
    exit 3
fi

# Print the header into the output file
echo -e "Library\tBlastn\tDIAMOND (Blastx)\tBuild small RNA profiles\tHandle FASTA sequences\tRunning velvet (fixed hash)\tRunning velvet optimiser\tTotal time elapsed" > "$output_file"

# Execute awk to extract and format the output as a table, and APPEND to the specified output file
awk -v libName="$library_name" -v outFile="$output_file" '
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
