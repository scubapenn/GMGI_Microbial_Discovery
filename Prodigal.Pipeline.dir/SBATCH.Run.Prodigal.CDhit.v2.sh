#!/bin/bash
#SBATCH --job-name=prodigal_cdhit_job
#SBATCH --nodes=1
#SBATCH --mem=128G
#SBATCH --cpus-per-task=28
#SBATCH --time=5-00:00:00
#SBATCH --partition=long
#SBATCH --output=prodigal_cdhit_output.%j.out
#SBATCH --error=prodigal_cdhit_output.%j.err
#SBATCH --mail-type=END              # Email notification when the job ends
#SBATCH --mail-user=kevin.penn@gmgi.org   # Replace with your email address

# Load modules
module load gcc/9.2.0
#module load prodigal/v2.6.3 not needed I installed it in /work/gmgiMD/bin
module load cd-hit/4.8.1-2019-0228

# Job command
./Run.Prodigal.CDhit.sh -s SampleList -n new_names.txt

# Send email notification with job name in the subject
mail -s "Job ${SLURM_JOB_NAME} (${SLURM_JOB_ID}) Completed" kevin.penn@gmgi.org <<EOF
< "The job ${SLURM_JOB_NAME} with Job ID ${SLURM_JOB_ID} has completed successfully."
EOF
