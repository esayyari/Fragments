#!/bin/bash

i=$1
dir=$(dirname $i)
cd $dir
b=$(basename $i)
cat $b  | sed -e 's/^\([0-9][0-9]*  [0-9][0-9]*\)/#\1/'  | tr '\n' '@' | tr '#' '\n'    | sed -e '/^$/d'  > b
split -l1 -da3 b genes.phylip.
sed -i 's/@/\n/g' genes.phylip.*
sed -i '/^$/d' genes.phylip.*
