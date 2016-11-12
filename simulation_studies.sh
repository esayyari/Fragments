#!/bin/bash
find . -maxdepth 1 -type d -name "[A-Za-Z0-9]*" | sed -e 's/\.\///' | sort > listOfFiles
while read x; do 
	y=FNA-$x-rm-3rdCodon-mask1sites.mask1taxa; 
	$WS_HOME/insects/generate_fragmentary_stat.sh ./$x/ $y FNA $x-rm-3rdCodon-mask1sites.mask1taxa; 
	$WS_HOME/insects/gc-stats.py $x/$y/$y.fasta FNA > $x/$y/$y.gc-stats; 
done < listOfFiles   > gc_stat.error 2>&1
while read x; do 
	$WS_HOME/insects/root-nw_friendly.py $x/FNA-$x-rm-3rdCodon-mask1sites.mask1taxa/FNA-$x-rm-3rdCodon-mask1sites.mask1taxa/fasttree.tre.best.addPoly.rooted.final; 
done < listOfFiles  > error_rerooting 2>&1
grep "IXODES_SCAPULARIS" */*/*/*.rerooted | sed -e 's/:.*//' |sed -e 's/\/.*//' | sort > listOfFiles-with-main_root
while read x; do 
	y=FNA-$x-rm-3rdCodon-mask1sites.mask1taxa; 
	sed -i "s/'//g" $x/$y/$y/fasttree.tre.best.addPoly.rooted.final.rerooted; 
	nw_distance $x/$y/$y/fasttree.tre.best.addPoly.rooted.final.rerooted -m r -n -s f | sort -k 1 > $x/$y/distances_to_the_root.txt; 
	sed -i 's/>//g' $x/$y/$y.fragmentary.stat
	sort -k 1 $x/$y/$y.fragmentary.stat > $x/$y/$y.fragmentary.stat.sorted
done < listOfFiles-with-main_root
echo "ID,taxa,seqlength,A,C,G,T,a,c,g,t,N,other_fragmentary" > all_fragmentary.stat
grep "[a-zA-Z0-9]" $(cat listOfFiles-with-main_root | sort | xargs -I@ sh -c 'echo @/FNA-@-rm-3rdCodon-mask1sites.mask1taxa/FNA-@-rm-3rdCodon-mask1sites.mask1taxa.fragmentary.stat.sorted;')  | grep -v "taxa,seqlength,A,C,G,T,a,c,g,t,N,-" | sed -e 's/\/.*:/,/g'  >> all_fragmentary.stat
echo "ID,taxa,branch_length" > all_distances.txt
grep "[a-zA-Z0-9]" $(cat listOfFiles-with-main_root | sort | xargs -I@ sh -c 'echo @/FNA-@-rm-3rdCodon-mask1sites.mask1taxa/distances_to_the_root.txt') | sed -e 's/\/.*:/,/g' >> all_distances.txt
sed -i 's/\t/,/g' all_distances.txt
cd ../simulated/model.100.2000000.0.000001/
seq -w 1 50 | xargs -P 3 -I@ sh -c '$WS_HOME/insects/simulated-nw-friendly-root.py @/estimatedgenetre.halfresolved @/estimatedgenetre.halfresolved.rerooted-nw-friendly; $WS_HOME/insects/simulated-root.py @/estimatedgenetre.halfresolved @/estimatedgenetre.halfresolved-rooted; echo @;'
for i in `seq -w 1 50`; do
	nw_distance $i/estimatedgenetre.halfresolved.rerooted-nw-friendly -m r -s f -n | sort -nk1 > $i/branch_lenght$i.txt
done
echo "ID taxa branch_length" > branch_length_all_simulated.txt; grep "[0-9]" */branch* | sed -e 's/\/.*:/ /g' | sed -e 's/\t/ /g' >> branch_length_all_simulated.txt 
