from Bio import SeqIO

input_file = input("Enter input fasta ")
output_file = input("Enter output fasta: ")

with open(input_file, "r") as in_handle, open(output_file, "w") as out_handle:
    unique_seqs = set()
    for seq_record in SeqIO.parse(in_handle, "fasta"):
        if str(seq_record.seq) not in unique_seqs:
            unique_seqs.add(str(seq_record.seq))
            SeqIO.write(seq_record, out_handle, "fasta")

print(output_file, "created")
