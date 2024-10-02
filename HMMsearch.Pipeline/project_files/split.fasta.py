import argparse
from Bio import SeqIO

# Function to split the FASTA file into smaller files based on the given size
def split_fasta(input_file, sequences_per_file, output_prefix):
    try:
        with open(input_file, "r") as input_fasta:
            fasta_iterator = SeqIO.parse(input_fasta, "fasta")

            file_number = 1
            sequence_counter = 0
            current_sequences = []

            for record in fasta_iterator:
                current_sequences.append(record)
                sequence_counter += 1

                # Once we reach the limit, write to a new file
                if sequence_counter == sequences_per_file:
                    # Create output file name
                    output_file_name = f"{output_prefix}.{str(file_number).zfill(3)}.fasta"
                    
                    # Write the current sequences to the new file
                    with open(output_file_name, "w") as output_file:
                        SeqIO.write(current_sequences, output_file, "fasta")

                    # Reset for the next batch
                    file_number += 1
                    current_sequences = []
                    sequence_counter = 0

            # Handle remaining sequences after the last full batch
            if current_sequences:
                output_file_name = f"{output_prefix}.{str(file_number).zfill(3)}.fasta"
                with open(output_file_name, "w") as output_file:
                    SeqIO.write(current_sequences, output_file, "fasta")

        print("Splitting complete. Files created successfully.")

    except Exception as e:
        print(f"An error occurred: {e}")

# Use argparse to parse command-line flags
def main():
    parser = argparse.ArgumentParser(description="Split a FASTA file into smaller files based on a specified number of sequences.")
    parser.add_argument("-input", required=True, help="Path to the input FASTA file.")
    parser.add_argument("-size", required=True, type=int, help="Number of sequences per output file.")
    parser.add_argument("-prefix", required=True, help="Prefix for the output file names.")

    args = parser.parse_args()

    split_fasta(args.input, args.size, args.prefix)

if __name__ == "__main__":
    main()
