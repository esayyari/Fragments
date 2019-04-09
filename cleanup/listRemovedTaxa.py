#!/usr/bin/env python


import sys

filename = sys.argv[1]
out = sys.argv[2]
f=open(filename,'r')
dictTaxa = dict()
dictGene = dict()
allLines = f.readlines()
for line in allLines[1:]:
	line=line.replace("\n","")
	spLine = line.split(" ")
	#if spLine[1].isdigit():
	#	continue
	dictTaxa[str(spLine[0])] = spLine[1]
f.close()
gene = list()
listKey = sorted(dictTaxa.keys())
for i in range(0,len(listKey)):
	key = listKey[i]
	tmp = map(None,dictTaxa[key])
	gene.append(tmp)
dictToRem = dict()



for i in range(0,len(gene)):
	key = listKey[i]
	g = "".join(gene[i])
	g=g.strip()
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
#	print >> o,key,
#	print "here"
	string = key +" " + " ".join(dictToRem[key])
	print >> o, string
#	for v in dictToRem[key]:
#		print >> o, v,
#		print v
#	print >> o
