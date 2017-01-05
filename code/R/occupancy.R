require(ggplot2)
require(reshape)
require(plyr)

setwd(dirname(sys.frame(1)$ofile))
clades<-read.csv("../results/annotate.txt",sep='\t',header=T)
oc <- read.csv('../results/occupancy.csv',header=F,sep=' ')
oc2<-read.csv('../results/occupancy_long_branch_filtered.csv',header=F,sep=' ')

names(oc)<-c("Seq","GENE_ID","filtered_sites","filtered_taxa", "Taxon","Len")
names(oc2)<-c("Seq","GENE_ID","filtered_sites","filtered_taxa", "Taxon","Len","sd","method")
oc$sd<-"None"
oc$method<-"None"
oc<-rbind(oc,oc2)

oc$ID <- apply( oc[ , c(1,3,4,7,8) ] , 1 , paste0 , collapse = "-" )
oc<-oc[,c(9,2,5,6)]
oc<-oc[grepl("F.*10.*N",oc$ID) | grepl("F.*10-50-3-avg",oc$ID),]
#if (length(names(oc)) == 4) {
 # oc <- dcast(oc,GENE_ID+Taxon~.,fun.aggregate=sum,value.var="Len")
#}

#names(oc) <- c("ID","Taxon", "Len")

ocs <- ddply(oc, .(ID,GENE_ID), transform, rescale= scale(Len,center=F))
ocs$Taxon <- with(ocs, reorder(Taxon, Len, FUN = function(x) {return(length(which(x>0)))}))
ocs$ID <- with(ocs, reorder(ID, Len,FUN = length))

tc=recast(ocs[,c(1,3,4)],ID+Taxon~.); names(tc)[3]<-"occupancy"
tc2<-tc
ocs2<-oc[oc$ID %in% c("FAA-10-50"),]
ocs2 <- dcast(ocs2,GENE_ID+Taxon~.,fun.aggregate=sum,value.var="Len")
names(ocs2) <- c("GENE_ID","Taxon", "Len")

ocs2 <- ddply(ocs2, .(GENE_ID), transform, rescale= scale(Len,center=F))
ocs2$Taxon <- with(ocs2, reorder(Taxon, Len, FUN = function(x) {return(length(which(x>0)))}))
ocs2$GENE_ID <- with(ocs2, reorder(GENE_ID, Len,FUN = length))

pdf('../results/figures/occupancy_map.pdf',width=24.5,height=11.7,compress=F)
ggplot(ocs2, aes(GENE_ID,Taxon)) + 
  geom_tile(aes(fill = rescale),colour = "white")+
  scale_fill_gradient(low = "white",high = "steelblue")+
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0) )+
  theme(legend.position = "none",axis.ticks = element_blank(),
        axis.text.x = element_text(size=2,angle = 90, hjust = 0, colour = "grey50"),
        axis.text.y = element_text(size=8,angle = 0, hjust = 0, colour = "grey50"))
dev.off()


tc$ID<-factor(tc$ID,rev(levels(tc$ID)))

pdf('../results/figures/occupancy_FAA.pdf',width=23.8, height=11.4,compress=F)

qplot(data=tc[grepl("FAA-",tc$ID),],
      x=reorder(Taxon,occupancy/1478,FUN=median),y=occupancy/1478,geom=c("line"),
      group=ID,color=ID)+theme_bw()+theme(legend.position = "bottom",axis.ticks = element_blank(),
                              axis.text.x = element_text(size=16,angle = 90, hjust = 0, colour = "grey50"),
                              legend.text=element_text(size=16),axis.text.y=element_text(size=16),text = element_text(size=16))+
  ylab('Occupancy')+xlab('Taxon')+scale_color_brewer(name="",palette = "Paired",labels=c("20","25","33","50","50-filtered-long-branches","66","75","80"))
dev.off()

pdf('../results/figures/occupancy_FNA_after_long_branch_filtering.pdf',width=23.8, height=11.4,compress=F)
qplot(data=tc[grepl("FNA-",tc$ID),],
      x=reorder(Taxon,occupancy/1478,FUN=median),y=occupancy/1478,geom=c("line"),
      group=ID,color=ID)+theme_bw()+theme(legend.position = "bottom",axis.ticks = element_blank(),
                                          axis.text.x = element_text(size=16,angle = 90, hjust = 0, colour = "grey50"),
                                          legend.text=element_text(size=16),axis.text.y=element_text(size=16),text = element_text(size=16))+
  ylab('Occupancy')+xlab('Taxon')+scale_color_brewer(name="",palette = "Paired",labels=c("20","25","33","50","50-filtered-long-branches","66","75","80"))
dev.off()


tc$occupancy_prob <-tc$occupancy/1478
tc$miss_prob <-1-tc$occupancy_prob
tc_clades<-(merge(tc,clades,by.x="Taxon",by.y="Names"))
tc_clades2<-dcast(data=tc_clades,formula=ID+Clades+GENE_ID~.)
tc_clades_missing<-dcast(data=tc_clades,formula=ID+Clades~.,fun.aggregate=prod,value.var="miss_prob")
names(tc_clades_missing) <-c("ID","Clades","prob_miss")
tc_clades_missing$occupancy <- 1-tc_clades_missing$prob_miss

ocs3<-merge(ocs,clades,by.x="Taxon",by.y="Names")
tc_clades3<-dcast(data=ocs3,formula=GENE_ID+ID+Clades~.)
names(tc_clades3)[4]<-"num_clade_present"

tc_clades3$ID<-factor(tc_clades3$ID,rev(levels(tc_clades3$ID)))

pdf('../results/figures/occupancy_clades_FAA-plus-long-branch-filtering.pdf')
qplot(reorder(Clades,.),.,
      data=dcast(tc_clades3[grepl("FAA-10",tc_clades3$ID) ,2:4], 
                 ID+Clades~., fun.aggregate = 
                   function(x) (sum(x>0)/length(levels(tc_clades3$GENE_ID)))),
      geom="line",color=ID,group=ID)+theme_bw()+theme(legend.position = "bottom",
      axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, colour = "grey50"))+
      xlab('Clades')+ylab('Percent')+scale_y_continuous(labels = scales::percent)+
      scale_color_brewer(name="",palette="Paired",labels=c("20","25","33","50","50-filtered-long-branches","66","75","80"))
dev.off()
pdf('../results/figures/occupancy_clades_FNA-plus-long-branch-filtering.pdf')
qplot(reorder(Clades,.),.,
      data=dcast(tc_clades3[grepl("FNA-10",tc_clades3$ID) ,2:4], 
                 ID+Clades~., fun.aggregate = 
                   function(x) (sum(x>0)/length(levels(tc_clades3$GENE_ID)))),
      geom="line",color=ID,group=ID)+theme_bw()+theme(legend.position = "bottom",
                                                      axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, colour = "grey50"))+
  xlab('Clades')+ylab('Percent')+scale_y_continuous(labels = scales::percent)+
  scale_color_brewer(name="",palette="Paired",labels=c("20","25","33","50","50-filtered-long-branches","66","75","80"))
dev.off()

pdf('../results/figures/occupancy_clades_FNA.pdf')
qplot(reorder(Clades,.),.,
      data=dcast(tc_clades3[grepl("FNA-10",tc_clades3$ID) ,2:4], 
                 ID+Clades~., fun.aggregate = 
                   function(x) (sum(x>0)/length(levels(tc_clades3$GENE_ID)))),
      geom="line",color=ID,group=ID)+theme_bw()+theme(legend.position = "bottom",
      axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, colour = "grey50"))+
      xlab('Clades')+ylab('Percent')+scale_y_continuous(labels = scales::percent)+sclae_color_brewer(names="",)
  scale_color_brewer(name="",palette="Paired",labels=c("20","25","33","50","66","75","80"))
dev.off()

tc_clades3$ID<-factor(tc_clades3$ID,rev(levels(tc_clades3$ID)))
tc_clades4<-dcast(tc_clades3[grepl("F.*10-50-[346N]",tc_clades3$ID) ,2:4], 
                  ID+Clades~., fun.aggregate = 
                    function(x) (sum(x>0)/length(levels(tc_clades3$GENE_ID))))
names(tc_clades4)[3]<-c("clade_occupancy")

pdf('../results/figures/occupancy_clades_FAA.pdf')
qplot(reorder(Clades,.),.,
      data=dcast(tc_clades3[grepl("FAA-10.*None",tc_clades3$ID) ,2:4], 
                 ID+Clades~., fun.aggregate = 
                   function(x) (sum(x>0)/length(levels(tc_clades3$GENE_ID)))),
      geom="line",color=ID,group=ID)+theme_bw()+theme(legend.position = "bottom",
                                                      axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, colour = "grey50"))+
  xlab('Clades')+ylab('Percent')+scale_y_continuous(labels = scales::percent)+
  scale_color_brewer(name="",palette="Paired",labels=c("20","25","33","50","66","75","80"))
dev.off()

pdf('../results/figures/occupancy_clades_after_long_branch_filtering_FNA.pdf')
ggplot(data=tc_clades4[grepl("FNA",tc_clades4$ID),], aes(x=reorder(Clades,clade_occupancy),y=clade_occupancy,fill=ID ))+
  stat_summary(color="1",geom="bar",position="dodge",fun.y=mean,alpha=1)+theme_bw()+theme(legend.position = "bottom",
                                                                                          axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, colour = "grey50"))+
  xlab('Clades')+ylab('Percent')+scale_y_continuous(labels = scales::percent)+scale_fill_brewer(name="",palette="Set2",labels=c("No-filtering","6-med","6-average","4-med","4-average","3-med","3-average"))
dev.off()

pdf('../results/figures/occupancy_clades_after_long_branch_filtering_FNA.pdf')
ggplot(data=tc_clades4[grepl("FNA",tc_clades4$ID),], aes(x=reorder(Clades,clade_occupancy),y=clade_occupancy,fill=ID ))+
  stat_summary(color="1",geom="bar",position="dodge",fun.y=mean,alpha=1)+
  theme_bw()+theme(legend.position = "bottom",axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, colour = "grey50"))+
  xlab('Clades')+ylab('Percent')+scale_y_continuous(labels = scales::percent,breaks= scales::pretty_breaks(n=6))+
  scale_fill_brewer(name="",palette="Paired",labels=c("No-filtering","6-med","6-average","4-med","4-average","3-med","3-average"))+
  geom_hline(yintercept=.66,color='#ff7f00',size=2)
dev.off()







