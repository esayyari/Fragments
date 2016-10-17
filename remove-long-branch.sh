#!/bin/bash

#set -e
#set -x

H=${1}
DT=$2
y=$3 # mask10sites.mask33taxa 
med=$4
method=$5
rep=$6
test $# == 6 || { echo "USAGE: <PATH> <DT> <SUFFIX> <MED THR> <METHOD avg, or med> <#replicates>" && exit 1;}
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

filter=$y
mkdir $DT-$filter-$med-$method
cd $DT-$filter-$med-$method
if [ -s list-filter-lb-$med-$method-$y ]; then
	rm list-filter-lb-$med-$method-$y
fi
if [ -s $y.gene_trees.trees ]; then	
	rm $y.gene_trees.trees
fi
if [ -s $y.list.IDs ]; then
	rm $y.list.IDs
fi
for ID in `find $H -maxdepth 1 -mindepth 1 -type d -name "[A-Za-z0-9]*" | sort`; do
	ID=$(basename $ID)
	mkdir -p $H/$ID/$DT-$ID-$y-$med-$method-filtered-long-branch/$DT-$ID-$y-$med-$method-filtered-long-branch/
	cp $H/$ID/$DT-$ID-$y/$DT-$ID-$y.fasta $H/$ID/$DT-$ID-$y-$med-$method-filtered-long-branch/$DT-$ID-$y-$med-$method.fasta;
	echo "$H/$ID/$DT-$ID-$y-$med-$method-filtered-long-branch/$DT-$ID-$y-$med-$method.fasta" >> list-filter-lb-$med-$method-$y
	cat $H/$ID/$DT-$ID-$y/$DT-$ID-$y/fasttree.tre.best.addPoly.rooted.final >> $y.gene_trees.trees
	echo "$ID" >> $y.list.IDs
done 
sed -i 's/e_\([0-9]\)/e-\1/g' $y.gene_trees.trees
python $DIR/root-nw_friendly.py $y.gene_trees.trees
python $DIR/find-long-branches.py $y.gene_trees.trees.rerooted $med $method> filter-lb-$med-$method-$y


paste  <(cat list-filter-lb-$med-$method-$y) <(cat  filter-lb-$med-$method-$y  | tr '\n' ';' | sed -e 's/;;/\n/g' |  sed -e 's/: [^;]*;//' | sed -e 's/[0-9.]*;/ /g'  | sed -e 's/ [0-9.]*$//' | sed -e 's/  / /g' | tr ' ' ',')  | grep -v ":" | sed -e 's/\t/ /g'  | sed -e 's/ [0-9]*,/ /' | awk '{print $1,$2}' > rem-lb-$med-$method-$y.t

cat rem-lb-$med-$method-$y.t | awk -va=$DIR '{print a"/remove_taxon_from_fasta.sh",$1,$2}' > rem-lb-$med-$method-$y
rm rem-lb-$med-$method-$y.t
if [ -s "$DT-gene_tree_estimation" ]; then
	rm $DT-gene_tree_estimation
fi
while read x; do
	b=$(cat rem-lb-$med-$method-$y | grep  "$x")
	if [ "$b" == "" ]; then
		echo "cp $H/$x/$DT-$x-$y/$DT-$x-$y/fasttree.tre.best.addPoly.rooted.final $H/$x/$DT-$x-$y-$med-$method-filtered-long-branch/$DT-$x-$y-$med-$method-filtered-long-branch/; cp $H/$x/$DT-$x-$y-$med-$method-filtered-long-branch/$DT-$x-$y-$med-$method.fasta $H/$x/$DT-$x-$y-$med-$method-filtered-long-branch/$DT-$x-$y-$med-$method-filtered-long-branch.fasta " >> rem-lb-$med-$method-$y.t; 
	else
		printf "$DIR/runraxml-fasttreeboot.sh $x-$y-$med-$method-filtered-long-branch $DT $x tre $rep fasttree $H \n" >> $DT-gene_tree_estimation
		echo "$b > $H/$x/$DT-$x-$y-$med-$method-filtered-long-branch/$DT-$x-$y-$med-$method-filtered-long-branch.fasta" >> rem-lb-$med-$method-$y.t
	fi

done < $y.list.IDs 

mv rem-lb-$med-$method-$y.t rem-lb-$med-$method-$y

