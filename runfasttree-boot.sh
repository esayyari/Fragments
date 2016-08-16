#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 7 || exit 1
ALIGNAME=$1
ID=$2
path=$3
label=$4
repnum=$5
reppartiallen=$6
randomraxml=$7
tmpdir=`mktemp -d`
$rep=$(( repnum * reppartiallen ))
$repstart=$(( repnum * reppartiallen - reppartiallen + 1 ))
$repend=$(( repnum * reppartiallen )) 
in=$ALGNAME
s="-p $randomraxml"
dirn=fasttreboot."$in"."$label".start_"$repstart".end_"$repend".randomraxml_"$randomraxml"

cp $path/$ID/$ALIGNAME $tmpdir/$ALIGNAME

cd $tmpdir
pwd
mkdir logs

test "`head -n 1 $ALIGNAME`" == "0 0" && exit 1

model=GTRGAMMA
ftmodel="-nt -quiet -nopr -gamma"

mkdir $dirn
cd $dirn

#Figure out if main ML has already finished
 


#Figure out if bootstrapping has already finished
#Bootstrap if not done yet
  crep=$rep
  # if bootstrapping is partially done, resume from where it was left
  rm RAxML_info.BS
  
  rm fast*.BS* #RAxML*.ml.BS* 
  rnd=$randomraxml
  /usr/bin/raxmlHPC  -s ../$ALIGNAME -f j -b $rnd -n BS -m $model -# $crep
  mv ../$ALIGNAME.BS* .
   
  for bs in `seq $(( repstart - 1)) $(( crep - 1 ))`; do
   cat $ALIGNAME.BS.$bs >> $ALIGNAME.BS-all
  done
  ttrep=$(( repstart - repend ))
  $DIR/fasttree -x $randomftre $ftmodel -n $ttrep $ALIGNAME.BS-all > fasttree.tre.BS-all 2> ft.log.BS-all;  
  test $? == 0 || { cat ft.log.BS-all; exit 1; }


sp=$(head -n 1 $ALIGNAME.BS-all | nw_labels -I -)
if [ ! `grep ";" $ALIGNAME.BS-all | wc -l` -eq $ttrep ]; then

	echo `pwd`>>$path/$ID/notfinishedproperly
	echo "repstart is $repstart, rep end is $repend, $randraxml" >> $path/$ID/notfinishedproperly
	echo "the error is the number of trees is not equal to $ttrep" >> $path/$ID/notfinishedproperly 
	exit 1
fi
while read x; do
		if [ ! `echo $x | nw_labels -I -` -eq "$sp" ]; then
			echo `pwd`>>$path/$ID/notfinishedproperly
		    	echo "repstart is $repstart, rep end is $repend, $randraxml" >> $path/$ID/notfinishedproperly	
			echo "number of species is not constantly equal to $sp" >> $path/$ID/notfinishedproperly
			exit 1
		fi
done < $ALIGNAME.BS-all

 #Finalize 
tar cfj $path/$ID/genetrees.tar.bz.$ALIGNAME.repstart_$repend.repend_$repend.randraxml_$randraxml $tmpdir 
cd $path/$ID/
echo "Done">$path/$ID/done.$ALIGNAME.repstart_$repend.repend_$repend
rm -r $tmpdir
