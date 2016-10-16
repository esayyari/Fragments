#!/bin/bash

site=$1
taxa=$2
work_dir=$3
DT=$4
path=$5
version=$(basename $(find $WS_HOME/ASTRAL -name "astral.*jar"))
mkdir -p $work_dir
if [ -s $DT-runASTRAL.jobs ]; then
	rm $DT-runASTRAL.jobs
fi
while read y; do
	while read x; do
		mkdir -p $work_dir/$DT-mask"$y"sites.mask"$x"taxa
		cat $path/*/$DT*mask"$y"sites.mask"$x"taxa/$DT*mask"$y"sites.mask"$x"taxa/fasttree.tre.best.addPoly.rooted.final > $work_dir/$DT-mask"$y"sites.mask"$x"taxa/$DT-mask"$y"sites.mask"$x"taxa.gene_trees.trees
		sed -i 's/e_\([0-9]\)/e-\1/g' $work_dir/$DT-mask"$y"sites.mask"$x"taxa/$DT-mask"$y"sites.mask"$x"taxa.gene_trees.trees
		z=$work_dir/$DT-mask"$y"sites.mask"$x"taxa/$DT-mask"$y"sites.mask"$x"taxa.gene_trees.trees
		printf "java -jar $WS_HOME/ASTRAL/$version -i $z -o $work_dir/$DT-mask"$y"sites.mask"$x"taxa/$DT-mask"$y"sites.mask"$x"taxa.species_tree.trees > $work_dir/$DT-mask"$y"sites.mask"$x"taxa/$DT-mask"$y"sites.mask"$x"taxa.species_tree.trees.log 2>&1 \n" >> $DT-runASTRAL.jobs
	done < $taxa
done < $site
