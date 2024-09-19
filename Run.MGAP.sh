#!/bin/bash
#SBATCH --job-name=mghtP19
#SBATCH --nodes=1
#SBATCH --mem=1000G
#SBATCH --cpus-per-task=28
#SBATCH --time=5-00:00:00
#SBATCH --partition=long
#SBATCH --output=megahit.P19_output.%j.out
#SBATCH --error=megahit.P19_output.%j.err


# Load the necessary modules
module load anaconda3/2022.05  # Adjust to your system's module version

# Activate the Conda environment with Java installed
source activate /work/gmgiMD/kpennCONDA

#Load Trimmomatic 
module load trimmomatic/0.39
# Load MEGAHIT module
module load megahit
module load python/3.8.1

#Setup the Directories
#mkdir MetaGenomeAssemblyPipeline.dir
#mkdir rawdata (I will do this part)

# Decompress the tar.gz file and move it to the rawdata folder
#tar -xzvf /work/gmgiMD/AWS/Arbor-P14_FW-sediment.tar.gz -C rawdata/ ( I will do this)
#ls rawdata/*fastq.gz | sed 's/rawdata\///g' | sed 's/_R.*//g' >  MetaGenomeAssemblyPipeline.dir/SampleList

#put the MGAP.py in the correct place and then move into that directory
#mv MGAP.py MetaGenomeAssemblyPipeline.dir/.
cd MetaGenomeAssemblyPipeline.dir

# Run Python script
python3 MGAP.py SampleList  /work/gmgiMD/projects/P19-A/rawdata
