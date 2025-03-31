#Usage: python script.py input.fasta output.fasta

from Bio import SeqIO
import argparse

def deduplicate_fasta(input_fasta, output_fasta):
    unique_strains = {}
    with open(output_fasta, "w") as output_handle:
        for record in SeqIO.parse(input_fasta, "fasta"):
            strain_name = record.description.split('|')[2]  # Assuming strain name is at index 2
            if strain_name not in unique_strains:
                unique_strains[strain_name] = record
                SeqIO.write(record, output_handle, "fasta")
    print(f"Unique sequences have been written to {output_fasta}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Deduplicate a FASTA file based on strain name.")
    parser.add_argument("input_fasta", help="Input FASTA file")
    parser.add_argument("output_fasta", help="Output FASTA file")
    args = parser.parse_args()
    
    deduplicate_fasta(args.input_fasta, args.output_fasta)
