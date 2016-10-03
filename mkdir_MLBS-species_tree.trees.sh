#!/bin/bash
DIR=$( cd "${BASH_SOURCE[0]}" && pwd )
source $DIR/tools.sh
workdir=$1/MLBS-species_tree
rep=$2
mkdir -p $workdir
cd $workdir
mkdir no-long-branch-filtering
cd no-long-branch-filtering
a=(20 25 33 50 66 75 80); f=(FAA FNA); 
for ft in ${f[@]}; do 
	for at in ${a[@]}; do 
		mkdir $ft-10sites-"$at"taxa; 
		ls $workdir/../*/$ft*10sites*"$at"taxa*/*/*/fasttree*best*final > tmp
		while read x; do
			p=`absp $x`
			cat $p >> $ft-10sites-"$at"taxa/gene_trees.trees;
		done < tmp
		
		ls $workdir/../*/$ft*10sites*"$at"taxa*/*/*/fasttree*BS-all.addPoly > tmp
		while read x; do
			p=`absp $x`; 
			echo $p >> $ft-10sites-"$at"taxa/list-BS-all;
		done < tmp
		
	done
done
for dir in `find . -maxdepth 1 -type d -name "F*"`; do 
	java -jar /home/esayyari/repository/ASTRAL/astral.4.10.9.jar -i $dir/gene_trees.trees -b $dir/list-BS-all -o $dir/BS -k bootstraps_norun -r $rep ; 
done

cd $workdir
mkdir with-long-branch-filtering
cd with-long-branch-filtering
a=(50)
f=(FAA)
clade=Strepsiptera
for ft in ${f[@]}; do
        for at in ${a[@]}; do
		for c in ${clade[@]}; do
			mkdir $ft-10sites-"$at"taxa-with-filtering-removed-$c;
			mkdir $ft-10sites-"$at"taxa-without-filtering-removed-$c;
			mkdir $ft-10sites-"$at"taxa-with-filtering-with-$c;
			mkdir $ft-10sites-"$at"taxa-with-filtering-with-$c-raxml;
			ls $workdir/../long*/*/$ft*10sites*"$at"taxa*removed* | grep -v "raxml" | grep -v "without" | grep > tmp
			while read x; do
				cat $x/*/fasttree*best*final >> $ft-10sites-"$at"taxa-with-filtering-removed-$c/gene_trees.trees
				p=`absp $x/*/fasttree*BS-all.addPoly`
				echo $p	>> $ft-10sites-"$at"taxa-with-filtering-removed-$c/list-BS-all
			done < tmp
			ls $workdir/../long*/*/$ft*10sites*"$at"taxa*removed* | grep -v "raxml" | grep "without" | grep > tmp
			while read x; do
                                cat $x/*/fasttree*best*final >> $ft-10sites-"$at"taxa-without-filtering-removed-$c/gene_trees.trees
                                p=`absp $x/*/fasttree*BS-all.addPoly`
				echo $p >> $ft-10sites-"$at"taxa-without-filtering-removed-$c/list-BS-all
                        done < tmp
			ls $workdir/../long*/*/$ft*10sites*"$at"taxa*removed* | grep -v "raxml" | grep -v "removed" | grep > tmp
                        while read x; do
                                cat $x/*/fasttree*best*final >> $ft-10sites-"$at"taxa-with-filtering-with-$c/gene_trees.trees
                                p=`absp $x/*/fasttree*BS-all.addPoly`
				echo $p >> $ft-10sites-"$at"taxa-with-filtering-with-$c/list-BS-all
                        done < tmp
			find  $workdir/../long*/*/$ft*10sites*"$at"taxa-with-filtering-with-$c*raxml/ -maxdepth 1 -type d -name "raxml*" > tmp
			while read x; do
				cat $x/RAxML_bestTree.best.addPoly.rooted.final.fasttree.rerooted >> $ft-10sites-"$at"taxa-with-filtering-with-$c-raxml/gene_trees.trees
				p=`absp $x/RAxML_bootstrap.all.addPoly.rooted`
				echo $p >> $ft-10sites*"$at"taxa-with-filtering-with-$c/list-BS-all
			done < tmp
		done
	done
done
rm tmp
for dir in `find . -maxdepth 1 -type d -name "F*"`; do 
	java -jar /home/esayyari/repository/ASTRAL/astral.4.10.11.jar -i $dir/gene_trees.trees -b $dir/list-BS-all -o $dir/BS -k bootstraps_norun -r $rep
done
#cat $dir/BS*bs* | sort > tmp
#while read x<$dir/list-BS-all; do
#	cat $x 
#done | sort > tmp2
#test `diff tmp tmp2` == "" || echo "Not all of the bootstrapped files have been used" && exit



