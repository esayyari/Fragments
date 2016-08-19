ST = FALSE
source ("~/workspace/global/src/R/depict_clades.R")


cl=read.csv("clade-defs.txt",header=T,sep="\t")
names(cl)<-c("V1","V2","V3",names(cl)[4:length(cl)])
clade.order=c()
for (x in levels(cl$V3)) {
 if (x != "None") {
  clade.order=c(clade.order,paste("[",x,"]"))
  clade.order=c(clade.order,as.vector(paste(cl[cl$V3==x,1],sapply(cl[cl$V3==x,4],function (x) if (x!="" & !is.na(x)) paste(" (",x,")",sep="") else ""),sep="")))
 }
}

print(cl)
if (ST) {
	data = read.data(clade.order=clade.order, techs.order = techs)	
	metatable(data$y,data$y.colors,data$countes,pages=c(1),raw.all=data$raw.all)
} else {
	data = read.data(file.all="clades.txt", file.hs="clades.hs.txt",clade.order=clade.order)
        rename <- list("Nucleotide, all three codons"="FNA2AA", "Nucleotide, 1st & 2nd codon"="FNA2AA.C12", "Amino acid"="FAA",
				               "Nucleotide, all three codons (25X filtering)"="25Xfilter-FNA2AA", "Nucleotide, 1st & 2nd codon (25X filtering)"="25Xfilter-FNA2AA.C12", "Amino acid (25X filtering)"="25Xfilter-FAA")
        levels(data$countes.melted$DS) <- rename
	levels(data$y$DS) <- rename	
	metabargraph(data$countes.melted,data$y,sizes=c(12.5,15))
	#metabargraph2(data$countes.melted,data$y,sizes=c(12.5,15))
	metahistograms2(data$raw.all)
}

