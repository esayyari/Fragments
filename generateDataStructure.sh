#!/bin/bash
DIR=$( cd $(dirname ${BASH_SOURCE[0]}) && pwd )
echo USAGE: directory sequencetype suffix outdirecotry sitepercentsfile taxapercentsfile
test $# == 6 || exit 1

dir=$1
DT=$2
suffix=$3
outdir=$4
taxapercents=$6
sitepercents=$5
tmp=`mktemp listOfFiles.XXXXX`
if [ -s $DT-listOfStatReportTasks ]; then	
	rm $DT-listOfStatReportTasks
fi
if [ -s $DT-listOfFilteringTasks ]; then
	rm $DT-listOfFilteringTasks
fi
for x in `find $dir -maxdepth 1 -mindepth 1 -type d -name "[A-Za-z0-9]*"`; do
	y=$(basename $x);
	mkdir -p $outdir/$y
	#cp $dir/$y/$y"."$suffix $outdir/$y/$DT-$y.fasta
	if [ $DT == "FNA" ]; then
		$DIR/remove_3rd_codon_nt_fas.sh -i $outdir/$y/$DT-$y.fasta 
		printf "$DIR/generate_fragmentary_stat.sh $outdir $y"-rm-3rdCodon" $DT \n " >> $DT-listOfStatReportTasks
		printf "$DIR/gc-stats.py $outdir/$y/$DT-$y-rm-3rdCodon.fasta \n " >> $DT-listOfStatReportTasks
		echo $y"-rm-3rdCodon" >> $tmp
	else
		printf "$DIR/generate_fragmentary_stat.sh $outdir $y $DT \n " >> $DT-listOfStatReportTasks
		echo $y >>  $tmp
	fi
done 

while read x; do
	while read y; do
		while read line; do
			printf "$DIR/mask-for-gt.sh $outdir $line $DT $line $y $x \n "  
		done < $tmp
	done < $sitepercents
done < $taxapercents  > $DT-listOfFilteringTasks
sed -i '/^$/d' $DT-listOfFilteringTasks
rm $tmp	







