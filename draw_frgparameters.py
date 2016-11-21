#!/usr/bin/env python

import sys
import os
import numpy as np
#average_branch_lengths.csv  fragmentary_augmented.csv  simulated_average_branch_lengths.csv
# np.random.choice(a, size=None, replace=True)
#I've assumed that the actual root is at bNames[0]
#I've assumed that the mapping of outgroups is uniqly defined, also 
#I've assumed that the number of taxa in simulated dataset is 100 (other than outgroup)
#I've assumed that the outgroup in the simulated datasets is the first branch length
	


class ReadAvgBioBranchLengths(object):

	def __init__(self,filepath=""):
		self.__filepath = filepath
		self.__names = list()
		self.__bLength = list()
		self.__root = ""
		self.readTable()

	def readTable(self):
		f = open(self.__filepath, 'r')
		j = 0
		for line in f:
			line = line.replace("\n", "")
			if "taxa" in line:
				continue
			t = line.split(",")
			if j == 0:
				self.__root = t[0]
				j = j + 1
			self.__names.append(t[0])
			self.__bLength.append(t[1])
		f.close()		

	def printTable(self):
		self.readTable()
		for i in range(0,len(self.__names)):
			print self.__names[i],self.__bLength[i]

	def root(self):
		return self.__root

	def names(self):
		return self.__names

	def bLength(self):
		return self.__bLength

class ReadTable(object):
	
	def __init__(self,filepath=""):
		self.__table = dict()
		self.__names = list()
		self.__revTable = dict()
		self.__tableList = dict()
		self.__filepath = filepath
		self.__numRow = 0
		self.__readTaxa()
		self.__readTable()
		self.__readTableAsList()
		self.__readRevTable()
	def __readTaxa(self):
		f = open(self.__filepath, 'r')
		for i, line in enumerate(f):
			if i == 0:
				line = line.replace("\n", "")
				t = line.split(",")
				self.__names = t[1:]
		f.close()


	def __readTableAsList(self):
		f = open(self.__filepath, 'r')
		self.__numRow = 0
		for i, line in enumerate(f):
			self.__numRow = self.__numRow + 1
			line = line.replace("\n", "")
			t = line.split(",")
			if i >0:
				ID = t[0]
				self.__tableList[ID] = t[1:]
		f.close()

	def __readRevTable(self):
		f = open(self.__filepath, 'r')
		for i in self.__names:
			self.__revTable[i] = list()
		for i, line in enumerate(f):
			line = line.replace("\n", "")
			t = line.split(",")
			if i > 0:
				for j in range(1, len(t)):
					tName = self.__names[j-1]
					if t[j] != "NA":
						self.__revTable[tName].append(t[j])
		f.close()
	
	def __readTable(self):
		f = open(self.__filepath, 'r')
		for i, line in enumerate(f):
			line = line.replace("\n", "")
			t = line.split(",")
			if i > 0:
				ID = t[0]
				self.__table[ID] = dict()
				for j in range(1, len(t)):
					tName = self.__names[j-1]
					self.__table[ID][tName] = t[j]
		f.close()
	def printRevTable(self):
		Total = list()
		for t in sorted(list(self.__revTable.keys()), key=lambda v: v.upper()):
			tmp = list()
			tmp.append(t)
			for l in self.__revTable[t]:
				tmp.append(l)
			Total.append(tmp)
		TotalRev = zip(*Total)
		for i in TotalRev:
			for j in i:
				print j,
			print

	def printTableAsList(self):
		print "ID",
		for i in range(0,len(self.__names)):
			print self.__names[i],
		print
		for ID in self.__tableList:
			print ID,
			for i in range(0,len(self.__names)):
				print self.__tableList[ID][i],
			print 

	def printTable(self):
		print "ID",
		for i in range(0,len(self.__names)):
			print self.__names[i],
		print
		for ID in self.__table:
			print ID,
			for i in range(0,len(self.__names)):
				print self.__table[ID][self.__names[i]],
			print

	def names(self):
		return self.__names
	
	def table(self):
		return self.__table

	def revTable(self):
		return self.__revTable

	def root(self):
		return self.__secondColName

	def tableAsList(self):
		return self.__tableList


class ParameterEstimation(object):
	def __init__(self, avgBrLenFile="", fragDataFile="", simBrLengthFile="", seed=32699, numG=1000):

		self.__avgBrLen = ReadAvgBioBranchLengths(avgBrLenFile)
		self.__fragData = ReadTable(fragDataFile)
		self.__simBrLen = ReadTable(simBrLengthFile)

		self.__simNames = self.__simBrLen.names()
		self.__simTable = self.__simBrLen.tableAsList()

		self.__fragTable = self.__fragData.table()
		self.__revFragTable = self.__fragData.revTable()
	
		
		self.__bNames = self.__avgBrLen.names()
		self.__bLength = self.__avgBrLen.bLength()
		self.__bioRoot = self.__avgBrLen.root()
		
		self.__seed = seed
		np.random.seed(self.__seed)

		self.__numG = numG
		self.__sTaxaNum = len(self.__simTable.items()[0][1])
		self.__sRep  = sorted(self.__simTable.keys())
		self.__taxaIDs = range(1, len(self.__bNames))
		self.flag = False
		
		self.__mapBioTaxaSimTaxa = dict()
		self.__table = dict()
		self.__mapBioTaxaSimTaxa = self.mapBioTaxaSimTaxa()
		self.__table = self.table()
		self.flag = True

	def __mapNamesID(self, i):
		# root is always maps to root (self.__sTaxaNum - 1)
		# randomly choose self.__sTaxaNum - 1 taxa from self.__taxaIDs (biological names)
		# I've assumed that the first element of biological names is the root
		selectedBioNameIDs = sorted(np.random.choice(self.__taxaIDs, self.__sTaxaNum-1, replace=False))
		a = len(set(selectedBioNameIDs))
	#	print "here " + str(a)
		if (a != self.__sTaxaNum-1):	
			print "something is wrong"
			print "number of taxa selected is " + str(a) + " not " + str(self.__sTaxaNum-1)
			return 1
		# assumed that the first element of self.__simTable (0) is the root
		tmpSimBrLen = self.__simTable[i][1:]
		# return indices of sorted tmpSimBrLen
		# key defines a function in sortd, which will be executed before sorting, and lambda defines a function on k
		sortedSimBrLenIDs = sorted(range(len(tmpSimBrLen)),key=lambda k: tmpSimBrLen[k])
		# add one to the indices to make them suitable for self.__simTable[i][1:]
		sortedSimBrLenIDs = [ x + 1 for x in sortedSimBrLenIDs ]
		# for self.__mapBioTaxaSimTaxa[i] make a list, will save which elements in biological data maps to simulated
		# The first element is root of biological maps to root of simulated
		# Each element of self.__mapBioTaxaSimTaxa[i] is a tuple (BioName, BioLen, SimName, SimLen)
		self.__mapBioTaxaSimTaxa[i] = list()
		self.__mapBioTaxaSimTaxa[i].append((self.__bioRoot,self.__bLength[0],self.__simNames[0],self.__simTable[i][0]))
		
		for j in range(0,len(sortedSimBrLenIDs)):
			bioTaxaName = self.__bNames[selectedBioNameIDs[j]]
			bioBrLen = self.__bLength[selectedBioNameIDs[j]]
			simBrLen = self.__simTable[i][sortedSimBrLenIDs[j]]
			simTaxaName = self.__simNames[sortedSimBrLenIDs[j]]
			self.__mapBioTaxaSimTaxa[i].append((bioTaxaName, bioBrLen, simTaxaName, simBrLen))

	def __fragSample(self,i):
		# "i" is for each replicate in simulated dataset
		mapping = self.__mapBioTaxaSimTaxa[i]
		# Will make a list of list of tuples for each replicate
		self.__table[i] = list()
		for g in range(0, self.__numG):
			# Choose which Biological Gene data should map to this gene in simulated
			selectedGID = np.random.choice(range(0, len(self.__fragTable.keys())), 1, replace=True)
			selectedG = self.__fragTable.keys()[selectedGID]
			#selectedFragData is a dictionary itself, which stores the fragmentary ration for each taxa in gene selectedG
			selectedFragData = self.__fragTable[selectedG]
			fragInfo = list()
			fragInfo.append((mapping[0][0], mapping[0][1], mapping[0][2], mapping[0][3], selectedG, selectedFragData[mapping[0][0]]))
			for j in range(1,len(mapping)):
				if selectedFragData[mapping[j][0]] != "NA":
					tmpFrag = selectedFragData[mapping[j][0]]
				else:
					tmpFrag = np.random.choice(self.__revFragTable[mapping[j][0]], 1, replace=True)[0]
					
				fragInfo.append((mapping[j][0], mapping[j][1], mapping[j][2], mapping[j][3], selectedG, tmpFrag))
			self.__table[i].append(fragInfo)

	def mapBioTaxaSimTaxa(self):
		for i in self.__simTable.keys():
			self.__mapNamesID(i)
		return self.__mapBioTaxaSimTaxa

	def table(self):
		for i in self.__simTable.keys():
			self.__fragSample(i)
		return self.__table

	def printBioTaxaSimTaxa(self):
		for ID in self.__mapBioTaxaSimTaxa:
			for t in self.__mapBioTaxaSimTaxa[ID]:
				continue
#				print 	ID,t[0],t[1],t[2],t[3]
	def printTable(self):
		for ID in self.__table:
			for g in range(0,self.__numG):
				for t in self.__table[ID][g]:
					print ID, g, t[0], t[1], t[2], t[3], t[4], t[5]
				

	def avgBrLen(self):
		return self.__avgBrLen

	def fragData(self):
		return self.__fragData

	def simBrLen(self):
		return self.__simBrLen

	def seed(self):
		return self.__seed

avgBrLen = ReadAvgBioBranchLengths('average_branch_lengths.csv')
fragData = ReadTable('fragmentary_augmented.csv')
simBrLength = ReadTable('simulated_average_branch_lengths.csv')

#avgBrLen.printTable()
#fragData.printTableAsList()
#fragData.printRevTable()
#fragData.printTable()
#simBrLength.printTableAsList()
#simBrLength.printTable()




	
		
parameter = ParameterEstimation('average_branch_lengths.csv', 'fragmentary_augmented.csv', 'simulated_average_branch_lengths.csv', seed=32699, numG=1000)
#parameter.printBioTaxaSimTaxa()
parameter.printTable()
