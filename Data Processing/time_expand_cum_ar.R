library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
mtframe <- fread(file.path(path.output,"ar_moviedate_frame.csv"))
ar.aggr<- fread(file.path(path.output,"ar_aggr_10_whole.csv"))
describe(ar.aggr)
ar.aggr <- ar.aggr[,-c(23:27)]
ar.aggr <- impute(ar.aggr,0)
class(ar.aggr) <- "data.frame"
ar.aggr <- ar.aggr[order(ar.aggr$MID,ar.aggr$Date),]
attach(ar.aggr)

##math sr
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
write.csv(ar.aggr,file.path(path.output,"ar_aggr_11_input.csv"))
detach(ar.aggr)
describe(ar.aggr)
str(ar.aggr)
