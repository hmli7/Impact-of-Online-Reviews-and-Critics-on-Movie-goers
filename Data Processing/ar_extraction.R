library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
ar.rate <- fread(file.path(path.input,"ar_rate_8_input.csv"))

#insight
describe(ar.rate)

#rate subset rate>0 
##sum count avg count rate>=3.5
ar.rate.sub_rate <- subset(ar.rate,ar.rate$Rate>0,select = c("Date","MID","Rate"))
describe(ar.rate.sub_rate)
##pivot
test <- ar.rate.sub_rate[ar.rate.sub_rate$MID%in%c(1,2),]
aggrfun_1 <- function(x) {
  s = sum(x)
  n = length(x)
  c = length(subset(x,x>=3.5))
  return(c(sum_rate = s,count_rate = n,count_35 = c))
}
attach(test)
detach(test)
attach(ar.rate.sub_rate)
ar.aggr.rate.mix <- aggregate(Rate ~ MID+Date,FUN = aggrfun_1)
ar.aggr.rate <- data.frame(MID = ar.aggr.rate.mix$MID, Date = ar.aggr.rate.mix$Date, ar.aggr.rate.mix[["Rate"]])
describe(ar.aggr.rate)

##math rate_avg
detach(ar.rate.sub_rate)
attach(ar.aggr.rate)
ar.aggr.rate <- ar.aggr.rate[order(ar.aggr.rate$MID, ar.aggr.rate$Date),]

aggr.cumsum <- aggregate(sum_rate~MID, FUN = cumsum)
ar.aggr.rate <- cbind(ar.aggr.rate, sum_rate_cum = melt(aggr.cumsum$sum_rate)[,1])
aggr.countrate <-aggregate(count_rate~MID, FUN = cumsum)
ar.aggr.rate <- cbind(ar.aggr.rate, count_rate_cum = melt(aggr.countrate$count_rate)[,1])
ar.aggr.rate <- cbind(ar.aggr.rate, ar_avg = ar.aggr.rate$sum_rate_cum/ar.aggr.rate$count_rate_cum)
aggr.countrate35 <-aggregate(count_35~MID, FUN = cumsum)
ar.aggr.rate <- cbind(ar.aggr.rate, count_rate35_cum = melt(aggr.countrate35$count_35)[,1])

describe(ar.aggr.rate)
write.csv(ar.aggr.rate,file.path(path.output,"ar_aggr_1_rate_cum.csv"),row.names = F)
rm(aggr.cumsum,aggr.countrate)
rm(ar.aggr.rate.mix,ar.rate.sub_rate)
detach(ar.aggr.rate)
#rate subset wts -1 ni -2
##count -1$-2
ar.rate.sub_wn <- subset(ar.rate,ar.rate$Rate%in%c(-1,-2),select = c("Date","MID","Rate"))
describe(ar.rate.sub_wn)
test <- ar.rate.sub_wn[ar.rate.sub_wn$MID%in%c(1,2),]
attach(test)
detach(test)
attach(ar.rate.sub_wn)

aggrfun_2 <- function(x) {
  c1 = length(subset(x,x==-1))
  c2 = length(subset(x,x==-2))
  return(c(count_wt = c1,count_ni = c2))
}
ar.aggr.wn.mix <- aggregate(Rate ~ MID+Date,FUN = aggrfun_2)
ar.aggr.wn <- data.frame(MID = ar.aggr.wn.mix$MID, Date = ar.aggr.wn.mix$Date, ar.aggr.wn.mix[["Rate"]])
##math count_cum
detach(ar.rate.sub_wn)
attach(ar.aggr.wn)
ar.aggr.wn <- ar.aggr.wn[order(ar.aggr.wn$MID, ar.aggr.wn$Date),]

aggr.cumsum_wt <- aggregate(count_wt~MID, FUN = cumsum)
ar.aggr.wn <- cbind(ar.aggr.wn, count_wt_cum = melt(aggr.cumsum_wt$count_wt)[,1])
aggr.cumsum_ni <- aggregate(count_ni~MID, FUN = cumsum)
ar.aggr.wn <- cbind(ar.aggr.wn, count_ni_cum = melt(aggr.cumsum_ni$count_ni)[,1])
describe(ar.aggr.wn)
write.csv(ar.aggr.wn,file.path(path.output,"ar_aggr_2_wn_cum.csv"),row.names = F)
rm(aggr.cumsum_ni,aggr.cumsum_wt)
rm(ar.aggr.wn.mix,ar.rate.sub_wn)


detach(ar.aggr.wn)
#count rate+wtsni
##subset rate>-3
##aggregate length(rate)
ar.rate.sub_null <- subset(ar.rate,ar.rate$Rate>-3,select = c("Date","MID","Rate"))
describe(ar.rate.sub_null)
attach(ar.rate.sub_null)
ar.aggr.volume.mix <- aggregate(Rate ~ MID+Date,FUN = length)
ar.aggr.volume <- data.frame(MID = ar.aggr.volume.mix$MID, Date = ar.aggr.volume.mix$Date, volume_day = ar.aggr.volume.mix[["Rate"]])
fix(ar.aggr.volume)
ar.aggr.volume <- ar.aggr.volume[order(ar.aggr.volume$MID, ar.aggr.volume$Date),]
detach(ar.rate.sub_null)
attach(ar.aggr.volume)
aggr.cumsum_vol <- aggregate(volume_day~MID, FUN = cumsum)
ar.aggr.volume <- cbind(ar.aggr.volume, volume_cum = melt(aggr.cumsum_vol$volume_day)[,1])
describe(ar.aggr.volume)
write.csv(ar.aggr.volume,file.path(path.output,"ar_aggr_3_vol_cum.csv"),row.names = F)
rm(aggr.cumsum_vol,ar.aggr.volume.mix,ar.rate.sub_null)
detach(ar.aggr.volume)
#combination
ar.aggr <- full_join(ar.aggr.volume,ar.aggr.rate,by=c("MID","Date"))
ar.aggr <- full_join(ar.aggr, ar.aggr.wn,by=c("MID","Date"))
describe(ar.aggr)
write.csv(ar.aggr,file.path(path.output,"ar_aggr_4_combination.csv"),row.names = F)
str(ar.aggr)

# dealing missing value -> math cum after combination
ar.aggr.sub <- subset(ar.aggr,select = c("MID","Date","volume_day","sum_rate","count_rate","count_35","count_wt","count_ni"))
ar.aggr.sub <- ar.aggr.sub[order(ar.aggr.sub$MID,ar.aggr.sub$Date),]
describe(ar.aggr.sub)
ar.aggr.sub_ad <- impute(ar.aggr.sub,0)
write.csv(ar.aggr.sub_ad, file.path(path.output,"ar_aggr_5_subimpute.csv"),row.names = F)
describe(ar.aggr.sub_ad)

## remath cum
class(ar.aggr.sub_ad) <- "data.frame"
ar.aggr.sub_ad <- ar.aggr.sub_ad[order(ar.aggr.sub_ad$MID,ar.aggr.sub_ad$Date),]
attach(ar.aggr.sub_ad)
aggr.cumsum <- aggregate(sum_rate~MID, FUN = cumsum)
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, sum_rate_cum = melt(aggr.cumsum$sum_rate)[,1])
aggr.countrate <-aggregate(count_rate~MID, FUN = cumsum)
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, count_rate_cum = melt(aggr.countrate$count_rate)[,1])
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, ar_avg = ar.aggr.sub_ad$sum_rate_cum/ar.aggr.sub_ad$count_rate_cum)
aggr.countrate35 <-aggregate(count_35~MID, FUN = cumsum)
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, count_rate35_cum = melt(aggr.countrate35$count_35)[,1])

aggr.cumsum_wt <- aggregate(count_wt~MID, FUN = cumsum)
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, count_wt_cum = melt(aggr.cumsum_wt$count_wt)[,1])
aggr.cumsum_ni <- aggregate(count_ni~MID, FUN = cumsum)
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, count_ni_cum = melt(aggr.cumsum_ni$count_ni)[,1])

aggr.cumsum_vol <- aggregate(volume_day~MID, FUN = cumsum)
ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad, volume_cum = melt(aggr.cumsum_vol$volume_day)[,1])

##math audience score
audiencescore = data.frame(Ascore = (ar.aggr.sub_ad$count_rate35_cum+ar.aggr.sub_ad$count_wt_cum)/ar.aggr.sub_ad$volume_cum)
describe(audiencescore)
audiencescore = cbind(audiencescore, Alabel = ifelse(ar.aggr.sub_ad$count_rate_cum>0,ifelse(ar.aggr.sub_ad$count_rate35_cum/ar.aggr.sub_ad$count_rate_cum>=0.6,1,2),3))
audiencescore = cbind(audiencescore, wtsodd = ar.aggr.sub_ad$count_wt_cum/(ar.aggr.sub_ad$count_wt_cum+ar.aggr.sub_ad$count_ni_cum))

ar.aggr.sub_ad <- cbind(ar.aggr.sub_ad,audiencescore)

write.csv(ar.aggr.sub_ad,file.path(path.output,"ar_aggr_7_mathscore.csv"),row.names = F)

describe(ar.aggr.sub_ad)
str(ar.aggr.sub_ad)
detach(ar.aggr.sub_ad)
#sr rate subset rate>0

#sr rate subwts