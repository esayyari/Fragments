d<-read.csv('../genetrees-mlbs.info',sep=" ",header=FALSE)
ggplot(d,
       aes(V2,fill = V1,group=V1)) +geom_density(alpha=0.5,
                                                 adjust=1.5,position="dodge")+
  theme_bw()+theme(legend.position="bottom",
                   strip.background = element_blank(),strip.text.x = element_blank())+
  scale_fill_brewer(name="",palette="Set2")+xlab('MLBS')



ggplot(d,
       aes(V2,fill = V1,group=V1)) +geom_histogram(alpha=1,color = "black",size=0.05,
                                                   binwidth=5,position="dodge")+
  theme_bw()+theme(legend.position="bottom",
                   strip.text.x = element_blank())+
  scale_fill_brewer(name="",palette="Paired")+xlab('MLBS')