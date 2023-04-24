import sys


# usage example NNN 10% of seq: python remove_N_percentseq.py alignment.fasta 10 > outputfile.fasta

def read_fasta(filename):
    seqs = {}
    with open(filename) as f:
        seq_id = None
        seq = ""
        for line in f:
            line = line.strip()
            if line.startswith(">"):
                if seq_id is not None:
                    seqs[seq_id] = seq
                seq_id = line[1:]
                seq = ""
            else:
                seq += line
        if seq_id is not None:
            seqs[seq_id] = seq
    return seqs



def count_n(seq):
    return seq.count("N") + seq.count("n")

def remove_seqs_with_high_n(seqs, max_n_percent):
    to_remove = []
    for seq_id, seq in seqs.items():
        n_count = count_n(seq)
        n_percent = n_count / len(seq) * 100
        if n_percent > max_n_percent:
            to_remove.append(seq_id)
    for seq_id in to_remove:
        del seqs[seq_id]

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python remove_high_n_seqs.py <input_file> <max_n_percent>")
        sys.exit(1)

    input_file = sys.argv[1]
    max_n_percent = float(sys.argv[2])

    seqs = read_fasta(input_file)
    remove_seqs_with_high_n(seqs, max_n_percent)

    for seq_id, seq in seqs.items():
        print(f">{seq_id}")
        print(seq)