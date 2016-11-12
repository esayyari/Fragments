#!/bin/bash

set -x


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# -eq 6 || exit 1

ALGNAME=$1
DT=$2
CPUS=$6
ID=$3
label=$4
H=${5}

OMP_NUM_THREADS=1
tmpdir=$H/$ID/$ALGNAME-raxml
mkdir -p $tmpdir
S=raxml
in=$ALGNAME
boot="-b $RANDOM"
s="-p $RANDOM"
dirn=raxmlboot.$in.$label

cp $H/$ID/$in.fasta $tmpdir/$in.fasta
cp $H/$ID/$in.part.partitioned $tmpdir/
cd $tmpdir
pwd
mkdir logs

$DIR/convert_to_phylip.sh $in.fasta $in.phylip

test "`head -n 1 $in.phylip`" == "0 0" && exit 1
$DIR/listRemovedTaxa.py $in.phylip listRemoved.txt
#if [ "$DT" == "FAA" ]; then
#        raxmlHPC  -s $in.phylip -f j -b $RANDOM -n BS -m PROTGAMMAJTT -# 2
#else
#        raxmlHPC  -s $in.phylip -f j -b $RANDOM -n BS -m  GTRGAMMA -# 2
#fi
#if [ -s "$in.phylip.reduced" ]; then
#	mv $in.phylip.reduced $in.phylip
#fi
rm RAxML_info.BS

if [ "$DT" == "FAA" ]; then
	if [ -s supergene.part.partitioned ]; then
		echo bestModel.$ALGNAME
	else
		echo model selection failed. check the log file
		exit 1
	fi
	model=PROTGAMMALG
	ftmodel=""
else
	model=GTRGAMMA
fi

mkdir $dirn
cd $dirn


#Figure out if main ML has already finished
donebs=`grep "Overall execution time" RAxML_info.best`
#Infer ML if not done yet
if [ "$donebs" == "" ]; then
	rm RAxML*best.back
	rename "best" "best.back" *best.partitioned
	if [ $CPUS -eq 1 ]; then	
		raxmlHPC -O -m $model -M -q ../supergene.part.partitioned -n best.partitioned -s ../$in.phylip $s -N 10 &> ../logs/best_std.errorout.$in
	else
		raxmlHPC-PTHREADS -O -T $CPUS -M -m $model -q ../supergene.part.partitioned -n best.partitioned -s ../$in.phylip $s -N 10 &> ../logs/best_std.errorout.$in
	fi
fi
 
#Figure out if bootstrapping has already finished
sed -i "s/'//g" RAxML_bestTree.best.partitioned
sed -i "s/e_\([0-9]\)/e-\1/g" RAxML_bestTree.best.partitioned
sed -i "/^$/d" ../listRemoved.txt
if [ -s "../listRemoved.txt" ]; then
	$DIR/addIdenticalTaxa.py RAxML_bestTree.best.partitioned RAxML_bestTree.best.addPoly ../listRemoved.txt
	sed -i 's/-/_/g' RAxML_bestTree.best.addPoly
else
	cp RAxML_bestTree.best.partitioned RAxML_bestTree.best.addPoly
fi	
tar cvfj bestML-files.tar.bz --remove-files RAxML_log.* RAxML_result.best.partitioned.RUN*   RAxML_parsimonyTree.best.partitioned.RUN.*
cd ..
echo "Done">.done.$dirn
