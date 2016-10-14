#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 5 || exit 1

DT=$1
label=$2
H=${3}

for ID in `find $H -maxdepth 0 -type d -name "*"`; do
	tmpdir=$H/$ID/$DT-$ID
done

tmpdir=$H/$ID/$DT-$ALGNAME-raxml
mkdir -p $tmpdir
S=raxml
in=$DT-$ALGNAME
boot="-b $RANDOM"
s="-p $RANDOM"
dirn=raxmlboot.$in.$label

cp $H/$ID/$in.fasta $tmpdir/$in.fasta

cd $tmpdir
pwd
mkdir logs


test "`head -n 1 $in.phylip`" == "0 0" && exit 1

if [ "$DT" == "FAA" ]; then
	if [ -s bestModel.$ALGNAME ]; then
		model=PROTGAMMA`sed -e "s/.* //g" bestModel.$ALGNAME`
	else
		echo model selection failed. check the log file
		exit 1
	fi
	submodel=$(sed -e "s/.* //g" bestModel.$ALGNAME)
else
	model=GTRGAMMA
	submodel=DNA
fi


while read i; do 
	g=$(cat $i/supergene.part | wc -l); 
	if [ $g -gt 1 ]; then 
	while read x; do 
		l=$(echo $x | awk '{print $2}' | sed -e "s/binning_50//"); 
		newmodel=$(cat $l*/*-raxml/bestModel* | sed -e "s/.* //g"); 
		p=$(echo $x | awk '{print $2}'); 
		y=$(basename $p);  
		h=$(echo $x | awk '{print $3,$4}'); 
		printf "$newmodel, $y $h\n"; 
	done < $i/supergene.part; fi; 
done < running_replicates.txt

for at in "${a[@]}"; do 
	mkdir binning_$at; 
	for x in `find */*-raxml/raxml*/RAxML_bestTree.best.addPoly.rooted.final.fasttree.rerooted`; do 
		lf=$(absp .);
		y=$(dirname $x); 
		z=$(basename $x); 
		k=$(dirname $y | sed -e 's/-raxml/.fasta/'); 
		f=$(dirname $k); 
		mkdir binning_$at/$f/; 
		cp $x binning_$at/$f; 
		cp $k binning_$at/$f/$f.fasta; 
	done; 
	mkdir binning_$at/pairwise_output_dir; 
	mkdir binning_$at/running_dir; 
	#source ~/.dendropy3/venv/bin/activate; 
	a=$(cd binning_$at/running_dir; $BINNING_HOME/makecommands.compatibility.sh  $lf/binning_$at/  50 $lf/binning_$at/pairwise_output_dir RAxML_bestTree.best.addPoly.rooted.final.fasttree.rerooted; ); 
	cat commands.compat."$at".*_$at* | xargs -P 5 -I@ sh -c "@"; 
	b=$(cd binning_$at/pairwise_output_dir; ls| grep -v ge|sed -e "s/.$at$//g" > genes; python $BINNING_HOME/cluster_genetrees.py genes); 
	echo $b; 
	mkdir supergenes_output_directory;   
	$BINNING_HOME/build.supergene.alignments.sh $lf/binning_$at/pairwise_output_dir $lf/binning_$at $lf/binning_$at/supergenes_output_directory; 
done

for x in `find supergenes_output_directory -maxdepth 1 -name "bin*"`; do 
	line=$(cat $x/supergene.part  |wc -l); 
	if [ $line -gt "1" ]; then  
		while read  y; do 
			p=$(echo $y | awk '{print $2}'); 
			seq=$(echo $y | awk '{print $3,$4}'); 
			b=$(echo $p | sed -e "s/binning_$at//g" | sed -e 's/\/\/*/\//g'); 
			model=$(find $b*/*-raxml -name "bestModel*"); 
			bas=$(basename $p);
			M=$(cat $model | sed -e 's/.* //'); 
			printf "$M, $bas $seq\n"; 
		done < $x/supergene.part > $x/supergene.part.partitioned;  
	fi
done

for x in `find supergenes_output_directory/ -maxdepth 1 -type d -name "bin*"`; do 
	line=$(cat $x/supergene.part | wc -l); 
	if [ "$line" -gt "1" ]; then 
		h=$(absp .); 
		b=$(basename $x); 
		p=$(dirname $h);  
		printf "$WS_HOME/insects/runraxml-bestML-binning.sh supergene FAA $b partitioned $p/supergenes_output_directory/ 4\n";
	 fi 
done >> ~/tasks/tasks.massive-Insects-long-branch-filtering-binning-bestML-partitioned-new

for x in `find  . -maxdepth 2 -name supergene.part | sort`; do 
	g=$(cat $x | wc -l); 
	if [ "$g" -eq "1" ]; then 
		h=$(dirname $x); 
		mkdir -p $h/supergene-raxml/raxmlboot.supergene.partitioned; 
		y=$(cat $x); 
		rm $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned; 
		cp ../../$y/*-raxml/raxmlb*/RAxML_bestTree.best.addPoly $h/supergene-raxml/raxmlboot.supergene.partitioned/RAxML_bestTree.best.partitioned; 
	fi
done

for x in `find . -maxdepth 1 -type d -name "bin*" | sort `; do 
	g=$(cat $x/supergene.part | wc -l); 
	for i in `seq 1 $g`; do 
		cat $x/sup*/raxml*/RAxML_bestTree.best.partitioned >> filtered_10sites_50taxa_with_long_branch_filtering_binning_50_partitioned.gene_trees.trees; 
	done
done
