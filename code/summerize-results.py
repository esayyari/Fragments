#!/usr/bin/env python

import sys
import glob
import os
import re
from optparse import OptionParser
import find_clades 
import reroot
import remove_edges_from_tree
import subprocess
def parseArgs(parser):
	
	(options, args) = parser.parse_args()
	if not options.path:
		parser.print_help()
		sys.exit("please enter the path to the gene directory")

	path = options.path

	if not options.root:
		parser.print_help()
		sys.exit("Please enter the path to the rooting definitions")

	root = options.root
		
	if not options.root:
		parser.print_help()
		sys.exit("Please enther path to the species names file")

	names = options.names

	if not options.clades:
		parser.print_help()
		sys.exit("Please enter the path to clade definitions")

	clades = options.clades
	
	if not options.thresh:
		parser.print_help()
		sys.exit("Please enter the bootstrapping threshold")

	threshold = options.thresh

	path = os.path.expanduser(os.path.expandvars(path))

	if not os.path.exists(path):
		parser.print_help()
		sys.exit("please check the path to the gene direcotry")

	root = os.path.abspath(root)

	if not os.path.isfile(root):
		parser.print_help()
		sys.exit("Please check the path to the rooting definitions")
	
	names = os.path.abspath(names)

	if not os.path.isfile(names):
		parser.print_help()
		sys.exit("Please check the names file")
	clades = os.path.abspath(clades)
	if not os.path.isfile(clades):
		parser.print_help()
		sys.exit("Please check the path to the rooting definitions")

	if float(threshold)<=1.0:
		threshold = float(threshold)
	if not options.mode:
		parser.print_help()
		sys.exit("Please enter the mode. Do you want to summerize the species tree (0), or the gene trees (1)")
	
	mode = int(options.mode)
	if mode != 0 and mode != 1:
		parser.print_help()
		sys.exit("To summerize species tree use 0, and to ummerize gene trees use 1")
	
	if not options.annotation:
		parser.print_help()
		sys.exit("Please enter the annotation file")
	
	annotation = options.annotation
	
	annotation = os.path.expanduser(os.path.expandvars(annotation))

        if not os.path.isfile(annotation):
                parser.print_help()
                sys.exit("Please check the annotation file")
	
	style = options.style
	return (path, root, clades, names, threshold, mode, style, annotation)

if "__main__" == __name__:

	parser = OptionParser()

	parser.add_option("-p", "--path", dest="path",
        	          help="path to the gene directory or species tree")

	parser.add_option("-m", "--mode", dest="mode",
			  help="summerize gene trees or estimated species tree. To summerize species tree use 0, and to summereize gene trees use 1.")

	parser.add_option("-n", "--names" , dest="names",
			  help="names of species")

	parser.add_option("-r", "--rooting",dest="root",
        	          help="The rooting file")

	parser.add_option("-c", "--clades", dest="clades",
			  help="The path to the clades definition file")

	parser.add_option("-t", "--threshold", dest="thresh",
			  help="The bootstrap threshold")

	parser.add_option("-s", "--style", dest="style", type = int, 
			  help="The color style set", default = 0)

	parser.add_option("-o", "--output", dest="outfile",
			  help="The output file")

	parser.add_option("-a", "--annotation", dest="annotation",
			  help="The annotation file")
	(path, root, clades, names, thresh, mode, style, annotation) = parseArgs(parser)
	if mode == 0:
		search = path + '/*/' + 'estimated_species_tree.tree'
		searchthr = path + '/*/' + 'estimated_species_tree.tree.' + str(thresh)

	elif mode == 1:
		search = path + '/*/*/' + 'estimated_gene_trees.tree'
		searchthr = path + '/*/*/' + 'estimated_gene_trees.tree.' + str(thresh)

	outFile = path + "/clades.txt"
	f = open(outFile,'w')
	f.close()
	outFilethr = path + "/clades.hs.txt"
	f = open(outFilethr,'w')
	f.close()
	searchFiles = " ".join(glob.glob(search))

	for tree in searchFiles.split(" "):
		reroot.main(tree, root, annotation)
		remove_edges_from_tree.main(tree, thresh)
	
	searchFilesthr = " ".join(glob.glob(searchthr))
	for tree in searchFilesthr.split(" "):
		reroot.main(tree, root, annotation)

	if mode == 0:
                search = path + '/*/' + 'estimated_species_tree.tree' + '.rerooted'
                searchthr = path + '/*/' + 'estimated_species_tree.tree.' + str(thresh) + '.rerooted'

        elif mode == 1:
                search = path + '/*/*/' + 'estimated_gene_trees.tree' + '.rerooted'
                searchthr = path + '/*/*/' + 'estimated_gene_trees.tree.' + str(thresh) + '.rerooted'

	searchFiles = " ".join(glob.glob(search))
	searchFilesthr = " ".join(glob.glob(searchthr))
	find_clades.main(names, clades, outFile, searchFiles) 
	find_clades.main(names, clades, outFilethr, searchFilesthr)
	f = open(outFile,'r')
	outRes = outFile + ".res"
	oRes = open(outRes, 'w')
	outResthr = outFilethr + ".res"
	oResThr = open(outResthr, 'w')
	oRes.write("ID\tDS\tMONO\tBOOT\tCLADE\n")
	for line in f:
		linet = line.replace("\n","")
		listLine = linet.split("\t")

		b = os.path.basename(os.path.dirname(listLine[0]))
		
		if mode == 1:
                        ID = os.path.basename(os.path.dirname(os.path.dirname(listLine[0])))
                        method = re.sub("^-","",re.split(ID,b)[1])
                else:
                        ID = b
                        tmp = re.split("-", b)
                        method = tmp[len(tmp)-1]

		MONO = listLine[1]
		BOOT = listLine[2]
		CLADE = re.sub("\s+\(.*","", listLine[3])
		oRes.write( "%s\t%s\t%s\t%s\t%s\n" % (ID, method, MONO, BOOT, CLADE))
	f.close()
	oRes.close()
	oResThr.write("ID\tDS\tMONO\tBOOT\tCLADE\n")
	f = open(outFilethr,'r')
	for line in f:
                linet = line.replace("\n","")
                listLine = linet.split("\t")

                b = os.path.basename(os.path.dirname(listLine[0]))
		if mode == 1:
	                ID = os.path.basename(os.path.dirname(os.path.dirname(listLine[0])))
                	method = re.sub("^-","",re.split(ID,b)[1])
		else:
			ID = b
			tmp = re.split("-", b)
			method = tmp[len(tmp)-1]

                MONO = listLine[1]
                BOOT = listLine[2]
                CLADE = re.sub("\s+\(.*","",listLine[3])
                oResThr.write( "%s\t%s\t%s\t%s\t%s\n" % (ID, method, MONO, BOOT, CLADE))
	oResThr.close()
	currPath = os.path.dirname(os.path.abspath(__file__))
	WS_HOME = os.environ['WS_HOME']
	command = 'Rscript'
	path2script = currPath  + "/depict_clades.R"
	(path, root, clades, names, thresh, mode, style, annotation)
	args = ["-p", WS_HOME, "-s", str(mode), "-c", clades, "-i", path]
	stderrFile = path + "/error.log"
	cmd = [command, path2script] + args
	print "printing outputs and errors on " + stderrFile
	print cmd
	proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	stdout, stderr = proc.communicate()
#	x = subprocess.check_output(cmd, universal_newlines=True, stderr=subprocess.STDOUT)
	err = open(stderrFile,'a')
	err.write(stdout)
	err.write(stderr)
	err.close()
	
