#!/bin/bash
#SBATCH --job-name=SpFaP2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=short
#SBATCH --time=00:30:00  # Set the appropriate time limit
#SBATCH --output=split_fastaP02.%j.out
#SBATCH --error=split_fastaP02.%j.err

# Load Anaconda module
module load anaconda3/2022.05

# Activate the Conda environment
source activate /work/gmgiMD/kpennCONDA

# Run the script with appropriate arguments
python /work/gmgiMD/code/split.fasta.py \
    -input INPUT_FASTA \
    -size 20000 \
    -prefix PREFIX
