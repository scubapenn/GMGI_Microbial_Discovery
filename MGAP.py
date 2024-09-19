import argparse
import glob
import os
import shutil
import subprocess

def main():
    parser = argparse.ArgumentParser(description="Process input data for MEGAHIT assembly")
    parser.add_argument("sample_list", help="Path to the file containing the list of sample names")
    parser.add_argument("input_data_dir", help="Path to the directory containing the raw read files")
    args = parser.parse_args()

    # Adapter fastas directory
    adapters_dir = "/work/gmgiMD/bin/trimmomatic.adapters.dir"

    # Load sample names from the file
    with open(args.sample_list, "r") as f:
        sample_list = [line.strip() for line in f if line.strip()]

    for sample in sample_list:
        # Extract sample name without the file extension
        sample_name = os.path.splitext(os.path.basename(sample))[0]
        sample_name_without_suffix = sample_name.rsplit("_", 1)[0]  # Remove suffix like _L001
        # Create output directory
        output_dir = f"./megahit_output_{sample_name}"
        os.makedirs(output_dir, exist_ok=True)

        # Run Trimmomatic to perform quality trimming   java -jar /shared/centos7/trimmomatic/0.39/trimmomatic-0.39.jar
        subprocess.run([
            "java", "-jar", "/shared/centos7/trimmomatic/0.39/trimmomatic-0.39.jar",
            "PE", "-threads", "30", "-phred33",
            f"{args.input_data_dir}/{sample}_R1_001.fastq.gz", f"{args.input_data_dir}/{sample}_R2_001.fastq.gz",
            f"{output_dir}/{sample_name}_trimmed_1.fastq", f"{output_dir}/{sample_name}_unpaired_1.fastq",
            f"{output_dir}/{sample_name}_trimmed_2.fastq", f"{output_dir}/{sample_name}_unpaired_2.fastq",
            "ILLUMINACLIP:"f"{adapters_dir}/TruSeq3-PE.fa:2:30:10", "LEADING:3", "TRAILING:3", "SLIDINGWINDOW:4:15", "MINLEN:36"
        ])

        # Print a message indicating completion
        print(f"Trimmomatic run completed successfully. Output stored in: {output_dir}")

    # Concatenate trimmed and unpaired files for all samples into single files
    for sample in sample_list:
        sample_name = os.path.splitext(os.path.basename(sample))[0]
        sample_name_without_suffix = sample_name.rsplit("_", 1)[0]  # Remove suffix like _L001

        concatenated_output_dir = f"./megahit_output_{sample_name_without_suffix}"
        os.makedirs(concatenated_output_dir, exist_ok=True)

        concatenated_trimmed_1_path = f"{concatenated_output_dir}/{sample_name_without_suffix}_concatenated_trimmed_1.fastq"
        concatenated_trimmed_2_path = f"{concatenated_output_dir}/{sample_name_without_suffix}_concatenated_trimmed_2.fastq"
        concatenated_unpaired_path = f"{concatenated_output_dir}/{sample_name_without_suffix}_concatenated_unpaired.fastq"

        with open(concatenated_trimmed_1_path, "a") as concatenated_trimmed_1_file:
            for file_path in glob.glob(f"./megahit_output_{sample_name}/*_trimmed_1.fastq"):
                with open(file_path, "r") as current_file:
                    concatenated_trimmed_1_file.write(current_file.read())

        with open(concatenated_trimmed_2_path, "a") as concatenated_trimmed_2_file:
            for file_path in glob.glob(f"./megahit_output_{sample_name}/*_trimmed_2.fastq"):
                with open(file_path, "r") as current_file:
                    concatenated_trimmed_2_file.write(current_file.read())

        with open(concatenated_unpaired_path, "a") as concatenated_unpaired_file:
            for file_path in glob.glob(f"./megahit_output_{sample_name}/*_unpaired*.fastq"):
                with open(file_path, "r") as current_file:
                    concatenated_unpaired_file.write(current_file.read())

        # Print a message indicating completion
        print(f"Concatenation completed successfully. Output stored in: {concatenated_output_dir}")

    # Run MEGAHIT on the concatenated data using subprocess
    for sample in sample_list:
        sample_name_without_suffix = sample.rsplit("_", 1)[0]  # Remove suffix like _L001
        concatenated_output_dir = f"./megahit_output_{sample_name_without_suffix}"
        megahit_command = [
            "megahit",
            "-t", "28",
            "-m", "256000000000",
            "-1", f"{concatenated_output_dir}/{sample_name_without_suffix}_concatenated_trimmed_1.fastq",
            "-2", f"{concatenated_output_dir}/{sample_name_without_suffix}_concatenated_trimmed_2.fastq",
            "-r", f"{concatenated_output_dir}/{sample_name_without_suffix}_concatenated_unpaired.fastq",
            "-o", f"{concatenated_output_dir}/megahit.results"
        ]
        subprocess.run(megahit_command)

        # Print a message indicating completion
        print(f"MEGAHIT run completed. Output stored in: {concatenated_output_dir}/megahit.results")

if __name__ == "__main__":
    main()
