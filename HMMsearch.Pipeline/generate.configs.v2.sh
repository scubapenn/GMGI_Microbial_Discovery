#!/bin/bash

# Set the project identifier (e.g., P23-A, P08-A) as a script argument
PROJECT_ID=$1

# Base directory and source directory
BASE_DIR="/work/gmgiMD/projects/${PROJECT_ID}"
SOURCE_DIR="/work/gmgiMD/code/HMMsearch.Pipeline.dir"
FILES=("split.fasta.py" "Make.Slurm.directories.sh" "SBATCH.split.fasta.py" "SBATCH.HMMSCAN.v2.sh")
CONDA_ENV="/work/gmgiMD/kpennCONDA"

# Automatically generate the array of input paths
INPUT_PATHS=($(ls ${BASE_DIR}/MetaGenomeAssemblyPipeline.dir/prodigal_*/*faa | xargs realpath))

# Function to extract sample identifier from input path
get_sample_id() {
    input_path=$1
    sample_id=$(basename $input_path | sed 's/prodigal_//; s/.faa//')
    echo $sample_id
}

# Generate config files
for input_path in "${INPUT_PATHS[@]}"; do
    sample_id=$(get_sample_id $input_path)
    config_file="${BASE_DIR}/config_${sample_id}.txt"
    target_dir="${BASE_DIR}/searches/split_fasta/split_fasta_${sample_id}"

    echo "BASE_DIR=\"${BASE_DIR}\"" > $config_file
    echo "TARGET_DIR=\"${target_dir}\"" >> $config_file
    echo "SOURCE_DIR=\"${SOURCE_DIR}\"" >> $config_file
    echo "FILES=(${FILES[@]})" >> $config_file
    echo "INPUT_FASTA=\"${input_path}\"" >> $config_file
    echo "PREFIX=\"${sample_id}\"" >> $config_file
    echo "CONDA_ENV=\"${CONDA_ENV}\"" >> $config_file

    echo "Generated $config_file"
done
