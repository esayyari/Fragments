#!/bin/bash
path=$1
DT=$2
label=$3
site=$4
taxa=$5
suffix=$6
CPU=$7
rep=$8
test $# -eq  8 || { echo "USAGE: $0 <path> <DT> <label> <site> <taxa> <suffix> <CPUS> <#replicates>" && exit 1; }
if [ -s $DT-raxml-MLBS-gene_trees.jobs ]; then
	rm $DT-raxml-MLBS-gene_trees.jobs
fi
if [ -s DT-raxml-MLBS-gene_trees_generate.jobs ]; then
	rm DT-raxml-MLBS-gene_trees_generate.jobs
fi
if [ -s $suffix ]; then
	for id in `find $path -maxdepth 1 -mindepth 1 -type d -name "*" | sort`; do  
		while read y; do
			while read z; do
				while read x; do
					ID=$(basename $id); 
					H=$path; 
					ALGNAME=$ID-mask"$y"sites.mask"$z"taxa-$x;
					crep=$(( $rep -1 ))
						
				
					printf "$WS_HOME/insects/runraxml-generateMLBSreplicates.sh $ALGNAME $DT $ID $label $rep $path \n" >> $DT-raxml-MLBS-gene_trees_generate.jobs 
					printf "$WS_HOME/insects/draw_support_on_best_ML.sh $ALGNAME $DT $ID $label $rep $path \n" >> $DT-draw_support.jobs
				for bs in `seq  0 $crep `; do
						printf "$WS_HOME/insects/runraxml-fasttree-start-boostrapping-splitted.sh $ALGNAME $DT $ID $label $H $bs $CPU \n" >> $DT-raxml-MLBS-gene_trees.jobs;
					done
				done < $suffix
			done < $taxa
		done < $site
	 done 
else
	for id in `find $path -maxdepth 1 -mindepth 1 -type d -name "*" | sort`; do
		while read y; do
			while read z; do
				ID=$(basename $id);
				H=$path;
				ALGNAME=$ID-mask"$y"sites.mask"$z"taxa;
				crep=$(( $rep -1 ))
				
				printf "$WS_HOME/insects/runraxml-generateMLBSreplicates.sh $ALGNAME $DT $ID $label $rep $path \n" >> $DT-raxml-MLBS-gene_trees_generate.jobs
				for bs in `seq  0 $crep `; do
					printf "$WS_HOME/insects/runraxml-fasttree-start-boostrapping-splitted.sh $ALGNAME $DT $ID $label $H $bs $CPU \n" >> $DT-raxml-MLBS-gene_trees.jobs;
				done
			done < $taxa
		done < $site
	 done
fi
