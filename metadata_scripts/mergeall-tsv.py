import glob
import pandas as pd
import numpy as np

# Combines all tsvs with the same fields in a given folder and dedups based on desired column

tsvnameinput = input("Enter desired tsv combined name: ")
dedupon = input("What value (e.g EPI_ISL)to dedup df on: ")

extension = 'tsv'
all_filenames = [i for i in glob.glob('*.{}'.format(extension))]

#combine all files in the list
combined_csv = pd.concat([pd.read_csv(f,sep ='\t') for f in all_filenames ])

combined_csv = combined_csv.drop_duplicates(subset=dedupon, keep="first")

#export to csv
combined_csv.to_csv( tsvnameinput , index=False, sep='\t')