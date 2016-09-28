#/bin/bash

x=$1

cd $x
pwd

cat astral-BS*.tre| tee bs-all.tre|wc -l

add-bl.py -- astral-Best.tre

raxmlHPC -f b -z bs-all.tre -t astral-Best.tre.blen -m GTRCAT -n bestML
