# script to extract name changes to use in dictionary change for tree vis
# usage: python iqtree_fordict.py logfile > log_out.txt
import sys

logfile = sys.argv[1]


with open(logfile, "r") as file:
    # Initialize a flag variable
    warning_found = False

    # Loop through each line in the file
    for line in file:
        # If the line contains the warning message, set the flag to True
        if "WARNING: Some sequence names are changed as follows:" in line:
            warning_found = True
        # If the flag is True and the line is not blank, print the line
        elif warning_found and line.strip():
            print(line.strip())
        # If the flag is True and the line is blank, exit the loop
        elif warning_found and not line.strip():
            break
