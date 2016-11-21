#!/usr/bin/env python


import pandas as pd

filename = 'fragmentary_augmented.csv'
table = pd.read_csv(filename)

filename = 'parameters.csv'
#REP GENE BTAXA BLEN STAXA SLEN GENEID FRAG
sample = pd.read_csv(filename)
print sample.columns
sample['REP']
for i in range(1,51):
	taxa = sample[sample['REP'] == i]['BTAXA'].values[:]
	gene = sample[sample['REP'] == i]['GENEID'].values[:]
	for j in range(0,len(taxa)):
		print table[(table['ID'] == gene[j])][taxa[j]].values[0] - sample[sample['REP'] == i]['FRAG'].values[j]


