#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

test $# == 8 || exit 1

ALGNAME=$1
DT=$2
CPUS=1
ID=$3
label=$4
rep=$5
rapid=$6 # use rapid for rapid bootstrapping or anything else for default
H=${7}
st=$8

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
if [ -s RAxML_bootstrap.back.all ] && [ ! -s RAxML_bootstrap.all ]; then
	mv RAxML_bootstrap.back.all RAxML_bootstrap.all
fi

if [ -s RAxML_bootstrap.all ]; then
	donerep=`cat RAxML_bootstrap.all | grep ";" | wc -l`
else
	donerep=0
fi
if [ -s RAxML_bootstrap.all.addPoly ]; then
	donebss=`cat RAxML_bootstrap.all.addPoly | grep ";" | wc -l`
else
	donebss=0
fi
#Bootstrap if not done yet
flag=1
if [ "$donebss" -eq "$rep" ]; then
	echo "bootstrapping was finished previousely";
	flag=2
	exit 0
fi
echo $flag
if [ "$donerep" -ne "$rep" ] && [ "$flag" -ne "2" ]; then 
	crep=$rep
	l=""
	# if bootstrapping is partially done, resume from where it was left
	if [ `cat RAxML_bootstrap.all | grep ";" |  wc -l` -ne 0 ]; then
		l=`cat RAxML_bootstrap.all |grep ";" | wc -l|sed -e "s/ .*//g"`
		crep=`expr $rep - $l`
	fi
	if [ -s RAxML_bootstrap.all ]; then
		cp RAxML_bootstrap.all RAxML_bootstrap.all.$l
	fi
	rename "all" "back.all" *.all
	rm RAxML_info.ml*
	if [ $crep -gt 0 ]; then
		if [ "$l" == "" ] || [ "$l" -eq "0" ]; then
			rm RAxML_info.BS
			$DIR/raxmlHPC -f j -s ../$in.phylip -n BS -m $model $boot -N $crep	
			mv ../$in.phylip.BS* .
			tar cfj bootstrap-reps.tbz --remove-files $in.phylip.BS*
			l=0
		else
			if [ -s RAxML_info.BS ]; then
				seedb=$(cat RAxML_info.BS | grep "raxmlHPC -f j" | grep -oe "-b [0-9]* " | sed -e 's/-b //' | sed -e 's/ //g')
				boot="-b $seedb"
				echo $seedb
			fi
			mkdir bootstraps
			cd bootstraps/
			rm *
			cp ../../$in.phylip .
			#Date=$(date +%Y-%m-%d-%H-%M-%S)
			#mv ../bootstrap-reps.tbz ../bootstrap-reps.old-"$Date".tbz
			$DIR/raxmlHPC -f j -s $in.phylip -n BS -m $model $boot -N $rep
			tar cfj bootstrap-reps.tbz --remove-files $in.phylip*BS*
			mv bootstrap-reps.tbz ../
			mv RAxML_info.BS ../
			cd ../
		fi	
		for bs in `seq $l $(( rep - 1 ))`; do
			tar xfj bootstrap-reps.tbz $in.phylip.BS$bs
			fasttree $ftmodel $in.phylip.BS$bs > fasttree.tre.BS$bs 2> ft.log.BS$bs;
			test $? == 0 || { cat ft.log.BS$bs; exit 1; }
			python $DIR/arb_resolve_polytomies.py fasttree.tre.BS$bs
			raxmlHPC -F -t fasttree.tre.BS$bs.resolved -m $model -n ml.BS$bs -s $in.phylip.BS$bs -N 1  $s &> $tmpdir/logs/ml_std.errout."$bs"."$in"
			test $? == 0 || { echo in running RAxML on bootstrap trees; exit 1; }
			cat RAxML_result.ml.BS$bs >> RAxML_bootstrap.all
			rm $in.phylip.BS$bs*
			tar rvf bootstrap-files.tar --remove-files *BS$bs *BS$bs.*
		done
	fi
fi
if [ ! -s RAxML_bootstrap.all ]; then
	cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all
elif [ `cat RAxML_bootstrap.all |wc -l` -ne $rep ]; then
	if [ -s RAxML_bootstrap.back.all ]; then
		kdif=$(grep -v -x -f RAxML_bootstrap.all RAxML_bootstrap.back.all > tmp.diff)
		kdifrep=$(cat tmp.diff | wc -l)
		krep=$(cat RAxML_bootstrap.back.all | wc -l)
		if [ "$kdifrep" -eq "$krep"  ];
			cat RAxML_bootstrap.all >> RAxML_bootstrap.back.all;
			mv RAxML_bootstrap.back.all RAxML_bootstrap.all
		else
			echo "something is not fine"
			exit 1
		fi
	fi
fi

if [ ! `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -eq $rep ]; then
	echo `pwd`>>$H/../notfinishedproperly
	exit 1
else
 
#Finalize
	 
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
