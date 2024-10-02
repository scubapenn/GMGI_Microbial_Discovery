#!/bin/bash

# This script creates the necessary SLURM directories for a given project

# Set the project identifier (e.g., P23-A, P08-A) as a script argument
PROJECT_ID=$1

BASE_DIR="/work/gmgiMD/projects/${PROJECT_ID}"
PROJECT_FILES_DIR="/work/gmgiMD/code/HMMsearch.Pipeline.dir/project_files"

# Create the project_files directory if it doesn't exist
mkdir -p "${BASE_DIR}/project_files"

# Copy the necessary files to the project_files directory
cp "${PROJECT_FILES_DIR}/SBATCH.HMMSCAN.v2.sh" "${BASE_DIR}/project_files/"
cp "${PROJECT_FILES_DIR}/Make.Slurm.directories.sh" "${BASE_DIR}/project_files/"
