#!/bin/bash
DIR=$( cd $(dirname ${BASH_SOURCE[0]}) && pwd )
echo "USAGE: $0 directory sequencetype suffix outdirecotry sitepercentsfile taxapercentsfile #bootstrap_rep"
#test $# == 7 || echo please enter all the inputs && exit 1

dir=$1
DT=$2
suffix=$3
outdir=$4
sitepercents=$5
taxapercents=$6
rep=$7
tmp=`mktemp listOfFiles.XXXXX`
if [ -s $DT-statReport.jobs ]; then	
	rm $DT-statReport.jobs
fi
if [ -s $DT-fragmentaryFiltering.jobs ]; then
	rm $DT-fragmentaryFiltering.jobs
fi
if [ -s $DT-MLBS-FastTree.jobs ]; then
	rm $DT-MLBS-FastTree.jobs
fi

for x in `find $dir -maxdepth 1 -mindepth 1 -type d -name "[0-9]*"`; do
	y=$(basename $x);
	if [ $DT == "FNA" ]; then
		printf "$DIR/generate_fragmentary_stat.sh $outdir $y $DT genes.$y.fragAdded  \n " >> $DT-statReport.jobs
		printf "$DIR/gc-stats.py $outdir/$y/$DT-genes.$y.fragAdded.fasta $DT $outdir/$y/$DT-genes.$y.fragAdded.gc-stats.stat \n " >> $DT-statReport.jobs
		echo genes.$y.fragAdded >> $tmp
	fi
done 

while read x; do
	while read y; do
		while read line; do
			if [ $DT == "FNA" ]; then
				ID=$(echo $line | sed -e 's/.*genes\.\([0-9]*\)\.fragAdded.*/\1/')
			fi
			printf "$DIR/mask-for-gt.sh $outdir $ID $DT $line $y $x \n " 
			linet="$line"-mask${y}sites.mask${x}taxa
			printf "$DIR/runraxml-fasttreeboot.sh $linet $DT $ID tre $rep fasttree $outdir \n" >> $DT-MLBS-fasttree.jobs
			printf "$DIR/runraxml-bestML.sh $linet $DT $ID tre-raxml $outdir 1\n" >> $DT-bestML-raxml.jobs
		done < $tmp
	done < $sitepercents
done < $taxapercents  > $DT-fragmentaryFiltering.jobs
sed -i '/^$/d' $DT-fragmentaryFiltering.jobs
rm $tmp
