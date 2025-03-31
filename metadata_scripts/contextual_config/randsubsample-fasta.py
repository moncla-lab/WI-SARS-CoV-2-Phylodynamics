
# Usage:  python3 input.fasta 1000 output.fasta

import sys
from random import sample
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

def main ():
	seq_file = sys.argv[1]
	num_seqs = int(sys.argv[2])
	subset_file = sys.argv[3]
	   
	seqs = [x for x in SeqIO.parse(seq_file, "fasta")]	
	subsample = sample(seqs, num_seqs)			
	SeqIO.write(subsample, subset_file, "fasta")
							        
									
if __name__ == '__main__':
	main()
