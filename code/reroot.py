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

def root (rootgroup, tree, c):
    root = None
    bigest = 0
    oldroot = tree.seed_node
    for n in tree.postorder_node_iter():
        if n.is_leaf():
            n.r = c.get(n.taxon.label) in rootgroup or n.taxon.label in rootgroup
            n.s = 1
        else:
            n.r = all((a.r for a in n.child_nodes()))
            n.s = sum((a.s for a in n.child_nodes()))
        if n.r and bigest < n.s:
            bigest = n.s
            root = n
    if root is None:
        return None
    #print "new root is: ", root.as_newick_string()
    newlen = root.edge.length/2 if root.edge.length else None
    tree.reroot_at_edge(root.edge,length1=newlen,length2=newlen,suppress_unifurcations=False)
    '''This is to fix internal node labels when treated as support values'''
    while oldroot.parent_node != tree.seed_node and oldroot.parent_node != None:
        oldroot.label = oldroot.parent_node.label
        oldroot = oldroot.parent_node
        if len(oldroot.sister_nodes()) > 0:
            oldroot.label = oldroot.sister_nodes()[0].label
    tree.suppress_unifurcations()
    return root

def readRoots(rootFile):
	f = open(rootFile,'r')
	ROOT = list()
	for line in f:
		line = line.replace("\n","")
		tmpRoot =  line.split(" ")
		ROOT.append(tmpRoot)
	return ROOT
def main(*arg):
    treeName = arg[0]
    rootDef =  arg[1]
    annotation = arg[2]
    if len(arg) == 4:
        resultsFile=arg[3]
    else:
        resultsFile="%s.%s" % (treeName, "rerooted")
    c={}
    for x in open(annotation):
	x.replace("\n","")
        c[x.split('\t')[0]] = x.split('\t')[1][0:-1]
    trees = dendropy.TreeList.get_from_path(treeName,'newick',rooting="force-rooted", preserve_underscores=True)
    ROOTS = readRoots(rootDef) 
    for i,tree in enumerate(trees):
	roots = ROOTS
        while roots and root(roots[0],tree, c) is None:
	    roots = roots[1:]
        if not roots:
            print "Tree %d: none of the root groups %s exist. Leaving unrooted." %(i," or ".join((" and ".join(a) for a in ROOTS)))
    print "writing results to " + resultsFile        
    trees.write(path=resultsFile,schema='newick',suppress_rooting=True,suppress_leaf_node_labels=False, unquoted_underscores=True)
if __name__ == '__main__':

    if len(sys.argv) < 4: 
        print "USAGE: treefile rootDef annotation [output]"
        sys.exit(1)
    treeName = sys.argv[1]
    rootDef = sys.argv[2]
    annotation = sys.argv[3]
    if len(sys.argv ) == 5:
        resultsFile=sys.argv[4]
    else:
        resultsFile="%s.%s" % (treeName, "rerooted")
    
    c={}
    for x in open(annotation):
        c[x.split('\t')[0]] = x.split('\t')[1][0:-1]
    trees = dendropy.TreeList.get_from_path(treeName,'newick',rooting="force-rooted",preserve_underscores=True)
    ROOTS = readRoots(rootDef) 
    for i,tree in enumerate(trees):
	roots = ROOTS
        while roots and root(roots[0],tree, c) is None:
	    roots = roots[1:]
        if not roots:
            print "Tree %d: none of the root groups %s exist. Leaving unrooted." %(i," or ".join((" and ".join(a) for a in ROOTS)))
    print "writing results to " + resultsFile        
    trees.write(path=resultsFile,schema='newick',suppress_rooting=True,suppress_leaf_node_labels=False, unquoted_underscores=True)
