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

if [ $g -gt 1 ]; then while read x; do l=$(echo $x | awk '{print $2}' | sed -e "s/binning_50//"); newmodel=$(cat $l*/*-raxml/bestModel* | sed -e "s/.* //g"); p=$(echo $x | awk '{print $2}'); y=$(basename $p);  h=$(echo $x | awk '{print $3,$4}'); printf "$newmodel, $y $h\n"; done <bin.41/supergene.part; fi

