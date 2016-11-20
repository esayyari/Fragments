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

	def print(self):
		self.readTable(self)
		for (i in range(0,len(self.__names))):
			print self.__names[i],self.__bLength[i]

	def root(self):
		return self.__root

	def names(self):
		return self.__names

	def brLength(self):
		return self.__bLength

class ReadTable(object):
	
	def __init__(self,filepath=""):
		self.__table = dict()
		self.__names = list()
		self.__revTable = dict()
		self.__tableList = dict()
		self.__filepath = filepath
		self.__numRow = 0
	
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
					if t[j] is not "NA":
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
					self.__table[ID][tName] = t[j-1]
		f.close()

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
		self.__readTaxa(self)
		return self.__names
	
	def table(self):
		self.__readTaxa(self)
		self.__readTable(self)
		return self.__table

	def revTable(self):
		self.__readTaxa(self)
		self.__readRevTable(self)
		return self.__revTable

	def root(self):
		self.readTaxa(self)
		return self.__secondColName

	def tableAsList(self):
		self.__readTaxa(self)
		self.__readTableAsList(self)
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

		self.__mapBioTaxaSimTaxa = dict()
		self.__table = dict()
		
		self.__seed = seed
		np.random.seed(self.__seed)

		self.__numG = numG
		self.__sTaxaNum = len(self.__simTable.items()[0][1])
		self.__sRep  = self.__simTable.keys()
		self.__taxaIDs = range(1, len(self.__bNames))

	def __mapNamesID(self, i):
		selectedBioNameIDs = sorted(np.random.choice(self.__taxaIDs,self.__sTaxaNum-1,replace=False))
		tmpSimBrLen = self.__simTable[i][1:]
		sortedSimBrLenIDs = sorted(range(len(tmpSimBrLen)),key=lambda k: tmpSimBrLen[k])
		sortedSimBrLenIDs = [ x + 1 for x in sortedSimBrLenIDs ]
		self.__mapBioTaxaSimTaxa[i] = list()
		self.__mapBioTaxaSimTaxa[i].append(self.__bioRoot,self.__brLength[0],self.__simNames[0],self.__simTable[i][0])
		
		for j in range(0,len(sortedSimBrLenIDs)):
			bioTaxaName = self.__bNames[selectedBioNameIDs[j]]
			bioBrLen = self.__bLength[selectedBioNamesIDs[j]]
			simBrLen = self.__self.__simTable[i][sortedSimBrLenIDs[j]]
			simTaxaName = self.__simNames[sortedSimBrLenIDs[j]]
			self.__mapBioTaxaSimTaxa[i].append(bioTaxaName, bioBrLen, simTaxaName, simBrLen)

	def __fragSample(self,i):
		mapping = self.__mapBioTaxaSimTaxa[i]
		self.__table[i] = list()
		for g in range(0, self.__numG):
			selectedGID = np.random.choice(range(0, len(self.__fragTable.key())), 1, replace=True)
			selectedG = self.__fragTable.key()[selectedGID]
			selectedFragData = self.__fragTable[selectedG]
			fragInfo = list()
			fragInfo.append((mapping[0][0], mapping[0][1], mapping[0][2], mapping[0][3], selectedFragData[mapping[0][0])
			for j in range(1,len(mapping)):
				if selectedFragData[mapping[j][0]] not "NA":
					tmpFrag = selectedFragData[mapping[j][0]]
				else:
					tmpFrag = np.random.choice(self.__revFragTable[mapping[j][0]], 1, replace=True)
					
				fragInfo.append((mapping[j][0], mapping[j][1], mapping[j][2], mapping[j][3], tmpFrag))
			self.__table[i].append(fragInfo)

	def mapBioTaxaSimTaxa(self):
		for i in self.__simTable.keys():
			self.__mapNamesID(self, i)
		return self.__mapBioTaxaSimTaxa

	def table(self):
		for i in self.__simTable.keys():
			self.__fragSample(self, i)
		return self.__table

	def avgBrLen(self):
		return self.__avgBrLen

	def fragData(self):
		return self.__fragData

	def simBrLen(self):
		return self.__simBrLen

	def seed(self)
		return self.__seed

avgBrLen = ReadAvgBioBranchLengths('average_branch_lengths.csv')
fragData = ReadTable('fragmentary_augmented.csv')
simBrLength = ReadTable('simulated_average_branch_lengths.csv')






	
		
		 
