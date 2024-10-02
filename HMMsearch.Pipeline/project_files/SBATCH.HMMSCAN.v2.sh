#!/bin/bash
#SBATCH --job-name=hmmscan_array          # Name of the job
#SBATCH --output=output_files/hmmscan_output_%A_%a.txt  # Standard output log
#SBATCH --error=error_files/hmmscan_error_%A_%a.txt    # Standard error log
#SBATCH --array=1-58
#SBATCH --partition=short                 # SLURM partition to use
#SBATCH --mem=4G                          # Memory per task (adjust as needed)
#SBATCH --cpus-per-task=8                 # Request 8 CPU cores for multi-threading
#SBATCH --mail-type=END,FAIL              # Send email when job ends or fails
#SBATCH --mail-user=kevin.penn@gmgi.org   # Your email address for notifications

# Load any required modules (e.g., for hmmer)
#module load hmmer/3.4                     # Adjust as needed

# Define the path to the hmmscan binary
HMMSCAN_BIN="/work/gmgiMD/bin/hmmer-3.4/bin/hmmscan"

# Get the path to the FASTA files and the sample name from environment variables
FASTA_DIR="${FASTA_DIR}"
HMM_DATABASE="/work/gmgiMD/Database/PFAM/Pfam-A.hmm"   # Path to your HMM database
SAMPLE_NAME="${SAMPLE_NAME}"

# Define the input FASTA file based on the SLURM_ARRAY_TASK_ID
FASTA_FILE="${FASTA_DIR}/${SAMPLE_NAME}.$(printf "%03d" $SLURM_ARRAY_TASK_ID).fasta"

# Define the output file for this task
OUTPUT_FILE="hmmscan_result_${SAMPLE_NAME}_$(printf "%03d" $SLURM_ARRAY_TASK_ID).txt"

# Set E-value cutoff and number of threads
THREADS=8
EVALUE_CUTOFF=1e-5

# Run hmmscan with multi-threading and E-value cutoff
$HMMSCAN_BIN -E $EVALUE_CUTOFF --cpu $THREADS --tblout $OUTPUT_FILE $HMM_DATABASE $FASTA_FILE
