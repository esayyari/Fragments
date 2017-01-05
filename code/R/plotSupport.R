d<-read.csv('../genetrees.info.perbranch',sep=" ",header=FALSE)
library(plyr)
cdat <- ddply(d, c("V1","V2"), summarise, rating.mean=mean(V3))
ggplot(data=d,aes(x=V3,y=..density..*500,fill=interaction(V2,V1)))+geom_histogram(alpha=1,color = "black",size=0.05,
                                                             binwidth=5,position="dodge")+
  geom_vline(data=cdat, aes(xintercept=rating.mean, colour=interaction(V2,V1)),size=1,linetype="dashed")+
  theme_bw()+theme(legend.position="bottom",
                   strip.text.x = element_blank())+
  scale_fill_brewer(name="",palette="Paired",
                    labels=c("Filtered (aa)","Filtered (nt)","Unfiltered (aa)","Unfiltered (nt)"))+xlab('Support')+
  ylab('Percentage of branches in each support group')+
  scale_color_brewer(name="",palette="Paired",labels=c("Filtered (aa)","Filtered (nt)","Unfiltered (aa)","Unfiltered (nt)"))
ggsave('boostrap_support_genetrees.pdf')
