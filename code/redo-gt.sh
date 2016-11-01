#!/bin/bash
if [ ! -s "clade-defs.txt-backup" ]; then
	cp clade-defs.txt clade-defs.txt-backup
fi
cat clade-defs.txt | grep -v '"'  | grep -v "Clade Name" | awk -vFS='\t' '{print "internalNode"NR"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}' > clade-defs.txt1
cat clade-defs.txt | grep '"' > clade-defs.txt-o
cat clade-defs.txt1 >> clade-defs.txt-o
mv clade-defs.txt-o clade-defs.txt 
rm clade-defs.txt1
bash -c './find_clades.py  */raxmlboot.????/RAxML_bipartitions.final.rooted */raxmlboot.????.c1c2/RAxML_bipartitions.final.rooted > clades.stat;' &
bash -c './find_clades.py  */raxmlboot.????/RAxML_bipartitions.final.rooted.75 */raxmlboot.????.c1c2/RAxML_bipartitions.final.rooted.75 > clades.hs.stat;' &


for job in `jobs -p`; do  wait $job; done

./prepare.stat.file.sh clades.hs.stat > clades.hs.txt
./prepare.stat.file.sh clades.stat > clades.txt

wc -l clades*txt
