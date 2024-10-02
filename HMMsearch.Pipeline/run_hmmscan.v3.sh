#!/bin/bash

# Set the project identifier (e.g., P23-A, P08-A) as a script argument
PROJECT_ID=$1

BASE_DIR="/work/gmgiMD/projects/${PROJECT_ID}"
PROJECT_DIR="${BASE_DIR}/project_files"

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

        # Count the number of generated FASTA files
        NUM_FASTA_FILES=$(ls "${TARGET_DIR}/${PREFIX}."*.fasta 2>/dev/null | wc -l)

        if [[ $NUM_FASTA_FILES -gt 0 ]]; then
            # Update the --array parameter in SBATCH.HMMSCAN.v2.sh
            sed -i "s/^#SBATCH --array=.*/#SBATCH --array=1-${NUM_FASTA_FILES}/" "${PROJECT_DIR}/SBATCH.HMMSCAN.v2.sh"

            # Export necessary environment variables for SBATCH.HMMSCAN.v2.sh
            export FASTA_DIR="${TARGET_DIR}"
            export SAMPLE_NAME="${PREFIX}"

            # Copy the updated SBATCH.HMMSCAN.v2.sh to the target directory
            cp "${PROJECT_DIR}/SBATCH.HMMSCAN.v2.sh" "${TARGET_DIR}/"

            # Submit the HMMSCAN script
            sbatch "${TARGET_DIR}/SBATCH.HMMSCAN.v2.sh"
            echo "Submitted SBATCH.HMMSCAN.v2.sh in ${TARGET_DIR} for ${NUM_FASTA_FILES} FASTA files."
        else
            echo "No FASTA files generated in ${TARGET_DIR}. Skipping HMMSCAN preparation."
        fi

        # Return to the initial directory
        cd "$BASE_DIR"
        echo "Returned to initial directory: $(pwd)"
    else
        echo "Configuration file ${CONFIG_FILE} not found. Skipping."
    fi
done
