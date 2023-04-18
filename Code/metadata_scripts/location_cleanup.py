import sys
import pandas as pd 

data = input("Enter tsv file: ")
df = pd.read_csv(data, sep='\t')


city_county = { 'MADISON' : 'DANE',

}

misspells_county = { 'Gren' : '',
}