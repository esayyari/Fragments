#!/bin/bash

site=$1
taxa=$2
work_dir=$3
DT=$4
path=$5
suffix=$6
version=$(basename $(find $WS_HOME/ASTRAL -name "astral.*jar"))
test $# -eq 6 || { echo "USAGE: <site> <taxa> <workdir> <DT> <path> <suffix>" && exit 1;}
mkdir -p $work_dir
if [ -s $DT-runASTRAL.jobs ]; then
	rm $DT-runASTRAL.jobs
fi
if [ -s $suffix ]; then
while read y; do
	while read x; do
		while read h; do
			mkdir -p $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h
			cat $path/*/$DT*mask"$y"sites.mask"$x"taxa$h/$DT*mask"$y"sites.mask"$x"taxa$h/fasttree.tre.best.addPoly.rooted.final > $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.gene_trees.trees
			sed -i 's/e_\([0-9]\)/e-\1/g' $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.gene_trees.trees
			z=$work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.gene_trees.trees
			printf "java -jar $WS_HOME/ASTRAL/$version -i $z -o $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.species_tree.trees > $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sitesx.mask"$x"taxa$h.species_tree.trees.log 2>&1 \n" >> $DT-runASTRAL.jobs
		done < $suffix
	done < $taxa
done < $site
else
while read y; do
        while read x; do
			h=""
                        mkdir -p $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h
                        cat $path/*/$DT*mask"$y"sites.mask"$x"taxa$h/$DT*mask"$y"sites.mask"$x"taxa$h/fasttree.tre.best.addPoly.rooted.final > $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.gene_trees.trees
                        sed -i 's/e_\([0-9]\)/e-\1/g' $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.gene_trees.trees
                        z=$work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.gene_trees.trees
                        printf "java -jar $WS_HOME/ASTRAL/$version -i $z -o $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sites.mask"$x"taxa$h.species_tree.trees > $work_dir/$DT-mask"$y"sites.mask"$x"taxa$h/$DT-mask"$y"sitesx.mask"$x"taxa$h.species_tree.trees.log 2>&1 \n" >> $DT-runASTRAL.jobs
        done < $taxa
done < $site
fi
