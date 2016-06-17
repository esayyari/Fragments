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

cp $H/$ID/$in.fasta $tmpdir/$in.fasta

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
   
  for bs in `seq 0 $(( crep - 1 ))`; do
   cat $in.phylip.BS$bs >> $in.phylip.BS-all
  done
#  $DIR/fasttree $ftmodel $in.phylip.BS$bs  > fasttree.tre.BS$bs 2> ft.log.BS$bs;  
  
  $DIR/fasttree $ftmodel -n $crep $in.phylip.BS-all > fasttree.tre.BS-all 2> ft.log.BS-all;  
  python $DIR/arb_resolve_polytomies.py fasttree.tre.BS-all
  #done
#  cat fasttree.tre.BS*.resolved >> fasttree.tre.BS-all.resolved
  #tar cfj bootstrap-reps.tbz $in.phylip.BS*
  test $? == 0 || { cat ft.log.BS-all; exit 1; }
  #rm $in.phylip.BS$bs*
  #tar rvf bootstrap-files.tar --remove-files *BS-all* *BS-all.resolved *BS$bs.*
  #gzip bootstrap-files.tar
  #rm bootstrap-reps.tbz

fi

 
if [ ! `wc -l fasttree.tre.BS-all.resolved |sed -e "s/ .*//g"` -eq $rep ]; then
 echo `pwd`>>$H/notfinishedproperly
 exit 1
else
 #Finalize 
 rename "final" "final.back" *final
 raxmlHPC -f b -m $model -n final -z fasttree.tre.BS-all.resolved -t fasttree.tre.best

   tar cfj $H/$ID/genetrees.tar.bz.$rnd $tmpdir 
   cd $H/$ID/
   cd ..
   echo "Done">.done.$dirn
fi
