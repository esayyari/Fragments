#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 9 || exit 1

ALGNAME=$1
DT=$2
CPUS=1
ID=$3
label=$4
rep=$5
rapid=$6 # use rapid for rapid bootstrapping or anything else for default
H=${7}
st=$8
bs=$9

OMP_NUM_THREADS=1
L=/oasis/scratch/comet/esayyari/temp_project/Insects
cd $L
tmpdir=$L/$H/$ID/$DT-$ALGNAME-raxml
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

$DIR/convert_to_phylip.sh $in.fasta $in.phylip

test "`head -n 1 $in.phylip`" == "0 0" && exit 1
$DIR/listRemovedTaxa.py $in.phylip listRemoved.txt
if [ "$DT" == "FAA" ]; then
        raxmlHPC  -s $in.phylip -f j -b $RANDOM -n BS -m PROTGAMMAJTT -# 2
else
        raxmlHPC  -s $in.phylip -f j -b $RANDOM -n BS -m  GTRGAMMA -# 2
fi
if [ -s "$in.phylip.reduced" ]; then
	mv $in.phylip.reduced $in.phylip
fi
rm RAxML_info.BS

if [ "$DT" == "FAA" ]; then
	if [ -s bestModel.$ALGNAME ]; then
		echo bestModel.$ALGNAME
	else
		rm -r modelselection
		mkdir modelselection
		cd modelselection
		ln -s ../$in.phylip .
		perl $DIR/ProteinModelSelection.pl $in.phylip > ../bestModel.$ALGNAME
		cd ..
		test -s bestModel.$ALGNAME && ( tar cfj modelselection-logs.tar.bz --remove-files modelselection/ )
	fi
	
	if [ -s bestModel.$ALGNAME ]; then
		model=PROTGAMMA`sed -e "s/.* //g" bestModel.$ALGNAME`
	else
		echo model selection failed. check the log file
		exit 1
	fi
	ftmodel=""
else
	model=GTRGAMMA
	ftmodel="-gtr -nt "
fi

mkdir $dirn
cd $dirn


#Figure out if main ML has already finished
donebs=`grep "Overall execution time" RAxML_info.best`
#Infer ML if not done yet
if [ "$donebs" == "" ]; then
	rm RAxML*best.back
	rename "best" "best.back" *best
	if [ "$st" == "fasttree" ]; then
		test -s fasttree.tre || { fasttree $ftmodel ../$in.phylip > fasttree.tre 2> ft.log; }
		test $? == 0 || { cat ft.log; exit 1; }
		python $DIR/arb_resolve_polytomies.py fasttree.tre
		startingtree="-t fasttree.tre.resolved"
	else
		startingtree=""
	fi
	
	raxmlHPC -m $model -n best -s ../$in.phylip $s -N 10 &> ../logs/best_std.errorout.$in
fi
 
#Figure out if bootstrapping has already finished
donebs=`grep "Overall Time" RAxML_info.ml`
#if [ -s RAxML_bootstrap.all ] && [ -s RAxML_bootstrap.back.all ]; then
#	di=$(diff <(sort RAxML_bootstrap.back.all) <(sort RAxML_bootstrap.all))
#	if [ "$di" != "" ]; then
#		cat RAxML_bootstrap.all >> RAxML_bootstrap.back.all
#		mv RAxML_bootstrap.back.all RAxML_bootstrap.all
#	else
#		rm RAxML_bootstrap.back.all
#	fi

#Bootstrap if not done yet
	# if bootstrapping is partially done, resume from where it was left
tar xfj bootstrap-reps.tbz $in.phylip.BS$bs
fasttree $ftmodel $in.phylip.BS$bs > fasttree.tre.BS$bs 2> ft.log.BS$bs;
test $? == 0 || { cat ft.log.BS$bs; exit 1; }
python $DIR/arb_resolve_polytomies.py fasttree.tre.BS$bs
raxmlHPC -F -t fasttree.tre.BS$bs.resolved -m $model -n ml.BS$bs -s $in.phylip.BS$bs -N 1  $s &> $tmpdir/logs/ml_std.errout."$bs"."$in"
test $? == 0 || { echo in running RAxML on bootstrap trees; exit 1; }
rm $in.phylip.BS$bs*
tar rvf bootstrap-files.tar --remove-files *BS$bs *BS$bs.*


