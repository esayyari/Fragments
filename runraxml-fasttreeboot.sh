#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 6 || exit 1

ALGNAME=$1
DT=$2
CPUS=1
ID=$3
label=$4
rep=$5
rapid=$6 # use rapid for rapid bootstrapping or anything else for default
OMP_NUM_THREADS=1

S=raxml
in=$DT-$ALGNAME
if test "$rapid" == "rapid"; then boot="-x $RANDOM"; else boot="-b $RANDOM"; fi
s="-p $RANDOM"
dirn=raxmlboot.$in.$label

cd $H/genes/$ID/
mkdir logs

$DIR/convert_to_phylip.sh $in.fasta $in.phylip
test "`head -n 1 $in.phylip`" == "0 0" && exit 1

if [ "$DT" == "FAA" ]; then
  ftmodel=""
else
  model=GTRGAMMA
  ftmodel="-gtr -nt"
fi

mkdir $dirn
cd $dirn

#Figure out if main ML has already finished
donebs=`grep "Overall execution time" ft.log.best`
#Infer ML if not done yet
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
if [ "`cat fasttree.tre.BS-all |wc -l`" -ne "$rep" ]; then

  crep=$rep
  # if bootstrapping is partially done, resume from where it was left
  rm RAxML_info.BS
  
  rm fast*.BS* #RAxML*.ml.BS* 

  raxmlHPC -f j -s ../$in.phylip -n BS -m GTRCAT $boot -N $crep
  mv ../$in.phylip.BS* .
  tar cfj bootstrap-reps.tbz --remove-files $in.phylip.BS*
 
  for bs in `seq 0 $(( crep - 1 ))`; do 

   tar xfj bootstrap-reps.tbz $in.phylip.BS$bs
   cat $in.phylip.BS$bs >> $in.phylip.BS-all
  done
  $DIR/fasttree $ftmodel $in.phylip.BS-all -n $rep > fasttree.tre.BS-all 2> ft.log.BS-all;  
  test $? == 0 || { cat ft.log.BS-all; exit 1; }
  rm $in.phylip.BS$bs*
  tar rvf bootstrap-files.tar --remove-files *BS-all* *BS$bs.*
  gzip bootstrap-files.tar
  rm bootstrap-reps.tbz

fi

 
if [ ! `wc -l fasttree.tre.BS-all |sed -e "s/ .*//g"` -eq $rep ]; then
 echo `pwd`>>$H/notfinishedproperly
 exit 1
else
 #Finalize 
 rename "final" "final.back" *final
 raxmlHPC -f b -m $model -n final -z fasttree.tre.BS-all -t fasttree.tre.best

 if [ -s RAxML_bipartitions.final ]; then
   mv logs.tar.bz logs.tar.bz.back.$RANDOM
   tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.* RAxML_*back* RAxML_bootstrap.ml RAxML_result.best.* RAxML_bootstrap.ml* RAxML_info.final ft.log.* RAxML_info.BS* bootstrap-files.tar*.gz 
   cd ..
   echo "Done">.done.$dirn
 fi
fi

