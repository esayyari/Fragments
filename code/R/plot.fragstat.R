require(ggplot2)
require(reshape2)

f = read.csv("../fragmentary.stat",sep=" ")
f$PR<-0
f[f$N>0.5,]$PR<-1
fall=f
fdall = melt(fall[,c(1,2,15)],id=c("GENE","SEQUENCE"),stat=sum)
pdf("allgenes_nucfreq.pdf")

qplot(reorder(SEQUENCE,value),value,data=fdall[fdall$variable == "N",],geom="boxplot", color=variable)+ theme(axis.text.x = element_text(angle = 90))+facet_grid(DATASET~., scales = "free")
qplot(SEQUENCE,value,data=fdall[fdall$variable == "N",],geom="boxplot", color=variable)+facet_grid(DATASET~., scales = "free")
dev.off()


quit()