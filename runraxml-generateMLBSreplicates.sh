#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

test $# == 6 || exit 1

ALGNAME=$1
DT=$2
ID=$3
label=$4
rep=$5
H=${6}

OMP_NUM_THREADS=1
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
	model=PROTGAMMALG
	ftmodel=""
else
	model=GTRGAMMA
	ftmodel="-gtr -nt "
fi

mkdir $dirn
cd $dirn

crep=$rep
raxmlHPC -f j -s ../$in.phylip -n BS -m $model $boot -N $crep	
mv ../$in.phylip.BS* .
tar cfj bootstrap-reps.tbz --remove-files $in.phylip.BS*
