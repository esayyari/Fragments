#!/usr/bin/env python
import sys

def readRoots(rootFile):
        f = open(filename,'r')
        ROOT = list()
        for line in f:
                line = line.replace("\n","")
                tmpRoot =  line.split(" ")
                ROOT.append(tmpRoot)
        return ROOT
if __name__ == "__main__":
		 
	filename = sys.argv[1]
	ROOT = readRoots(filename)
	for line in ROOT:
		for l in line:
			print l,
		print
