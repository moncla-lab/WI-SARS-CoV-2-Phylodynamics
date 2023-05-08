# script takes the output of iqtree_fordict and makes it formatted for use in dictionary
# usage: python iqtree_dictreverse.py input.txt out.txt
# LD 2023-5

import sys

intxt = sys.argv[1]
outtxt = sys.argv[2]
                
with open(intxt, 'r') as f_in:
    with open(outtxt, 'w') as f_out:
        for line in f_in:
            line = line.strip()
            if ' -> ' in line:
                before, after = line.split(' -> ')
                new_line = after.strip() + '\' : \'' + before.strip()
            else:
                new_line = line
            new_line = "'" + new_line + "',"
            f_out.write(new_line + '\n')
