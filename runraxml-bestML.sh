#!/bin/bash

set -x

module load python

DIR=$WS_HOME/insects/
echo $DIR
test $# == 6 || exit 1

ALGNAME=$1
DT=$2
CPU=$6
ID=$3
label=$4
H=${5}

OMP_NUM_THREADS=1
tmpdir=$H/$ID/$DT-$ALGNAME-raxml
mkdir -p $tmpdir
S=raxml
in=$DT-$ALGNAME
boot="-b $RANDOM"
s="-p $RANDOM"
dirn=raxmlboot.$in.$label

cp $H/$ID/$DT-$ALGNAME/$in.fasta $tmpdir/$in.fasta

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
	if [ $CPU -ne "1" ]; then
		raxmlHPC-PTHREADS -T $CPU -m $model -n best -s ../$in.phylip $s -N 10 &> ../logs/best_std.errorout.$in
	else
		raxmlHPC -m $model -n best -s ../$in.phylip $s -N 10 &> ../logs/best_std.errorout.$in
	fi
else
	echo "computing bestML was done previousely"	
fi
if [ -s RAxML_bestTree.best.addPoly ]; then
	g=$(cat RAxML_bestTree.best.addPoly | grep ";" | wc -l)
	if [ "$g" -eq 1 ]; then
		echo "bestML was done previousely";
		exit 0;
	fi
fi
#Figure out if bootstrapping has already finished
sed -i "s/'//g" RAxML_bestTree.best
sed -i "s/'//g" RAxML_bootstrap.all
sed -i "/^$/d" ../listRemoved.txt
if [ -s "../listRemoved.txt" ]; then
	$DIR/addIdenticalTaxa.py RAxML_bestTree.best RAxML_bestTree.best.addPoly ../listRemoved.txt
	sed -i 's/-/_/g' RAxML_bestTree.best.addPoly
	sed -i 's/e_\([0-9]\)/e-\1/g' RAxML_bestTree.best.addPoly
else
	cp RAxML_bestTree.best RAxML_bestTree.best.addPoly
fi	
tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.best.RUN.* RAxML_bootstrap.ml RAxML_result.best.RUN.*RAxML_bootstrap.ml*
cd ..
echo "Done">.done.$dirn
