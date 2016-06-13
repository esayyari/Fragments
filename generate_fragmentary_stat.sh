#!/bin/bash
for z in `find /home/erfan/Documents/Research//oasis/data/Insect/Supplementary_Archive_7/nt_masked/genes/filtered/ALICUT_EOG* -name "*.linsi.nt.fas"`; do g=$(dirname $z); for x in `cat $z`; do y=$(echo $x | grep ">" ); if [ "$y" == "" ]; then echo -n $x | awk -vFS="" '{for(i=1;i<=NF;i++)w[$i]++ sum++}END{printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s","SEQUENCE","N","-","A","C","G","T","a","c","t","g","ACGT-","SUM"}END{print ""}END{printf "%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f","##",w["N"]/sum,w["-"]/sum,w["A"]/sum,w["C"]/sum,w["G"]/sum,w["T"]/sum,w["a"]/sum,w["c"]/sum,w["t"]/sum,w["g"]/sum,(w["A"]+w["T"]+w["C"]+w["-"]+w["G"])/sum,sum}' | sed -e 's/,$//'; echo; else echo $x; fi; done  > $g/fragmentary.stat;echo "working on $g has been finishe"; done



for x in /home/erfan/Documents/Research//oasis/data/Insect/Supplementary_Archive_7/nt_masked/genes/filtered/*/fragmentary.stat; do d=$(dirname $x); cat $x | sed -e 's/>\(.*\)/>\1\#/' | sed -e 's/\(.*\)SUM/\&\1SUM\&/' | tr "\n" "@"  | sed -e 's/>/\n/g' | sed -e 's/@//g' | sed -e 's/#\&.*\&##//g' > $d/fragmentary_final.stat; echo "working on $x has been finished"; done 



#for z in `find /home/erfan/Documents/Research//oasis/data/Insect/Supplementary_Archive_7/nt_masked/genes/filtered/ALICUT_EOG* -name "*.linsi.nt.fas"`; do g=$(dirname $z); for x in `cat $z`; do y=$(echo $x | grep ">" ); if [ "$y" == "" ]; then echo -n $x | awk -vFS="" '{for(i=1;i<=NF;i++)w[$i]++ sum++}END{printf "%s ,%s ,%s ,%s ,%s ,%s ,%s ,%s ,%s, %s, %s, %s, %s" ,"N","-","A","C","G","T","a","c","t","g","ACGT-","SUM"}END{printf "%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f ,%f  ",w["N"]/sum,w["-"]/sum,w["A"]/sum,w["C"]/sum,w["G"]/sum,w["T"]/sum,w["a"]/sum,w["c"]/sum,w["t"]/sum,w["g"]/sum,(w["A"]+w["T"]+w["C"]+w["-"]+w["G"])/sum,sum}' | sed -e 's/,$//'; echo; else echo $x; fi; done > $g/fragmentary.stat;echo "working on $g has been finishe"; done
