library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
ar.rate.orig <- fread(file.path(path.input,"ar_orig.csv"))
ar.usertable <- fread(file.path(path.input,"usertable.csv"))
describe(ar.rate.orig)
describe(ar.usertable)
ar.usertable <- ar.usertable[!is.na(ar.usertable$UID),]
#clean errors caused by SR
ar.rate.addSR <- left_join(ar.rate.orig,ar.usertable,by="UID")
describe(ar.rate.addSR$Rate)
describe(ar.rate.addSR$Rate[ar.rate.addSR$SR==1])
ar.rate.addSR$Rate[ar.rate.addSR$Rate=='wts'] <- "-1"
ar.rate.addSR$Rate[ar.rate.addSR$Rate=='ni'] <- "-2"
ar.rate.addSR$Rate[ar.rate.addSR$Rate=='Null'] <- "-3"
ar.rate.addSR$Rate <- as.numeric(ar.rate.addSR$Rate)
ar.rate.addSR$Rate[ar.rate.addSR$SR==1] <- ar.rate.addSR$Rate[ar.rate.addSR$SR==1] - 1
ar.rate.lean <- ar.rate.addSR[ar.rate.addSR$Rate!=0,]
describe(ar.rate.lean)

#rm duplicate
# length(ar.rate.lean[duplicated(ar.rate.lean[c("UID","Date","MID","Rate","SR")]),])
ar.rate.short <- ar.rate.lean[,4:8]
Index <- duplicated(ar.rate.short)
ar.rate.minus <- ar.rate.lean[!Index,]
describe(ar.rate.minus)
dim(ar.rate.minus[duplicated(ar.rate.minus[c("UID","Date","MID","Rate","SR")]),])
#sub movies in ar
ar.moviepool <- as.data.frame(unique(ar.rate.minus$MID))
colnames(ar.moviepool) <- "MID"

#load cr_rate
cr.rate.org <- fread(file.path(path.input,"cr_rate_new.csv"))
cr.rate.org <- cr.rate.org[,V8:=NULL]
cr.rate.clean <- as.data.framecr.rate.org[complete.cases(cr.rate.org),]

describe(cr.rate.clean)
cr.moviepool <- as.data.frame(unique(cr.rate.clean$MID))
colnames(cr.moviepool) <- "MID"
#find movie intersection
moviepool <- inner_join(cr.moviepool,ar.moviepool,by="MID")



write.csv(moviepool,file.path(path.output,"moviepool.csv"),row.names=F)
