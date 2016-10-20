#!/bin/bash
DIR=$( cd $(dirname ${BASH_SOURCE[0]}) && pwd )
echo "USAGE: $0 directory sequencetype suffix outdirecotry sitepercentsfile taxapercentsfile #bootstrap_rep"
test $# == 7 || exit 1

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
if [ -s $DT-3rdCodonRemoval.jobs ]; then
	rm $DT-3rdCodonRemoval.jobs
fi
for x in `find $dir -maxdepth 1 -mindepth 1 -type d -name "[A-Za-z0-9]*"`; do
	y=$(basename $x);
	mkdir -p $outdir/$y
	cp $dir/$y/$y"."$suffix $outdir/$y/$DT-$y.fasta
	if [ $DT == "FNA" ]; then
		printf "$DIR/remove_3rd_codon_nt_fas.sh -i $outdir/$y/$DT-$y.fasta \n " >> $DT-3rdCodonRemoval.jobs
		printf "$DIR/generate_fragmentary_stat.sh $outdir $y $DT $y"-rm-3rdCodon" \n " >> $DT-statReport.jobs
		printf "$DIR/gc-stats.py $outdir/$y/$DT-$y.fasta $DT $outdir/$y/$DT-$y.gc-stats.stat \n " >> $DT-statReport.jobs
		echo $y"-rm-3rdCodon" >> $tmp
	else
		printf "$DIR/generate_fragmentary_stat.sh $outdir $y $DT $y\n " >> $DT-statReport.jobs
		printf "$DIR/gc-stats.py $outdir/$y/$DT-$y.fasta $DT $outdir/$y/$DT-$y.gc-stats.stat \n " >> $DT-statReport.jobs
		echo $y >>  $tmp
	fi
done 

while read x; do
	while read y; do
		while read line; do
			if [ $DT == "FNA" ]; then
				ID=$(echo $line | sed -e 's/-rm-3rdCodon//')
			else
				ID=$line
			fi
			
			printf "$DIR/mask-for-gt.sh $outdir $ID $DT $line $y $x \n " 
			linet="$line"-mask${y}sites.mask${x}taxa
			printf "$DIR/runraxml-fasttreeboot.sh $linet $DT $ID tre $rep fasttree $outdir \n" >> $DT-MLBS-FastTree.jobs
		done < $tmp
	done < $sitepercents
done < $taxapercents  > $DT-fragmentaryFiltering.jobs
sed -i '/^$/d' $DT-fragmentaryFiltering.jobs
rm $tmp
