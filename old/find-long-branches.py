#!/usr/bin/env python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import os
import copy
import os.path

hdir=os.path.dirname(os.path.realpath(__file__))

def mean(data):
    """Return the sample arithmetic mean of data."""
    n = len(data)
    if n < 1:
        raise ValueError('mean requires at least one data point')
    return sum(data)/n # in Python 2 use sum(data)/float(n)

def median(data):
    """Return the sample arithmetic mean of data."""
    n = len(data)
    if n < 1:
        raise ValueError('median requires at least one data point')
    return data[n/2] # in Python 2 use sum(data)/float(n)

def _ss(data):
    """Return sum of square deviations of sequence data."""
    c = mean(data)
    ss = sum((x-c)**2 for x in data)
    return ss

def pstdev(data):
    """Calculates the population standard deviation."""
    n = len(data)
    if n < 2:
        raise ValueError('variance requires at least two data points')
    ss = _ss(data)
    pvar = ss/n # the population variance
    return pvar**0.5
def branchInfo(treeName, outFile, opt):
	c={}
	for x in open(opt.annotate):
	        c[x.split('\t')[0]] = x.split('\t')[2][0:-1]
	trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooting="force-rooted", preserve_underscores=True)
	r = os.path.basename(treeName).split("-")
	mode = ("-".join(r[2:])).replace(".trees","")
	DS = r[0] 
	f = open(outFile,'w')
	for i,tree in enumerate(trees):
	        disrt = [n.distance_from_root() for n in tree.leaf_node_iter()]
        	med = median(disrt)
	        avg = mean(disrt)
        	std = pstdev(disrt)
		
	        string = DS " " + mode + " " + str(i+1) + " " + str(med) + " " + str(avg) + " " + str(std) + "\n"
		f.write(string)
	f.close()
if __name__ == '__main__':

    if len(sys.argv) < 2: 
        print "USAGE: treefile standard_deviation"
        sys.exit(1)

    treeName = sys.argv[1]
    SD=int(sys.argv[2])
    method=sys.argv[3]
    c={}
    for x in open(os.path.join(hdir,"annotate.txt")):
	#print x.split('\t')[2][0:-1]
        c[x.split('\t')[0]] = x.split('\t')[2][0:-1]

    trees = dendropy.TreeList.get_from_path(treeName, 'newick',rooting="force-rooted", preserve_underscores=True)
    for i,tree in enumerate(trees):
        disrt = [n.distance_from_root() for n in tree.leaf_node_iter()]
        med = median(disrt)
	avg = mean(disrt)
        std = pstdev(disrt)
        print i+1,":", med, avg, std, SD * std + med, SD * std + avg
	if method == "med":        
		for n in tree.leaf_node_iter():
        	    if med  + SD * std < n.distance_from_root():
                	print n.taxon.label,  n.distance_from_root()
	        print
	elif method == "avg":
		for n in tree.leaf_node_iter():
                    if avg  + SD * std < n.distance_from_root():
                        print n.taxon.label,  n.distance_from_root()
                print	

    #print "writing results to " + resultsFile        
    #trees.write(open(resultsFile,'w'),'newick',write_rooting=False,suppress_leaf_node_labels=False)
