library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
mtframe <- fread(file.path(path.output,"ar_moviedate_frame.csv"))
ar.aggr<- fread(file.path(path.output,"ar_aggr_11_input.csv"))
ar.aggr.sub <- cbind(ar.aggr[,c(2:9)],ar.aggr[,c(20:23)])
rm(ar.aggr)
ar.aggr <- ar.aggr.sub
rm(ar.aggr.sub)
#time move
mtframe$Date <- as.Date(mtframe$Date)
mtframe$Date <- mtframe$Date-1
ar.aggr$Date <- as.Date(ar.aggr$Date)
ar.aggr <- full_join(ar.aggr,mtframe,by = c("MID","Date"))
ar.aggr <- impute(ar.aggr,0)
class(ar.aggr) <- "data.frame"
write.csv(ar.aggr,file.path(path.output,"ar_aggr_12_dateminusplus.csv"),row.names = F)
ar.aggr <- ar.aggr[order(ar.aggr$MID,ar.aggr$Date),]
describe(ar.aggr)
attach(ar.aggr)

## remath cum
aggr.cumsum <- aggregate(sum_rate~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, sum_rate_cum = melt(aggr.cumsum$sum_rate)[,1])
aggr.countrate <-aggregate(count_rate~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, count_rate_cum = melt(aggr.countrate$count_rate)[,1])
ar.aggr <- cbind(ar.aggr, ar_avg = ar.aggr$sum_rate_cum/ar.aggr$count_rate_cum)
aggr.countrate35 <-aggregate(count_35~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, count_rate35_cum = melt(aggr.countrate35$count_35)[,1])

aggr.cumsum_wt <- aggregate(count_wt~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, count_wt_cum = melt(aggr.cumsum_wt$count_wt)[,1])
aggr.cumsum_ni <- aggregate(count_ni~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, count_ni_cum = melt(aggr.cumsum_ni$count_ni)[,1])

aggr.cumsum_vol <- aggregate(volume_day~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, volume_cum = melt(aggr.cumsum_vol$volume_day)[,1])

##math audience score
audiencescore = data.frame(Ascore = (ar.aggr$count_rate35_cum+ar.aggr$count_wt_cum)/ar.aggr$volume_cum)
describe(audiencescore)
audiencescore = cbind(audiencescore, Alabel = ifelse(ar.aggr$count_rate_cum>0,ifelse(ar.aggr$count_rate35_cum/ar.aggr$count_rate_cum>=0.6,1,2),3))
audiencescore = cbind(audiencescore, wtsodd = ar.aggr$count_wt_cum/(ar.aggr$count_wt_cum+ar.aggr$count_ni_cum))

ar.aggr <- cbind(ar.aggr,audiencescore)
rm(aggr.countrate,aggr.countrate35,aggr.cumsum,aggr.cumsum_ni,aggr.cumsum_vol,aggr.cumsum_wt)
##remath sr
aggr.cumsum <- aggregate(SR_sum_rate~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, SR_sum_rate_cum = melt(aggr.cumsum$SR_sum_rate)[,1])

aggr.countrate <-aggregate(SR_count_rate~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, SR_count_rate_cum = melt(aggr.countrate$SR_count_rate)[,1])

ar.aggr <- cbind(ar.aggr, SR_ar_avg = ar.aggr$SR_sum_rate_cum/ar.aggr$SR_count_rate_cum)

aggr.countrate35 <-aggregate(SR_count_35~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, SR_count_rate35_cum = melt(aggr.countrate35$SR_count_35)[,1])

aggr.cumsum_vol <- aggregate(SR_volume_day~MID, FUN = cumsum)
ar.aggr <- cbind(ar.aggr, SR_volume_cum = melt(aggr.cumsum_vol$SR_volume_day)[,1])
describe(ar.aggr[,23:27])

ar.aggr <- impute(ar.aggr,0)
write.csv(ar.aggr,file.path(path.output,"ar_aggr_13_timemove_input.csv"),row.names = F)
detach(ar.aggr)
