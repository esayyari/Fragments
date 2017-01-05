#!/usr/bin/env Rscript
 
library("optparse")
option_list = list(
   make_option(c("-p", "--path"), type="character", default=NULL, 
               help="WS_HOME", metavar="character"),
   make_option(c("-s", "--ST"), type="integer", default=NULL,
               help="Type of data stats, it could be species tree (0), or gene tree (1)"),
   make_option(c("-c","--clade"), type="character", default=NULL,
               help="Clade definition file"),
   make_option(c("-i", "--inputPath"), type="character", default=NULL,
               help="The path to the stat files direcotry")
 ); 
 
 opt_parser = OptionParser(option_list=option_list);
 opt = parse_args(opt_parser);
 
 if (is.null(opt$path)){
   print_help(opt_parser)
   stop("At least one argument must be supplied WS_HOME.", call.=FALSE)
 } else {
   WS_HOME = opt$path
 }
 
 if (is.null(opt$ST)){
   print_help(opt_parser)
   stop("Please specify wheather the stat file is for species trees (0) or gene trees (1).", call.=FALSE)
 } else {
   if ( as.integer(opt$ST) == 0 ) {
     ST = TRUE
   } else {
     ST = FALSE
   }
 }
 if (is.null(opt$clade)){
   print_help(opt_parser)
   stop("Please specify the path to the clade definitions.", call.=FALSE)
 } else {
   clade = opt$clade
 }
 
 if (is.null(opt$inputPath)){
   print_help(opt_parser)
   stop("Please specify the path to the input stat files")
 } else {
   input = opt$inputPath
}
out = opt$inputPath
setwd(out)
print("here")
print(getwd())
#WS_HOME = "/Users/Erfan/Documents/Research/"
#clade = "/Users/Erfan/Documents/Research/insects/code/clade-defs.txt"
#ST=TRUE
#input = "/Users/Erfan/Documents/Research/insects/code/test/species/"
#out = input
#setwd(out)
#print(getwd())
depict = paste(WS_HOME,"/insects/code/R/main_depict_clades.R",sep="") 
source(depict)

cl=read.csv(clade,header=T,sep="\t")

names(cl)<-c("V1","V2","V3",names(cl)[4:length(cl)])

clade.order=c()
for (x in levels(cl$V3)) {
  if (x != "None") {
    clade.order=c(clade.order,paste("[",x,"]"))
    clade.order=c(clade.order,as.vector(paste(cl[cl$V3==x,1],
                                              sapply(cl[cl$V3==x,4],function (x) if (x!="" & !is.na(x)) paste(" (",x,")",sep="") else ""),sep="")))
  }
}

print(cl)
data = read.data(file.all="clades.txt.res", file.hs="clades.hs.txt.res", clade.order=clade.order)
if (ST) {
	print("here")
	# metabargraph1(data$countes.melted,data$y,sizes=c(5,15))
	metatable(data$y,data$y.colors,data$countes,pages=c(1),raw.all=data$raw.all)
} else {
  metabargraph(data$countes.melted,data$y,sizes=c(12.5,15))
  metabargraph2(data$countes.melted,data$y,sizes=c(12.5,15))
  metahistograms2(data$raw.all)
   	p<-ggplot(data$countes.melted, aes(x = DS, y = value)) 
   	p <- p+ geom_bar(stat="identity") + 
   	  aes(fill = Classification)+facet_wrap(~CLADE)
   	  	theme(axis.text.x = element_text(angle = 45))
}


