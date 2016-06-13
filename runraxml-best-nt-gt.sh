#!/bin/bash

set -x

#module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

test $# == 3 || exit 1

in=$1
DT=GTRGAMMA
CPUS=1
bestN=10
filter=$2
thirdcodon=$3
rep=0
st="" # Start tree, use fasttree for FastTree or anything else for default
OMP_NUM_THREADS=$CPUS
if [ "$filter" == 1 ]; then
	if [ "$thirdcodon" == "1" ]; then
		$WS_HOME/1kpscripts/filter_remove_gappyTaxa_nt_fas.sh -i $in;  
		$WS_HOME/1kpscripts/remove_3rd_codon_nt_fas.sh -i $in-filtered50;
		f=$in-filtered50-rm-3rdCodon	
	else
		$WS_HOME/1kpscripts/filter_remove_gappyTaxa_nt_fas.sh -i $in;
		f=$in-filtered50
	fi
else
	if [ "$thirdcodon" == "1" ]; then

		$WS_HOME/1kpscripts/remove_3rd_codon_nt_fas.sh -i $in;
		f=$in-rm-3rdCodon
	else
		f=$in
	fi
fi
S=raxml
s="-p $RANDOM"
tttt=$(basename $in)
dirn=raxmlboot.$tttt
out=$(dirname $in)
dirInT=`mktemp -d`
dirIn=`mktemp -d $dirInT/$tttt.XXXXX`
echo $dirIn
cd $dirIn
mkdir logs
mkdir $dirn
$DIR/convert_to_phylip.sh $f $f.phylip
test "`head -n 1 $f.phylip`" == "0 0" && exit 1

if [ "$DT" == "FAA" ]; then
  if [ -s bestModel.$ALGNAME ]; then
    echo bestModel.$ALGNAME exists
  else
    rm -r modelselection
    mkdir modelselection
    cd modelselection
    ln -s ../$f.phylip .
    perl $DIR/ProteinModelSelection.pl $f.phylip > ../bestModel.$ALGNAME
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
  ftmodel="-gtr -nt"
fi

cd $dirn


#Figure out if main ML has already finished
donebs=`grep "Overall execution time" RAxML_info.best`
#Infer ML if not done yet
if [ "$donebs" == "" ]; then
 rename "back" "back.`date +%s`"  RAxML*best.back
 rename "best" "best.back.`date +%s`" *best
 # Estimate the RAxML best tree
 if [ "$st" == "fasttree" ]; then
   test -s fasttree.tre || { $DIR/fasttree $ftmodel ../$f.phylip > fasttree.tre 2> ft.log; }
   test $? == 0 || { cat ft.log; exit 1; }
   python $DIR/arb_resolve_polytomies.py fasttree.tre
   startingtree="-t fasttree.tre.resolved"
 else
   startingtree=""
 fi
 if [ $CPUS -gt 1 ]; then
  /usr/bin/time -po ../logs/best.time.info raxmlHPC-PTHREADS -m $model -T $CPUS -n best -s $f.phylip $s -N $bestN $startingtree &> ../logs/best_std.errout.$tttt
 else
  /usr/bin/time -po ../logs/best.time.info raxmlHPC -m $model -n best -s $f.phylip $s -N $bestN $startingtree &> ../logs/best_std.errout.$tttt
 fi
fi


if [ $rep == 0 ]; then
   mv logs-best.tar.bz logs-best.tar.bz.back.$RANDOM
   tar cvfj $out/logs-best.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.* RAxML_*back*  RAxML_result.best.* ../*
   if [ -s RAxML_bestTree.best ]; then
    cd ..
    echo "Done">.done.best.$dirn
    exit 0
   fi
   exit 1
fi
