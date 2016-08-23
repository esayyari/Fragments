#!/bin/bash

set -x

module load python

DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")"  && pwd )

test $# == 8 || exit 1
ALIGNAME=$1
ID=$2
GENEID=$3
path=$4
label=$5
repnum=$6
reppartiallen=$7
randomraxml=$8
rep=$(( repnum * reppartiallen ))
repstart=$(( repnum * reppartiallen - reppartiallen + 1 ))
repend=$(( repnum * reppartiallen )) 
in=$ALIGNAME
s="-p $randomraxml"
dirn=fasttreboot."$in"."$label".start_"$repstart".end_"$repend".randomraxml_"$randomraxml"


tmpdir=`mktemp -d`
ls $path/$ID/$GENEID/$ALIGNAME
cp $path/$ID/$GENEID/$ALIGNAME $tmpdir/$ALIGNAME
cp $path/$ID/$GENEID/$GENEID.fas $tmpdir/$GENEID.fas
maxLen=$(cat $tmpdir/$GENEID.fas | wc -L)

sed -i 's/_0_0//g' $tmpdir/$ALIGNAME
cd $tmpdir
pwd
mkdir logs

test "`head -n 1 $ALIGNAME`" == "0 0" && exit 1

model=GTRGAMMA
ftmodel="-nt -nopr -gamma"

mkdir $dirn
cd $dirn

#Figure out if main ML has already finished
 


#Figure out if bootstrapping has already finished
#Bootstrap if not done yet
crep=$rep
  # if bootstrapping is partially done, resume from where it was left
if [ -s RAxML_info.BS ]; then
	  rm RAxML_info.BS	
fi
if [ -s fast*.BS* ]; then
	rm fast*.BS*
fi
rnd=$randomraxml
raxmlHPC  -s ../$ALIGNAME -f j -b $rnd -n BS -m $model -# $crep
mv ../*.BS* .
if [ "$maxLen" -lt "5000" ]; then
  	for bs in `seq $(( repstart - 1)) $(( crep - 1 ))`; do
		
   		cat "$ALIGNAME".BS"$bs" >> "$ALIGNAME".BS-all
  	done
else
	for bs in `seq $(( repstart - 1)) $(( crep - 1 ))`; do
		cat "$ALIGNAME".BS"$bs" | tail -n +2 | sed -e 's/^/>/'| sed -e 's/ $//' | sed -e 's/ \+/ /g' | tr ' ' '\n' | grep -e "[>A-Za-z0-9]" > "$GENEID".fas.BS$bs
	done
	
fi


if [ "$maxLen" -lt "5000" ]; then
  	ttrep=$(( repend -repstart  + 1 ))
  	$DIR/fasttree $ftmodel -n $ttrep $ALIGNAME.BS-all > fasttree.tre.BS-all 2> ft.log.BS-all;  
  	test $? == 0 || { cat ft.log.BS-all; exit 1; }
else
  	for bs in `seq $(( repstart - 1)) $(( crep - 1 ))`; do
		$DIR/fasttree -nt -nopr -gamma "$GENEID"*fas*BS"$bs" > fasttree.tre.BS$bs 2>ft.log.BS$bs;
		test $? == 0 || { cat ft.log.BS$bs; exit 1; }
  	done
  	cat fasttree.tre.BS* > fasttree.tre.BS-all
  	cat ft.log.BS* >  ft.log.BS-all
  	rm fasttree.tre.BS[0-9]*
  	rm ft.log.BS[0-9]*
fi



sp=$(head -n 1 fasttree.tre.BS-all | nw_labels -I - | wc -l)
if [ ! `grep ";" fasttree.tre.BS-all | wc -l` -eq $ttrep ]; then

	echo `pwd`>>$path/$ID/$GENEID/notfinishedproperly
	echo "repstart is $repstart, rep end is $repend, $randraxml" >> $path/$ID/$GENEID/notfinishedproperly
	echo "the error is the number of trees is not equal to $ttrep" >> $path/$ID/$GENEID/notfinishedproperly 
	exit 1
fi
while read x; do
		if [ ! `echo $x | nw_labels -I - | wc -l` -eq "$sp" ]; then
			echo `pwd`>>$path/$ID/$GENEID/notfinishedproperly
		    	echo "repstart is $repstart, rep end is $repend, $randraxml" >> $path/$ID/$GENEID/notfinishedproperly	
			echo "number of species is not constantly equal to $sp" >> $path/$ID/$GENEID/notfinishedproperly
			exit 1
		fi
done < fasttree.tre.BS-all

 #Finalize 
tar cfj $path/$ID/$GENEID/genetrees.tar.bz."$ALIGNAME".repstart_"$repstart".repend_"$repend".randraxml_"$randomraxml" $tmpdir 
cd $path/
echo "Done">$path/$ID/$GENEID/done."$ALIGNAME".repstart_"$repend".repend_"$repend".randraxml_"$randomraxml"
rm -r $tmpdir
