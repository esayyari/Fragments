import glob
import os
import dendropy
import sys
import os.path

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
def remove_edges_from_tree(*arg):

    treeName = arg[0]
    t = 75 if len(arg) < 2 else float(arg[1])
    resultsFile="%s.%s" % (treeName,t) if len(arg) < 4 or arg[3]=="-" else arg[2]
    #print "outputting to", resultsFile
    strip_internal=True if len(arg) > 4 and ( arg[3]=="-strip-internal" or arg[3]=="-strip-both" ) else False
    strip_bl=True if len(arg) > 4 and ( arg[3]=="-strip-bl" or arg[3]=="-strip-both" ) else False

    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    filt = lambda edge: False if (edge.label is None or (is_number(edge.label) and float(edge.label) >= t)) else True
    for tree in trees:
        for n in tree.internal_nodes():
            if n.label is not None:
                n.label = float (n.label)
                n.edge.label = n.label
                #print n.label
                #n.label = round(n.label/2)
        edges = set(tree.edges(filt))
        print >>sys.stderr, len(edges), "edges will be removed"
        for e in edges:
            e.collapse()
        if strip_internal:
            for n in tree.internal_nodes():
                n.label = None
        if strip_bl:
            for e in tree.get_edge_set():
                e.length = None

        #tree.reroot_at_midpoint(update_splits=False)

    trees.write(file = open(resultsFile,'w'),schema='newick', suppress_rooting=True)

def concatenateFiles(outFile, search):
	searchFiles = " ".join(glob.glob(search))
	with open(outFile, 'a') as outfile:
		for fname in searchFiles.split(" "):
			with open(fname) as infile:
				for line in infile:
					outfile.write(line)

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


def reroot(*arg):
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



