#!/bin/bash

for x in `find . -name "bootstrap-files.tar"`; do 
	y=$(dirname $x); 
	b=$(basename $x| sed -e 's/.tar//'); 
	mkdir $y/$b; 
	cp $x $y/$b; 
	a=$(cd $y/$b; tar xvf `basename $x`); 
	echo $x; 
done 

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
