setwd(dirname(sys.frame(1)$ofile))

d<-read.csv('../results/branchStat.txt',sep=" ",header=F)

cdat <- ddply(d, c("V1","V2","V3"), summarise, mean_bl=mean(V5),max_bl=mean(V6),support=mean(V7))
cdat[,4]<-as.numeric(cdat[,4])
cdat[,5]<-as.numeric(cdat[,5])
cdat[,6]<-as.numeric(cdat[,6])

pdf('../results/figures/average_taxa_distance_vs_MLBS.pdf',width=7,height=4.5,compress=F)
qplot(data=cdat[cdat$V2 != 15,],mean_bl,support,color=interaction(V2,V3))+facet_wrap(~V1)+geom_point(size=4)+
  theme_bw()+xlab('average taxa distance')+
  theme(legend.position="bottom",text = element_text(size=12),
        axis.text.x = element_text(size=12,angle = 0),
        axis.text.y = element_text(size=12,angle = 0),
        legend.text=element_text(size=12))+
  ylab('average bootstrap support (percent)')+
  scale_color_brewer(name='',palette='Paired',
                     labels=c("20","25","33","50","66","75","80"))
dev.off()


pdf('../results/figures/maximum_taxa_distance_vs_MLBS.pdf',width=7,height=4.5,compress=F)
qplot(data=cdat[cdat$V2 != 15,],max_bl,support,color=interaction(V2,V3))+facet_wrap(~V1)+geom_point(size=4)+
  theme_bw()+  theme(legend.position="bottom",text = element_text(size=12),
                     axis.text.x = element_text(size=12,angle = 0),
                     axis.text.y = element_text(size=12,angle = 0),
                     legend.text=element_text(size=12))+
  xlab('average maximum taxa distance')+ylab('average bootstrap support (percent)')+
  scale_color_brewer(name='',palette='Paired',
                     labels=c("20","25","33","50","66","75","80"))+theme(legend.position="bottom")
dev.off()

d1<-read.csv('../results/branchSupport-all.csv',sep=' ',header=F)


pdf('../results/figures/histogram_MLBS_distribution.pdf',width=30,height=15,compress=F)
ggplot(d1[d1$V2 == 10,], aes(V4,fill = interaction(as.factor(V2),as.factor(V3)),..density..*1000))+
  geom_histogram(alpha=1,color = "black",size=0.05,binwidth=10,position="dodge")+facet_wrap(~V1)+
  theme_bw()+theme(legend.position="bottom",text = element_text(size=24),
                   axis.text.x = element_text(size=24,angle = 0),
                   axis.text.y = element_text(size=24,angle = 0),
                   legend.text=element_text(size=24))+ylab('percent')+
  scale_fill_brewer(name="",palette="Paired",labels=unique(d1$V3))+xlab('MLBS')
dev.off()

a="#7b3294"
b="#c2a5cf"
c="#a6dba0"
d="#008837"

cdat<-melt(cbind(rbind(dcast(data = d1[d1$V2 == 10,c(1,3,4)],
                             V1~V3,fun.aggregate = function(x)(sum(x<1)/length(x))),
                       dcast(data = d1[d1$V2 == 10,c(1,3,4)],
                             V1~V3,fun.aggregate = function(x)(sum(x<=33)/length(x))),
                       dcast(data = d1[d1$V2 == 10,c(1,3,4)],V1~V3,fun.aggregate = function(x)(sum(x>=75)/length(x))),
                       dcast(data = d1[d1$V2 == 10,c(1,3,4)],V1~V3,fun.aggregate = function(x)(sum(x>99)/length(x)))),
                 t=c("=0","=0","<=33","<=33",">=75",">=75","=100","=100")),id=c("t","V1"))

pdf('../results/figures/distribution_MLBS_different_filtering.pdf',width=7.5,height=4.5,compress=F)
qplot(variable, value, data=cdat,geom=c("point","line"),
      color=t,group=t,xlab="Fragment filtering threshold",ylab="Percent")+facet_wrap(~V1)+theme_bw()+
  scale_color_manual(name="Bootstrap support",values=c(a,b,c,d))+scale_y_continuous(labels=percent)+
  theme(legend.position="bottom",text = element_text(size=12),
        axis.text.x = element_text(size=12,angle = 0),
        axis.text.y = element_text(size=12,angle = 0),
        legend.text=element_text(size=12))
dev.off()
