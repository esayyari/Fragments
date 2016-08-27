#!/bin/bash
set -x
DIR=$WS_HOME/ASTRAL

version=$(find $DIR -maxdepth 1 -name "astral*.jar"| sed -e 's/.*\///')
file=$1
y=$(dirname $file)
b=$(basename $file)
sp=$(basename $file | sed -e 's/gene_trees.trees/species_tree.trees/')
tmpdir=`mktemp -d`;
cd $tmpdir
echo $tmpdir
java -jar $DIR/$version -i $file -o $sp 2>$sp.log.info
check=$(test "`grep ";" $sp | wc -l`" -eq "1" && echo Done  || echo ERROR)
echo $check >> $sp.log.info
tar czvf $y/$sp.tar.gz $tmpdir/*
rm -r $tmpdir

 
