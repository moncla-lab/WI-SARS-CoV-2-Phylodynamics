##scripts used for configuring contextual data- both sequences and metadata

# For formatting NCBI virus downloads: 

**if downloaded a large number of seqs and need to subset down, use lambo's python script - randsubsample-fasta.py

Example:
python3 Desktop/project_source/midwest_sars2/metadata_config/randsubsample-fasta.py Downloads/alpha_marchapril21.fasta 10000 Downloads/subset_marchapril21_10k.fasta

Then multi download: 
# #concatenate fastas 
cat *.fasta > output.fasta **CALL THIS wave_seqs_v1.fasta**

# #deduplicate fasta based on headers

seqkit rmdup -n < input.fasta > output_deduped.fasta **CALL THIS wave_seqs_v2.fasta**


--> Jupyter notebook to dedupe on the strain name since that's an issue with augur parse
**UPDATE- this is now a python script**. fasta_dedupe_on_strainname.py

# --> now activate nextstrain shell to do augur parse 


augur parse --sequences sequences.fasta --output-sequences results/sequences_context.fasta --output-metadata results/metadata_context.tsv --fields accession division strain date pango_lin

**CALL THIS output wave_seqs_v3.fasta**

Then open up tsv in text editor and remove all <USA: >

**do that after it got mad at me when I did it before

There are some geolocations that have county, which we need to remove, can do that using this regex in bbedit and replace with nothing:

,(.*?)(?=\t|$)


# After doing this, use ncbi-meta-add-cols script to further mod (adding columns via Jupyter notebook)

**with this script, I've also added code to filter down the fasta file to exclude all seqs that got cut in further refining metadata (i.e. removing MN sequences, removing non-wave sequences, and missing location data)

Put final final into ncov data folder for use for nextstrain builds!!


Example augur parse command input:
augur parse --sequences omicron_more23_deduped.fasta --output-sequences results/omicron_v2.fasta --output-metadata results/metadata_context_omicronv2.tsv --fields accession division strain date pango_lin


