#!/usr/bin/env python
import dendropy
import sys

tref = sys.argv[1]
outf = sys.argv[2]
lstf = sys.argv[3]
f = open(tref,'r')

g = open(lstf,'r')
taxa_list = list(list())
for lt in g:
	lt = lt.replace("\n","")
	lt = lt.replace("_","-")
	taxa = lt.split(" ")
	taxa_list.append(taxa)
trees = dendropy.TreeList()
for line in f:
	dictExistNode = dict()
	line = line.replace("\n","")
	line = line.replace("_","-")
	tre = dendropy.Tree.get_from_string(line,"newick")
	for taxa in taxa_list:
		tmp = list()
		for t in taxa:
			filter = lambda taxon: True if taxon.label == t else False
			node = tre.find_node_with_taxon(filter)
			if node is None:
				tmp.append(t)
			else:
				Nd = node
		dictExistNode[Nd] = tmp

	for Nd in dictExistNode:
		for t in dictExistNode[Nd]:
			taxon_1 = dendropy.Taxon(label=t)
			if taxon_1 not in tre.taxon_namespace:
				tre.taxon_namespace.add_taxon(taxon_1)
			# Create a new node and assign a taxon OBJECT to it (not a label)
			n = dendropy.Node(taxon=taxon_1, label=t)
			n.edge.length = Nd.edge.length 
			Nd.parent_node.insert_child(0, n)
	trees.append(tre)
trees.write(
    path=outf,
    schema="newick",suppress_rooting=True)
f.close()
g.close()
# Now this works
