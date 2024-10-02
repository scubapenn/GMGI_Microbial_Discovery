
# Load modules
module load gcc/9.2.0
#module load prodigal/v2.6.3 not needed I installed it in /work/gmgiMD/bin
module load cd-hit/4.8.1-2019-0228
# Parse command-line arguments
while getopts ":s:n:" opt; do
  case ${opt} in
    s )
      sample_list=$OPTARG
      ;;
    n )
      new_names_file=$OPTARG
      ;;
    \? )
      echo "Usage: $(basename $0) -s sample_list.txt -n new_names.txt"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check if sample list and new names file are provided
if [ -z "$sample_list" ] || [ -z "$new_names_file" ]; then
  echo "Sample list file and new names file are required. Usage: $(basename $0) -s sample_list.txt -n new_names.txt"
  exit 1
fi

# Load sample names from the sample list file, remove the _L00* suffix, and remove duplicates
samples=($(sed 's/_L00.*//' "$sample_list" | sort | uniq))

# Loop through each sample
for sample in "${samples[@]}"; do
    input_data_dir="megahit_output_${sample}/megahit.results/final.contigs.fa"
    output_dir="prodigal_${sample}"
    cd_hit_output_dir="${output_dir}/cdhit_results"

    # Create output directories if they don't exist
    mkdir -p "$output_dir"
    mkdir -p "$cd_hit_output_dir"

    # Print sample name for debugging
    echo "Processing sample: $sample"

    # Replace the names of the contigs in the final.contigs.fa file and output to a new file
    new_name=$(grep -w "$sample" "$new_names_file" | cut -f2)
    echo "New name for $sample: $new_name"
    sed "s/>k141/>${new_name}/g" "$input_data_dir" > "${input_data_dir}_modified.fa"
    input_data_file_modified="${input_data_dir}_modified.fa"

    # Run Prodigal
    prodigal -i "$input_data_file_modified" -a "${output_dir}/prodigal_${sample}.faa" -d "${output_dir}/prodigal_${sample}.fna" -p meta

    # Print a newline for better readability
    echo

    # Clean up headers in the Prodigal results file
    sed -i 's/ .*//g' "${output_dir}/prodigal_${sample}.faa"

    # Loop through different identity thresholds for CD-HIT
    identity_thresholds=("99" "95" "90")
    for threshold in "${identity_thresholds[@]}"; do
        # Run CD-HIT on cleaned amino acid sequences
        cd-hit -i "${output_dir}/prodigal_${sample}.faa" -o "${cd_hit_output_dir}/${sample}.CD-hit.${threshold}perc" -c 0.${threshold} -n 5 -M 204800 -T 28

        # Print a newline for better readability
        echo
    done
done
