#!/bin/bash

set -x

module load python

DIR=$( cd "$(dirname $0)" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 6 || exit 1

ALGNAME=$1
DT=$2
CPUS=1
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
cd $tmpdir
cd $dirn

k=$(cat RAxML_result.ml | grep ";" | wc -l)	 
if [ "$k" -eq "$rep" ]; then
	cat RAxML_result.ml > RAxML_bootstrap.all
	sed -i "s/'//g" RAxML_bestTree.best
	sed -i "s/'//g" RAxML_bootstrap.all
	sed -i "/^$/d" ../listRemoved.txt
	if [ -s "../listRemoved.txt" ]; then
		$DIR/addIdenticalTaxa.py RAxML_bestTree.best RAxML_bestTree.best.addPoly ../listRemoved.txt
		sed -i 's/-/_/g' RAxML_bestTree.best.addPoly
		$DIR/addIdenticalTaxa.py RAxML_bootstrap.all RAxML_bootstrap.all.addPoly ../listRemoved.txt
		sed -i 's/-/_/g' RAxML_bootstrap.all.addPoly
	else
		cp RAxML_bestTree.best RAxML_bestTree.best.addPoly
		cp RAxML_bootstrap.all RAxML_bootstrap.all.addPoly
	fi	
	sed -i "s/'//g" RAxML_bestTree.best.addPoly
	sed -i "s/'//g" RAxML_bootstrap.all.addPoly
	tmptmp=RAxML_bestTree.best.addPoly
	rt=$(nw_labels -I $tmptmp | head -n 1)
	nw_reroot RAxML_bestTree.best.addPoly $rt > RAxML_bestTree.best.addPoly.rooted
	nw_reroot RAxML_bootstrap.all.addPoly $rt > RAxML_bootstrap.all.addPoly.rooted
	nw_support -p RAxML_bestTree.best.addPoly.rooted RAxML_bootstrap.all.addPoly.rooted > RAxML_bestTree.best.addPoly.rooted.final.fasttree
	rm RAxML*final.RAxML
	model="PROTGAMMALG"
	sed -i 's/e_\([0-9]\)/e-\1/g' RAxML_bootstrap.all.addPoly.rooted
	sed -i 's/e_\([0-9]\)/e-\1/g' RAxML_bestTree.best.addPoly.rooted
	raxmlHPC -f b -m $model -n final.RAxML -z RAxML_bootstrap.all.addPoly.rooted -t RAxML_bestTree.best.addPoly.rooted
	tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.best.RUN.* RAxML_bootstrap.ml RAxML_result.best.RUN.*RAxML_bootstrap.ml*
	cd ..
	echo "Done">.done.$dirn
else
	echo "The number of bootstrapped gene trees is not $rep . There are only $k bootstrapped genes."
	exit 1
fi
