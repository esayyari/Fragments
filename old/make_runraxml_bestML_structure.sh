#!/bin/bash
path=$1
DT=$2
label=$3
site=$4
taxa=$5
suffix=$6
CPU=$7
test $# == 7 || { echo "USAGE: $0 <path> <DT> <label> <site> <taxa> <suffix> <CPUS>" && exit 1; }
if [ -s $DT-raxml-bestML-gene_trees.jobs ]; then
	rm $DT-raxml-bestML-gene_trees.jobs
fi
for id in `find $path -maxdepth 1 -mindepth 1 -type d -name "*" | sort`; do  
	while read y; do
		while read z; do
			ID=$(basename $id);
			H=$path
			if [ -s $suffix ]; then
				while read x; do 
					ALGNAME=$ID-mask"$y"sites.mask"$z"taxa-$x;
					printf "$WS_HOME/insects/runraxml-bestML.sh $ALGNAME $DT $ID $label $H $CPU \n" >> $DT-raxml-bestML-gene_trees.jobs;
				done < $suffix
			else
				ALGNAME=$ID-mask"$y"sites.mask"$z"taxa;
				printf "$WS_HOME/insects/runraxml-bestML.sh $ALGNAME $DT $ID $label $H $CPU \n" >> $DT-raxml-bestML-gene_trees.jobs;
			fi
		done < $taxa
	done < $site
 done 
