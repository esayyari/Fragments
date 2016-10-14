#!/usr/bin/env python


import sys

filename = sys.argv[1]
out = sys.argv[2]
f=open(filename,'r')
dictTaxa = dict()
dictGene = dict()
for line in f:
	line=line.replace("\n","")
	spLine = line.split(" ")
	if spLine[0].isdigit():
		continue
	dictTaxa[spLine[0]] = spLine[1]
f.close()
gene = list()
listKey = sorted(dictTaxa.keys())
for i in range(0,len(listKey)):
	key = listKey[i]
	tmp = map(None,dictTaxa[key])
	gene.append(tmp)
#gene = zip(*gene)
#idx= list()
#for i in range(0,len(gene)):
#	if set(gene[i]) == {"-"}:
#		print "found all -"
#		idx.append(i)
#gene = [i for j, i in enumerate(gene) if j not in idx]
#gene = zip(*gene)
dictToRem = dict()
for i in range(0,len(gene)):
	key = listKey[i]
	g = "".join(gene[i])
	if g in dictGene:
		if dictGene[g] in dictToRem:
			dictToRem[dictGene[g]].append(key)
		else:
			dictToRem[dictGene[g]] = list()
			dictToRem[dictGene[g]].append(key)
	else:
		dictGene[g] = key
o = open(out,'w')
for key in dictToRem:
	print >> o,key,
	for v in dictToRem[key]:
		print >> o, v,
print >> o
