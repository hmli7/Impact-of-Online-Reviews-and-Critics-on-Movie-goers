library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
cr.rate <- fread(file.path(path.input,"cr_rate_4_input.csv"))

#dealing general
##generate subset to math rate
cr.rate.rate <- subset(cr.rate,Rate_conv!="Null",select = c("Date","MID","Rate_conv"))
cr.rate.rate$Rate_conv <- as.numeric(cr.rate.rate$Rate_conv)
describe(cr.rate.rate$Rate_conv)
cr.rate.rate <- subset(cr.rate.rate, Rate_conv!=0)
describe(cr.rate.rate)
fix(cr.rate.rate)
##convert rate to dec
cr.rate.rate$Rate <- cr.rate.rate$Rate*10

##pivot
aggrfun <- function(x) {
  s = sum(x)
  n = length(x)
  return(c(Sum_short = s,Count = n))
}
attach(cr.rate.rate)
cr.aggr.rate.mix <- aggregate(Rate ~ MID+Date,FUN = aggrfun)
cr.aggr.rate <- data.frame(MID = cr.aggr.rate.mix$MID, Date = cr.aggr.rate.mix$Date, cr.aggr.rate.mix[["Rate"]])

##generate cr_avg
cr.rate_cravg <- cr.aggr.rate$Sum_short/cr.aggr.rate$Count
cr.aggr.rate <- data.frame(cr.aggr.rate, cr_avg = cr.rate_cravg)
##minus volume<5
cr.aggr.rate <- data.frame(cr.aggr.rate, cr_avg_display = ifelse(cr.aggr.rate[["Count"]]<5,NA,cr.aggr.rate$cr_avg))

##fresh
cr.rate.fresh <- data.frame(cr.rate[,c("Fresh","Date","MID")])
##pivot
aggrfun_2 <- function(x) {
  c = sum(x)
  n = length(x)
  return(c(count_fresh = c,count_whole = n))
}

attach(cr.rate.fresh)
cr.aggr.fresh.mix <- aggregate(Fresh ~ MID+Date,FUN = aggrfun_2)
head(cr.aggr.fresh.mix)
cr.aggr.fresh <- data.frame(MID = cr.aggr.fresh.mix$MID, Date = cr.aggr.fresh.mix$Date, cr.aggr.fresh.mix[["Fresh"]])

Tomatometer <- cr.aggr.fresh$count_fresh/cr.aggr.fresh$count_whole
cr.aggr.fresh <- cbind(cr.aggr.fresh, Tomatometer)

cr.aggr <- full_join(cr.aggr.fresh,cr.aggr.rate, by=c("MID","Date"))

#dealing top
cr.rate.top <- subset(cr.rate,Top==1)
##generate subset to math rate
cr.top.rate <- subset(cr.rate.top,Rate_conv!="Null",select = c("Date","MID","Rate_conv"))
cr.top.rate$Rate_conv <- as.numeric(cr.top.rate$Rate_conv)
describe(cr.top.rate$Rate_conv)
cr.top.rate <- subset(cr.top.rate, Rate_conv!=0)
describe(cr.top.rate)
fix(cr.top.rate)
##convert rate to dec
cr.top.rate$Rate <- cr.top.rate$Rate*10

##pivot
aggrfun <- function(x) {
  s = sum(x)
  n = length(x)
  return(c(Sum_short = s,Count = n))
}
attach(cr.top.rate)
cr.aggr.top.rate.mix <- aggregate(Rate ~ MID+Date,FUN = aggrfun)
cr.aggr.top.rate <- data.frame(MID = cr.aggr.top.rate.mix$MID, Date = cr.aggr.top.rate.mix$Date, cr.aggr.top.rate.mix[["Rate"]])
fix(cr.aggr.top.rate)
describe(cr.aggr.top.rate)
##generate cr_avg
cr.top.rate_cravg <- cr.aggr.top.rate$top_Sum_rate/cr.aggr.top.rate$top_Count_rate
cr.aggr.top.rate <- data.frame(cr.aggr.top.rate, top_cr_avg = cr.top.rate_cravg)
##minus volume<5
cr.aggr.top.rate <- data.frame(cr.aggr.top.rate, top_cr_avg_display = ifelse(cr.aggr.top.rate[["top_Count_rate"]]<5,NA,cr.aggr.top.rate$top_cr_avg))
describe(cr.aggr.top.rate)


##fresh
cr.top.rate.fresh <- data.frame(cr.rate.top[,c("Fresh","Date","MID")])
##pivot
aggrfun_2 <- function(x) {
  c = sum(x)
  n = length(x)
  return(c(count_fresh = c,count_whole = n))
}

attach(cr.top.rate.fresh)
cr.aggr.top.fresh.mix <- aggregate(Fresh ~ MID+Date,FUN = aggrfun_2)
head(cr.aggr.top.fresh.mix)
cr.aggr.top.fresh <- data.frame(MID = cr.aggr.top.fresh.mix$MID, Date = cr.aggr.top.fresh.mix$Date, cr.aggr.top.fresh.mix[["Fresh"]])

top_Tomatometer <- cr.aggr.top.fresh$count_fresh/cr.aggr.top.fresh$count_whole
cr.aggr.top.fresh <- cbind(cr.aggr.top.fresh, top_Tomatometer)

describe(cr.aggr.top.fresh)
fix(cr.aggr.top.fresh)

cr.aggr.top <- full_join(cr.aggr.top.fresh,cr.aggr.top.rate, by=c("MID","Date"))
fix(cr.aggr.top)
cr.aggr.whole <- full_join(cr.aggr, cr.aggr.top,by=c("MID","Date"))













searchpaths()
fix(cr.aggr.whole)
rm(cr.aggr.top.fresh.mix)
describe(cr.aggr.whole)
write.csv(cr.aggr.whole,file.path(path.output,"cr_aggr_whole_1.csv"),row.names = F)

head(melt(cr.rate))
