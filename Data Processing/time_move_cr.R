library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
mtframe <- fread(file.path(path.output,"ar_moviedate_frame.csv"))
cr.aggr<- fread(file.path(path.output,"cr_aggr_whole_3_excum_tolabel.csv"))
describe(cr.aggr)
str(cr.aggr)
cr.aggr <- cr.aggr[,c(1:14)]
#time move
mtframe$Date <- as.Date(mtframe$Date)
mtframe$Date <- mtframe$Date-1
#time expand
cr.aggr$Date <- as.Date(cr.aggr$Date)
cr.aggr <- full_join(mtframe,cr.aggr, by=c("MID","Date"))
describe(mtframe)
describe(cr.aggr)
cr.aggr <- as.data.table(cr.aggr)
sum(duplicated(cbind(cr.aggr$MID,cr.aggr$Date)))
cr.aggr[,c("cr_avg_display_day","Tomatometer_day","top_Tomatometer_day"):=NULL]
str(cr.aggr)
cr.aggr <- impute(cr.aggr,0)
class(cr.aggr) <- "data.frame"
cr.aggr <- cr.aggr[order(cr.aggr$MID,cr.aggr$Date),]
write.csv(cr.aggr,file.path(path.output,"cr_aggr_whole_4_timeextand_3_timemove.csv"),row.names = F)
describe(cr.aggr$Date)

#normal
attach(cr.aggr)
aggr.cumsum <- aggregate(sum_rate~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, sum_rate_cum = melt(aggr.cumsum$sum_rate)[,1])

aggr.countrate <-aggregate(count_rate~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, count_rate_cum = melt(aggr.countrate$count_rate)[,1])

cr.aggr <- cbind(cr.aggr, cr_avg = cr.aggr$sum_rate_cum/cr.aggr$count_rate_cum)
cr.aggr <- cbind(cr.aggr, cr_avg_display = ifelse(cr.aggr$count_rate_cum<5,0,cr.aggr$cr_avg))

describe(cr.aggr)
##fresh
aggr.countfresh <- aggregate(count_fresh~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, count_fresh_cum = melt(aggr.countfresh$count_fresh)[,1])
aggr.countwhole <-aggregate(count_whole~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, count_whole_cum = melt(aggr.countwhole$count_whole)[,1])
cr.aggr <- cbind(cr.aggr,Tomatometer = cr.aggr$count_fresh_cum/cr.aggr$count_whole_cum)

describe(cr.aggr)
rm(aggr.countfresh,aggr.countrate,aggr.countwhole,aggr.cumsum)
#top
##rate
aggr.cumsum <- aggregate(top_sum_rate~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, top_sum_rate_cum = melt(aggr.cumsum$top_sum_rate)[,1])

aggr.countrate <-aggregate(top_count_rate~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, top_count_rate_cum = melt(aggr.countrate$top_count_rate)[,1])

cr.aggr <- cbind(cr.aggr, top_cr_avg = cr.aggr$top_sum_rate_cum/cr.aggr$top_count_rate_cum)
cr.aggr <- cbind(cr.aggr, top_cr_avg_display = ifelse(cr.aggr$top_count_rate_cum<5,0,cr.aggr$top_cr_avg))

##fresh
aggr.countfresh <- aggregate(top_count_fresh~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, top_count_fresh_cum = melt(aggr.countfresh$top_count_fresh)[,1])
aggr.countwhole <-aggregate(top_count_whole~MID, FUN = cumsum)
cr.aggr <- cbind(cr.aggr, top_count_whole_cum = melt(aggr.countwhole$top_count_whole)[,1])
cr.aggr <- cbind(cr.aggr,top_Tomatometer = cr.aggr$top_count_fresh_cum/cr.aggr$top_count_whole_cum)

#math label
cr.aggr <- impute(cr.aggr,0)
class(cr.aggr) <- "data.frame"
Tomatometer_label <- data.frame(Tomatometer_label = ifelse(cr.aggr$Tomatometer>=0.6,ifelse(cr.aggr$Tomatometer>=0.75&cr.aggr$count_whole_cum>=80&cr.aggr$top_count_whole_cum>=5,1,2),3))
describe(Tomatometer_label)
cr.aggr <- cbind(cr.aggr,Tomatometer_label)
fix(cr.aggr)
describe(cr.aggr)
rm(aggr.countfresh,aggr.countrate,aggr.countwhole,aggr.cumsum)
cr.aggr <- impute(cr.aggr,0)
write.csv(cr.aggr,file.path(path.output,"cr_aggr_whole_5_timemove_input.csv"),row.names = F)

#compare
cr.aggr.orig<- fread(file.path(path.output,"cr_aggr_whole_3_excum_tolabel.csv"))

detach(cr.aggr)
describe(cr.aggr)
str(cr.aggr)


