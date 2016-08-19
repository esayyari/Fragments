#!/bin/bash

bash -c './find_clades.py  */raxmlboot.????/RAxML_bipartitions.final.rooted */raxmlboot.????.c1c2/RAxML_bipartitions.final.rooted > clades.stat;' &
bash -c './find_clades.py  */raxmlboot.????/RAxML_bipartitions.final.rooted.75 */raxmlboot.????.c1c2/RAxML_bipartitions.final.rooted.75 > clades.hs.stat;' &


for job in `jobs -p`; do  wait $job; done

./prepare.stat.file.sh clades.hs.stat > clades.hs.txt
./prepare.stat.file.sh clades.stat > clades.txt

wc -l clades*txt
