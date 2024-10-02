#!/bin/bash

# Set the project identifier (e.g., P23-A, P08-A) as a script argument
PROJECT_ID=$1

BASE_DIR="/work/gmgiMD/projects/${PROJECT_ID}"
SEARCHES_DIR="${BASE_DIR}/searches/split_fasta"
PROJECT_DIR="${BASE_DIR}/project_files"
SOURCE_DIR="/work/gmgiMD/projects/P02-A/searches/split_fasta/split_fasta_20190425-JR_S3"

# Files to copy
FILES_TO_COPY=(
#    "split.fasta.py"
#    "Make.Slurm.directories.sh"
#    "SBATCH.split.fasta.py"
#    "SBATCH.HMMSCAN.v2.sh"
)

# Copy necessary files to the project directory
mkdir -p "$PROJECT_DIR"
for file in "${FILES_TO_COPY[@]}"; do
    cp "${SOURCE_DIR}/${file}" "$PROJECT_DIR/"
done

# Generate the list of sample identifiers from config files
CONFIG_FILES=(${BASE_DIR}/config_*.txt)
SAMPLES=()
for config_file in "${CONFIG_FILES[@]}"; do
    sample_id=$(basename "$config_file" | sed 's/config_//; s/.txt//')
    SAMPLES+=("$sample_id")
done

for sample in "${SAMPLES[@]}"; do
    # Load configuration from the config file
    CONFIG_FILE="${BASE_DIR}/config_${sample}.txt"
    echo "Config file: $CONFIG_FILE"

    if [[ -f "${CONFIG_FILE}" ]]; then
        # Source the configuration file
        source "${CONFIG_FILE}"

        # Change to the target directory
        if [[ ! -d "${TARGET_DIR}" ]]; then
            echo "Creating directory: ${TARGET_DIR}"
            mkdir -p "${TARGET_DIR}"
        fi
        cd "${TARGET_DIR}"
        echo "Changed directory to: $(pwd)"

        # Prepare the SBATCH script for this sample
        SBATCH_SCRIPT="${PROJECT_DIR}/SBATCH.split.fasta.py"
        TEMP_SBATCH_SCRIPT="${TARGET_DIR}/SBATCH.split.fasta.py"

        # Copy the template SBATCH script to the target directory
        cp "${SBATCH_SCRIPT}" "${TEMP_SBATCH_SCRIPT}"

        # Replace placeholders in the SBATCH script
        sed -i "s|INPUT_FASTA|${INPUT_FASTA}|g" "${TEMP_SBATCH_SCRIPT}"
        sed -i "s|PREFIX|${PREFIX}|g" "${TEMP_SBATCH_SCRIPT}"
        sed -i "s|INPUT_FASTA|${INPUT_FASTA}|g" "${TEMP_SBATCH_SCRIPT}"

        # Submit the SBATCH script
        sbatch "${TEMP_SBATCH_SCRIPT}"
        echo "Submitted SBATCH.split.fasta.py for sample ${sample}."

        # Return to the initial directory
        cd "$BASE_DIR"
        echo "Returned to initial directory: $(pwd)"
    else
        echo "Configuration file ${CONFIG_FILE} not found. Skipping."
    fi
done
