library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
movietime<-fread(file.path(path.output,"MID_Date_table_ar.csv"))
ml.aggr<- fread(file.path(path.output,"Movielens_aggr_3_sub2000.csv"))

#expend movielens time and MID 
ml.aggr_expand <- full_join(ml.aggr,movietime,by=c("MID","Date"))
describe(ml.aggr_expand)
#impute
ml.aggr_expand <- ml.aggr_expand[,-length(ml.aggr_expand)]
ml.aggr_expand <- impute(ml.aggr_expand,0)
write.csv(ml.aggr_expand,file.path(path.output,"Movielens_timeexpend_1.csv"))

class(ml.aggr_expand) <- "data.frame"
ml.aggr_expand <- ml.aggr_expand[order(ml.aggr_expand$MID,ml.aggr_expand$Date),]
attach(ml.aggr_expand)
aggr.cumsum <- aggregate(ml_sum_rate~MID, FUN = cumsum)
ml.aggr_expand <- cbind(ml.aggr_expand, ml_sum_rate_cum = melt(aggr.cumsum$ml_sum_rate)[,1])
aggr.countrate <-aggregate(ml_count_rate~MID, FUN = cumsum)
ml.aggr_expand <- cbind(ml.aggr_expand, ml_count_rate_cum = melt(aggr.countrate$ml_count_rate)[,1])
ml.aggr_expand <- cbind(ml.aggr_expand, ml_ar_avg = ml.aggr_expand$ml_sum_rate_cum/ml.aggr_expand$ml_count_rate_cum)
aggr.countrate35 <-aggregate(ml_count_35~MID, FUN = cumsum)
ml.aggr_expand <- cbind(ml.aggr_expand, ml_count_rate35_cum = melt(aggr.countrate35$ml_count_35)[,1])
detach(ml.aggr_expand)
write.csv(ml.aggr_expand,file.path(path.output,"Movielens_timeexpend_2_cum.csv"))

#sub by mtframe
mtframe <- unique(movietime[,1:2])
mtframe <- mtframe[order(mtframe$MID,mtframe$Date),]
write.csv(mtframe,file.path(path.output,"ar_moviedate_frame.csv"),row.names = F)
ml.aggr_expand.sub <- ml.aggr_expand[,-c(2:4)]
ml.aggr_expand.sub <- left_join(mtfre)