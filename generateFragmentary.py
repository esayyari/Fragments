#! /usr/bin/env python

import sys
import random
import re

random.seed(22841)





def generateFragSeq(infoList):
	geneFileName = infoList[0][4]
	g = open(geneFileName, 'r')
	l = g.readline()
	l = l.replace("\n","")
	l = re.sub(r"\s\s+", " ", l)
	seqLen = int(l.split(" ")[1])
	wholeFile = dict()
	for n, seq in enumerate(g, 1):
		seq = seq.replace("\n","")
		seq = re.sub(r"\s\s+", " ", seq)
		seq.strip()
		t = seq.split(" ")
		wholeFile[t[0]] = t[1] 
		seqLen = len(t[1])
	g.close()
	h = open(geneFileName + ".fragmentary",'w')
	k = open(geneFileName + ".fragmentary.info",'w')
	l = len(infoList)
	print >> h, str(l) + "  " + str(seqLen)	
	for info in infoList:

		(newrepID, newgeneID, frag,  taxonID, geneFileName) = info
		fragNum = int(seqLen * frag)
		indices = random.sample(range(0, seqLen - 1), fragNum)
		seq = wholeFile[taxonID]
		print >> h, taxonID + "      "
		for pos in sorted(indices):
			seq = seq[:pos] + '-' + seq[pos+1:]	 	
		print >> h, "@" + seq 
		print >> k, frag, fragNum, seq.count('-') 
		print >> k, info[0], info[1], info[4]
	k.close()
	h.close()

paramFileName = sys.argv[1]
origpath = sys.argv[2]
origfilename = sys.argv[3]
#outfilename = sys.argv[4]
oldrepID = -2
oldgeneID = -2
f = open(paramFileName, 'r')
infoList = list()
allLines = f.readlines()
for num in range(1,len(allLines)):
	line = allLines[num]
	tmpLine = line.split(",")
	newrepID = tmpLine[0]
	newrepID = newrepID.zfill(2)
	newgeneID = tmpLine[1]
	newgeneID = newgeneID.zfill(3)
	frag = float(tmpLine[7])
	geneFileName = origpath + "/" + newrepID + "/" + origfilename + newgeneID
	taxonID = tmpLine[4]

	if num == 1:
		oldgeneID = newgeneID
		oldrepID = newrepID
	if newgeneID == oldgeneID and newrepID == oldrepID and num != len(allLines) - 1:
		info = (newrepID, newgeneID, frag,  taxonID, geneFileName)		
		infoList.append(info)
	elif num == len(allLines) - 1:
		info = (newrepID, newgeneID, frag,  taxonID, geneFileName)
		infoList.append(info)
		generateFragSeq(infoList)
	else:
		generateFragSeq(infoList)
		infoList = list()
		info = (newrepID, newgeneID, frag,  taxonID, geneFileName)
		infoList.append(info)
		oldgeneID = newgeneID
		oldrepID = newrepID
f.close()
