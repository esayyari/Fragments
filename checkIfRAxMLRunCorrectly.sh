#!/bin/bash

for x in `find */*-raxml/raxml*/ -maxdepth 1 -name "bootstrap-files.tar"`; do 
	y=$(dirname $x); 
	b=$(basename $x| sed -e 's/.tar//'); 
	rm -r $y/$b;
	mkdir $y/$b; 
	cp $x $y/$b; 
	a=$(cd $y/$b; tar xvf `basename $x`); 
	echo $x; 
done 
#cd /oasis/projects/nsf/uot138/esayyari/data/Insects/genes/filtered/10sites-33taxa/long-branch-filtered-2016-08-18-16-30-10-not-backuped/
#pwd
rm notFinishedProperly_not_computed
rm notFinishedProperly_len
for y in `find ALIC*/FAA-*-raxml/raxmlboot.FAA-*/ -type d -name "bootstrap-files"`; do 
	for i in `seq 0 99`; do 
		if [ -s $y/RAxML_result.ml.BS"$i" ] && [ `cat $y/RAxML_result.ml.BS"$i" | grep ";" | wc -l` -eq "1" ]; then 
			cat $y/RAxML_result.ml.BS$i >> $y/RAxML_result.ml; 
		else 
			echo $y,$i | tee -a notFinishedProperly_not_computed;
		fi; 
	done  
	lenres=$(cat $y/RAxML_result.ml | wc -l)
	lenresu=$(cat $y/RAxML_result.ml | sort | uniq | wc -l)
	if [ "$lenres" -ne "$lenresu" ]; then
		echo $lenres,$lenresu,$y/RAxML_result.ml | tee -a notFinishedProperly_len;
	fi
done

while read x; do 
	y=$(echo $x | sed -e 's/,/ /' | sed -e 's_/_ _g' | sed -e 's/  / /g' | awk '{print $2}' | sed -e 's/FAA-//' |sed -e 's/-raxml//'); 
	z=$(echo $x | sed -e 's/,/ /' | sed -e 's_/_ _g' | sed -e 's/  / /g' | awk '{print $1}'); 
	b=$(echo $x | sed -e 's/,/ /' | sed -e 's/\// /g' | sed -e 's/  / /g' | awk '{print $(NF)}'); 
	p=$(pwd); 
	printf " /home/esayyari/repository/insects/runraxml-fasttree-start-boostrapping-remaining-mine.sh $y FAA $z tre 100 rapid $p fasttree $b \n"; 
done < notFinishedProperly_not_computed | tee final_rerun
