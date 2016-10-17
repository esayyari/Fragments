#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 7 || exit 1

ALGNAME=$1
DT=$2
CPUS=1
ID=$3
label=$4
rep=$5
rapid=$6 # use rapid for rapid bootstrapping or anything else for default
H=${7}
OMP_NUM_THREADS=1
tmpdir=`mktemp -d`
S=raxml
in=$DT-$ALGNAME
if test "$rapid" == "rapid"; then boot="-x $RANDOM"; else boot="-b $RANDOM"; fi
s="-p $RANDOM"
dirn=raxmlboot.$in.$label

cp $H/$ID/$in/$in.fasta $tmpdir/$in.fasta

cd $tmpdir
pwd
mkdir logs

$DIR/convert_to_phylip.sh $in.fasta $in.phylip
test "`head -n 1 $in.phylip`" == "0 0" && exit 1

if [ "$DT" == "FAA" ]; then
  	ftmodel=""
  	model=PROTGAMMAJTT
else
  	model=GTRGAMMA
  	ftmodel="-gtr -gamma -nt"
fi

mkdir $dirn
cd $dirn

#Figure out if main ML has already finished
donebs=`grep "Overall execution time" ft.log.best`
#Infer ML if not done yet

$DIR/listRemovedTaxa.py ../$in.phylip ../listRemoved.txt
if [ "`cat fasttree.tre.BS-all |wc -l`" -ne "$rep" ]; then

  	crep=$rep
  	# if bootstrapping is partially done, resume from where it was left
	rm RAxML_info.BS

	rm fast*.BS* #RAxML*.ml.BS*
  	rnd=$RANDOM
  
	raxmlHPC  -s ../$in.phylip -f j -b $rnd -n BS -m $model -# $crep
	if [ -s "../$in.phylip.reduced" ]; then
		mv ../$in.phylip.reduced ../$in.phylip
		rm ../*BS*
		rm ../*BS
		rm ../RAxML_info.BS
		rm *BS*
		rm RAxML*BS
		raxmlHPC  -s ../$in.phylip -f j -b $rnd -n BS -m $model -# $crep

	fi
	mv ../$in.phylip.BS* .
fi

for bs in `seq 0 $(( crep - 1 ))`; do
	cat $in.phylip.BS$bs >> $in.phylip.BS-all
done
if [ "$donebs" == "" ]; then
 # Estimate the fasttree best tree
	$DIR/fasttree $ftmodel ../$in.phylip > fasttree.tre.best 2> ft.log.best
fi
 

if [ $rep == 0 ]; then
	mv logs-best.tar.bz logs-best.tar.bz.back.$RANDOM
	tar cvfj logs-best.tar.bz --remove-files fasttree.tre.best ft.log.best
	if [ -s fasttree.tre.best ]; then
		cd ..
		echo "Done">.done.best.$dirn
		exit 0
	fi
	exit 1
fi

#Figure out if bootstrapping has already finished
#Bootstrap if not done yet

   
$DIR/fasttree $ftmodel -n $crep $in.phylip.BS-all > fasttree.tre.BS-all 2> ft.log.BS-all;  
test $? == 0 || { cat ft.log.BS-all; exit 1; }


 
if [ ! `wc -l fasttree.tre.BS-all |sed -e "s/ .*//g"` -eq $rep ]; then
	echo `pwd`>>$H/notfinishedproperly
	exit 1
else
 #Finalize
	sed -i "/^$/d" ../listRemoved.txt
	sed -i "s/'//g" fasttree.tre.best
	sed -i "s/'//g" fasttree.tre.BS-all
	if [ -s "../listRemoved.txt" ]; then
		$DIR/addIdenticalTaxa.py fasttree.tre.best fasttree.tre.best.addPoly ../listRemoved.txt
		sed -i 's/-/_/g' fasttree.tre.best.addPoly
		$DIR/addIdenticalTaxa.py fasttree.tre.BS-all fasttree.tre.BS-all.addPoly ../listRemoved.txt
		sed -i 's/-/_/g' fasttree.tre.BS-all.addPoly
	else
		cp fasttree.tre.best fasttree.tre.best.addPoly
		cp fasttree.tre.BS-all fasttree.tre.BS-all.addPoly
	fi	
	sed -i "s/'//g" fasttree.tre.best.addPoly
	sed -i "s/'//g" fasttree.tre.BS-all.addPoly
	tmptmp=fasttree.tre.best.addPoly
	rt=$(nw_labels -I $tmptmp | head -n 1)
	sed -i 's/e_\([0-9]\)/e-\1/g' fasttree.tre.best.addPoly
	sed -i 's/e_\([0-9]\)/e-\1/g' fasttree.tre.BS-all.addPoly
	nw_reroot fasttree.tre.best.addPoly $rt > fasttree.tre.best.addPoly.rooted
	nw_reroot fasttree.tre.BS-all.addPoly $rt > fasttree.tre.BS-all.addPoly.rooted
	nw_support -p fasttree.tre.best.addPoly.rooted fasttree.tre.BS-all.addPoly.rooted >> fasttree.tre.best.addPoly.rooted.final
# raxmlHPC -f b -m $model -n final -z fasttree.tre.BS-all.resolved -t fasttree.tre.best

	mkdir -p $H/$ID/$in/$DT-$ALGNAME
	cp $tmpdir/$dirn/fasttree.tre.best.addPoly.rooted.final $H/$ID/$in/$DT-$ALGNAME/
	cp $tmpdir/$dirn/ft.log.BS-all $H/$ID/$in/$DT-$ALGNAME/
	
	tar cfj $H/$ID/$in/$DT-$ALGNAME-genetrees.tar.bz.$rnd $tmpdir 
	
	cd $H/$ID/$in/$DT-$ALGNAME
	echo "Done">.done.$dirn
fi
#rm -r $tmpdir
