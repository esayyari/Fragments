import sys
import os
from optparse import OptionParser
class Opt(object):
	def __init__(self, parser):
		(path, root, clades, names, threshold, mode, style, annotation) = parseArgs(parser)
		self.path = path
		self.root = root
		self.clades = clades
		self.names = names
		self.threshold = threshold
		self.mode = mode
		self.style = style
		self.annotation = annotation

		(search, searchthr, searchrooted, searchthrrooted) = searchFiles(self, mode, path, thresh)
		self.search = search
		self.searchthr = searchthr
		self.searchrooted = searchrooted
		self.searchthrrooted = searchthrrooted

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
		if mode != 0 and mode != 1 and mode !=2:
			parser.print_help()
			sys.exit("To summerize species tree use 0, and to ummerize gene trees use 1. To do GC-stat analysis use 2")

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
	def searchFiles(self, mode, path, thresh):
		if mode == 0:
			search = path + '/*/' + 'estimated_species_tree.tree'
			searchthr = path + '/*/' + 'estimated_species_tree.tree.' + str(thresh)
			searchrooted = path + '/*/' + 'estimated_species_tree.tree' + '.rerooted'
			searchthrrooted = path + '/*/' + 'estimated_species_tree.tree.' + str(thresh) + '.rerooted'
		elif mode == 1:
			search = path + '/*/*/' + 'estimated_gene_trees.tree'
			searchthr = path + '/*/*/' + 'estimated_gene_trees.tree.' + str(thresh)
			searchrooted = path + '/*/*/' + 'estimated_gene_trees.tree' + '.rerooted'
			searchthrrooted = path + '/*/*/' + 'estimated_gene_trees.tree.' + str(thresh) + '.rerooted'
		elif mode == 2:
			search = path + '/*/orig_alignments.fasta'
			searchthr = None
			searchrooted = None
			searchthrrooted = None
		return (search, searchthr, searchrooted, searchthrrooted)
			
	
