#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

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
tmpdir=$H/$ID/$DT-$ALGNAME-raxml
mkdir -p $tmpdir
S=raxml
in=$DT-$ALGNAME
test $rapid == "rapid" && boot="-x $RANDOM" || boot="-b $RANDOM"
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
rm *BS*
rm RAxML_info.BS
rm RAxML*BS


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
RAxML_bestTree.gene_tree.trees  RAxML_bootstrap.all.addPoly.rooted

donebs=`grep ";" RAxML_bestTree.best | wc -l`
#donebs=`grep "Overall execution time" RAxML_info.best`
#Infer ML if not done yet
if [ "$donebs" -ne "1" ]; then
	rm RAxML*best.back
	rename "best" "best.back" *best
	raxmlHPC -m $model -n best -s ../$in.phylip $s -N 10
fi

#Figure out if bootstrapping has already finished
donebs=`grep ";" RAxML_bootstrap.all | wc -l`
#Bootstrap if not done yet
if [ "$donebs" -ne "$rep" ]; then
	crep=$rep
	# if bootstrapping is partially done, resume from where it was left
	if [ `ls RAxML_bootstrap.ml*|wc -l` -ne 0 ]; then
		l=`cat RAxML_bootstrap.ml*|wc -l|sed -e "s/ .*//g"`
		crep=`expr $rep - $l`
	fi
	if [ -s RAxML_bootstrap.ml ]; then
		cp RAxML_bootstrap.ml RAxML_bootstrap.ml.$l
	fi
	rename "ml" "back.ml" *ml
	rm RAxML_info.ml
	if [ $crep -gt 0 ]; then
		raxmlHPC  -m $model -n ml -s ../$in.phylip -N $crep $boot $s &> $tmpdir/logs/ml_std.errout.$in
	fi
fi
if [ ! -s RAxML_bootstrap.all ] || [ `cat RAxML_bootstrap.all|wc -l` -ne $rep ]; then
	cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all
fi

if [ ! `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -eq $rep ]; then
	echo `pwd`>>$H/../notfinishedproperly
	exit 1
else
 
#Finalize
	doneml=`grep ";" RAxML_bestTree.best.addPoly.rooted.final | wc -l`;
	if [ "$doneml" -ne "1" ]; then
		sed -i "/^$/d" ../listRemoved.txt
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
		nw_support -p RAxML_bestTree.best.addPoly.rooted RAxML_bootstrap.all.addPoly.rooted >> RAxML_bestTree.best.addPoly.rooted.final
# raxmlHPC -f b -m $model -n final -z fasttree.tre.BS-all.resolved -t fasttree.tre.best
		tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.best.RUN.* RAxML_bootstrap.ml RAxML_result.best.RUN.*RAxML_bootstrap.ml*
		cd ..
		echo "Done">.done.$dirn
	fi
fi
