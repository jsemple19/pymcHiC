

# packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(GenomicRanges)
library(BSgenome.Celegans.UCSC.ce11)
library(Sushi)
library(RColorBrewer)
library(data.table)

setwd("/home/ubelix/izb/md17s996/20181126_HICRepeat/pymcHiC")
#setwd("~/Documents/MeisterLab/otherPeopleProjects/Moushumi")
expName="20181126_HICRepeat"
path="../out/"
Chrnames<-c("I","II","III","IV","V","X") # used to get rid of mtDNA
chrOrder<-c("I","II","III","IV","V","X","MtDNA") # used to reorder sequence name levels in objects

# read in contacts file
contacts<-read.csv(paste0(path,expName,"_contacts.csv"),stringsAsFactors=F)
idx<-contacts$hopType=="Intra" & contacts$hopSize<500
contacts<-contacts[!idx,]

# function to convert text to genomic range
makeGRfromTxt<-function(txtVec) {
  s<-strsplit(txtVec,"[[:punct:]]")
  chr<-sapply(s,"[[",1)
  strand<-rep("*",length(txtVec))
  start<-as.numeric(sapply(s,"[[",3))
  end<-as.numeric(sapply(s,"[[",4))
  gr<-GRanges(seqnames=chr,IRanges(start=start,end=end),strand=strand)
  return(gr)
}

gr1<-makeGRfromTxt(contacts$firstChr)
seqlevels(gr1)<-chrOrder
#strand(gr1)<-"*"

gr2<-makeGRfromTxt(contacts$secondChr)
seqlevels(gr2)<-chrOrder
#strand(gr2)<-"*"

# set size of bins to use
seqnames(Celegans)<-gsub("chr","",seqnames(Celegans))
seqnames(Celegans)<-gsub("M","MtDNA",seqnames(Celegans))

binSizes=c(1e6,5e5,1e5)
for (binSize in binSizes) {
b<-unlist(tileGenome(seqlengths(Celegans), tilewidth=binSize))


#############################################
# plot full genome HiC
#############################################

# create empty matrix for contact counts
m<-matrix(c(0),nrow=length(b),ncol=(length(b)))

# build up matrix of counts in bins. If GR hits two bins, only take the first one
for (i in 1:length(gr1)) {
  ol1<-findOverlaps(gr1[i],b)
  ol2<-findOverlaps(gr2[i],b)
  dim1<-subjectHits(ol1)[1]
  dim2<-subjectHits(ol2)[1]
  m[dim1,dim2]<-m[dim1,dim2]+1
  m[dim2,dim1]<-m[dim2,dim1]+1
}

options(scipen=1e4) #print numbers in normal notation

# save matrix
saveRDS(m,paste0(path,"contactMatrix_res",binSize,"bp.RDS"))
m<-readRDS(paste0(path,"contactMatrix_res",binSize,"bp.RDS"))

# get full genome length
genomeLength=sum(seqlengths(Celegans))

# get bin number where chromosomes start
chrStarts<-start(seqnames(b))
# get bin number where chromosomes end
chrEnds<-end(seqnames(b))

# find the midpoint of each chromosome where chromosome name labels will go
chrLabelPos<-start(seqnames(b))+(end(seqnames(b))-start(seqnames(b)))/2

# get tick positions for cumulative distance along genome
tickPos<-seq(0,genomeLength,2e7)

# convert matrix to a table for genome wide plotting
m4plot<-melt(m)


# make genome wide plot
p1<-ggplot(m4plot,aes(Var1,Var2,fill=log(value,10))) +
  geom_tile() + coord_fixed() +
  ggtitle(paste("MC-HiC contacts with bin size:",
              formatC(binSize,big.mark=",",drop0trailing=T,format="f"),"bp")) +
  geom_vline(xintercept=chrStarts-1) +
  geom_hline(yintercept=chrStarts-1) +
  scale_fill_distiller(name="log(#contacts)",palette = "YlOrRd", na.value = "grey",direction=1,
                       limits=c(0,0.85*log(max(m),10))) +
  scale_x_continuous(name="Position in genome (Mb)",breaks=(chrEnds[6]/100)*tickPos/binSize,labels=tickPos/1e6) +
  scale_y_continuous(name="Position in genome (Mb)",breaks=(chrEnds[6]/100)*tickPos/binSize,labels=tickPos/1e6) +
  annotate("text",x=rep(-3,6),y=chrLabelPos[1:6],label=Chrnames) +
  annotate("text",y=rep(-3,6),x=chrLabelPos[1:6],label=Chrnames)

ggsave(filename=paste0(path,"genomeWideContacts_res",binSize,"bp.pdf"),plot=p1,device="pdf",
       width=19,height=19,units="cm")

##################################################
# Plot one chr at a time in horizontal orientation
##################################################

# choose colour scheme
#myCols<-colorRampPalette(rev(brewer.pal(6,"Accent")))
myCols<-colorRampPalette(rev(heat.colors(9)))
#myCols<-colorRampPalette(topo.colors(11))

# get a cumulative genome position for where the bins start and name the matrix rows and columns accordingly
binBreaks<-start(b)+rep(cumsum(c(0,seqlengths(Celegans)[1:6])),times=diff(c(0,end(seqnames(b)))))
names(binBreaks)<-NULL
rownames(m)<-binBreaks
colnames(m)<-binBreaks

m<-m+1e-2 # add a small amount to all elements of matrix to avoid problem with log(0)

# save matrix
saveRDS(m,paste0(path,"contactMatrix_res",binSize,"bp.RDS"))
m<-readRDS(paste0(path,"contactMatrix_res",binSize,"bp.RDS"))
# plots single chromosomes
pdf(paste0(path,"contactsByChr_res",binSize,"bp.pdf"),height=11,width=8,paper="a4")
par(mfrow=c(3,2))
for (i in 1:length(Chrnames)){
  maxDist<-ceiling(diff(c(0,end(seqnames(b))))[i]/2)
  phic=plotHic(log(m,10),chrom=Chrnames[i],chromstart=binBreaks[chrStarts[i]],chromend=binBreaks[chrEnds[i]],
        palette=myCols,max_y=maxDist,zrange=c(0,log(max(m),10)))
  labelgenome(chrom=Chrnames[i],chromstart=binBreaks[chrStarts[i]],chromend=binBreaks[chrEnds[i]],side=1,
              scipen=20,n=5,scale="Mb", edgeblankfraction=0.20,line=.18,chromline=.5,scaleline=0.5)
  addlegend(phic[[1]],palette=phic[[2]],title="log(#contacts)",side="right",bottominset=0.4,
            topinset=0,xoffset=-.035,labelside="left",width=0.025,title.offset=0.075)
  labelplot(paste0("MC-HiC contacts in chr",Chrnames[i],". Bin size: ",
                formatC(binSize,big.mark=",",drop0trailing=T,format="f"),"bp"),lettercex=0.75)
}
dev.off()

}





# library(ggbio)
# myCols<-brewer.pal(7,"Accent")
#
# genomeGR<-GRanges(seqnames=seqnames(Celegans),ranges=IRanges(start=1,end=seqlengths(Celegans)),strand="*")
#
# # create link object
# bMid<-resize(b,fix="center",width=1)
# links<-bMid[m4plot$Var1]
# mcols(links)$toGR<-bMid[m4plot$Var2]
# mcols(links)$numContacts<-m4plot$value
#
#
# refLink<-105
# ol<-findOverlaps(b[refLink],links)
# refLinks<-links[subjectHits(ol)]
# refLinks<-refLinks[-refLink]
#
#
# seqlengths(genomeGR)<-seqlengths(Celegans)
# ggbio()+circle(genomeGR,geom="ideo",fill="grey70") +
#   circle(genomeGR,geom="scale",size=0.05) +
#   circle(genomeGR,geom="text",aes(label = seqnames),vjust=0,size=5) +
#   circle(refLinks, geom = "link", linked.to = "toGR", aes(color = log(numContacts,10),
#                     size = log(numContacts,10)/max(log(numContacts,10))),radius = 30) +
#   scale_color_gradient(low=alpha("yellow",0.9),high=alpha("red2",0.9)) +
#   labs( colour="log(#contacts") + guides(size=FALSE)
#
# # create bedpe file
# bedpe<-data.frame(chrom1=seqnames(gr1), start1=start(gr1), end1=end(gr1),
#                   chrom2=seqnames(gr2), start2=start(gr2), end2=end(gr2),
#                   name=NA, score=1,strand1=strand(gr1),strand2=strand(gr2),sampleNumber=1)
#
# write.table(bedpe,filename=paste0(path,"contacts_hopGt500.bedpe"),quote=F,row.names=F)
#
#
# pbpe = plotBedpe(bedpe,chromstart=binBreaks[chrStarts[i]],chromend,
#                    heights = Sushi_5C.bedpe$score,plottype="loops",colorby=Sushi_5C.bedpe$samplenumber,
#                  colorbycol=SushiColors(3))
# labelgenome(chrom, chromstart,chromend,n=3,scale="Mb")
# legend("topright",inset =0.01,legend=c("K562","HeLa","GM12878"),
#        col=SushiColors(3)(3),pch=19,bty='n',text.font=2)
# axis(side=2,las=2,tcl=.2)
# mtext("Z-score",side=2,line=1.75,cex=.75,font=2)
