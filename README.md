# small-RNA-Metavir Report

**Overview:**

The "small-RNA-Metavir Report" is a script designed to process and analyze output data from the small-RNA-Metavir bioinformatics tool. This script automates the extraction of metadata, computation statistics, and other relevant data, compiling everything into a cohesive tabular report.

**Prerequisites:**

Before using the small-RNA-Metavir Report, ensure that Conda is installed on your system. Conda will be used to create an environment containing all necessary dependencies for running the script.

**Installing Conda:**

If Conda is not already installed, it can be downloaded and installed from either the Miniconda or Anaconda distribution:

[Miniconda](https://docs.anaconda.com/free/miniconda/)

**Setup Instructions:**

**Create a Conda Environment:**
Open a terminal and run the following command to create a new Conda environment:

```bash
conda create -n Report_metavir_env python=3.8 samtools
```

**Activate the Environment:**
Activate the newly created environment using:

```bash
conda activate Report_metavir_env
```

**Usage:**

To run the small-RNA-Metavir Report Generator, follow these steps:

1. **Open your Terminal:**
Navigate to the directory where the script is located.
2. **Execute the Script:**
Use the following command structure to run the script:

```bash
./Report_Metavir.sh <path_to_lib_directory> <final_output_file>
```

- **`<path_to_lib_directory>`**: Specify the full path to the directory containing the output from the small-RNA-Metavir tool.
- **`<final_output_file>`**: Specify the desired name and path for the final report file.

**Output:**

The script processes all specified data and generates a final report in tabular format, stored at the location specified by **`<final_output_file>`**. This file contains a comprehensive overview of the data extracted and processed by the script.

**Cleanup:**

The script is designed to automatically clean up all intermediate files created during its execution, ensuring that only the final report is retained.

**Contributing:**

Contributions to the small-RNA-Metavir Report are welcome. Please feel free to fork the repository, make your changes, and submit pull requests for any enhancements or bug fixes.

**Contact:**

For more information, questions, or support, please contact me at **[vrogana@gmail.com](mailto:vrogana@gmail.com) or [my github](https://github.com/v-rogana)**.