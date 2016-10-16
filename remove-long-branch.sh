#!/bin/bash

set -e
set -x

y=$2 # FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa  FAA-upp-masked.fasta.mask10sites.mask33taxa
dir=$1
med=$3
method=$4
test $# == 4 || { echo "USAGE: < all gene tree path>  <gene tree structure, e.g., FNA-upp-mask10sites.mask33taxa  or FAA-upp-mask10sites.mask33taxa> <standard deviation> <method avg, or med"; exit 1; }

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
searchP=$( echo $1 | sed -e 's/-upp-/-\*/')
ls $2/*/$searchP/*/*/fasttree.tre.best.addPoly.rooted.final > list-$med-$metho-$y
cat $2/*/$searchP/*/*/fasttree.tre.best.addPoly.rooted.final > $y.gene_trees.trees
x=$y.gene_trees.trees

python $DIR/root-nw_friendly.py $x
python $DIR/find-long-branches.py $x.rerooted $med $method> filter-lb-$med-$method-$x

paste <(cat list-$med-$metho-$y) <(cat  filter-lb-$med-$method-$x  | tr '\n' ';' | sed -e 's/;;/\n/g' |  sed -e 's/: [^;]*;//' | sed -e 's/[0-9.]*;/ /g'  | sed -e 's/ [0-9.]*$//' | sed -e 's/  / /g' | tr ' ' ',')  | grep -v ":" | sed -e 's/\t/ /g'  | sed -e 's/ [0-9]*,/ /' | sed -e 's/,/ /g' | awk '{for(i=2;i<=NF;i++){print $1,$i}}' > rem-lb-$med-$method-$x

exit 0;

paste <( ls genes/*/$y.fasta ) <( cat filter-lb-$med-$x |tr  '\n' ';'|tr ':' '\n'|sed -e "s/;;.*$/;/g"|sed -e "s/[^;]*;//"|sed -e "s/ [^;]*;/|/g"|sed -e "s/|$//"|tail -n+2 )   |xargs -n1 echo remove_taxon_from_fasta.sh|sed -e 's/ / "/g' -e 's/,/" /g'| grep -v '""'| awk '{print $0, "> ",$3"-filterbln"}'|sed -e "s/.fasta-filterbln/-filterbln-$med.fasta/g" > rem-lb-$med-$x.sh

bash rem-lb-$med-$x.sh

#set +e

#for f in genes/*; do ln -s $y.fasta $f/$y-filterbln-$med.fasta; done

