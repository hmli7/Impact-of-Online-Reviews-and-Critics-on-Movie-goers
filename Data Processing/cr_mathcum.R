
#cumulative
test <- cr.aggr[cr.aggr$MID%in%c(1,2),]
attach(test)
cumfun_1 <- function(x){
  x <- as.data.frame(x)
  print(x[,1])
}
test.cum <- aggregate(sum_rate~MID, FUN = cumsum , na.action=na.omit)
melt(test.cum$sum_rate)
aggregate(sum_rate, list(MID), cumsum, na.action=na.omit)
print(cbind(Date,sum_rate)[,1])

##---non top
#rate

cr.sub.rate <- subset(cr.aggr.whole,is.na(cr.aggr.whole$sum_rate)==FALSE&is.na(cr.aggr.whole$count_rate)==FALSE,select = c("MID", "Date","sum_rate","count_rate"))
describe(cr.sub.rate)
cr.sub.rate <- cr.sub.rate[order(cr.sub.rate$MID, cr.sub.rate$Date),]
attach(cr.sub.rate)
aggr.sumrate <- aggregate(sum_rate~MID, FUN = cumsum)
cr.sub.rate <- cbind(cr.sub.rate, sum_rate_cum = melt(aggr.sumrate$sum_rate)[,1])
aggr.countrate <-aggregate(count_rate~MID, FUN = cumsum)
cr.sub.rate <- cbind(cr.sub.rate, count_rate_cum = melt(aggr.countrate$count_rate)[,1])
cr.sub.rate <- cbind(cr.sub.rate, cr_avg = cr.sub.rate$sum_rate_cum/cr.sub.rate$count_rate_cum)
cr.sub.rate <- cbind(cr.sub.rate, cr_avg_display = ifelse(cr.sub.rate$count_rate_cum<5,NA,cr.sub.rate$cr_avg))
describe(cr.sub.rate)
detach(cr.sub.rate)
write.csv(cr.sub.rate,file.path(path.output,"cr_aggr_cum_1_rate.csv"),row.names = F)

#fresh

cr.sub.fresh <- subset(cr.aggr.whole,is.na(cr.aggr.whole$count_fresh)==FALSE&is.na(cr.aggr.whole$count_whole)==FALSE,select = c("MID", "Date","count_fresh","count_whole"))
describe(cr.sub.fresh)
cr.sub.fresh <- cr.sub.fresh[order(cr.sub.fresh$MID, cr.sub.fresh$Date),]
attach(cr.sub.fresh)
aggr.countfresh <- aggregate(count_fresh~MID, FUN = cumsum)
cr.sub.fresh <- cbind(cr.sub.fresh, count_fresh_cum = melt(aggr.countfresh$count_fresh)[,1])
aggr.countwhole <-aggregate(count_whole~MID, FUN = cumsum)
cr.sub.fresh <- cbind(cr.sub.fresh, count_whole_cum = melt(aggr.countwhole$count_whole)[,1])
cr.sub.fresh <- cbind(cr.sub.fresh, cr_avg = cr.sub.fresh$sum_rate_cum/cr.sub.fresh$count_rate_cum)
cr.sub.fresh <- cbind(cr.sub.fresh,Tomatometer = cr.sub.fresh$count_fresh_cum/cr.sub.fresh$count_whole_cum)
describe(cr.sub.fresh)
detach(cr.sub.fresh)
write.csv(cr.sub.fresh,file.path(path.output,"cr_aggr_cum_2_fresh.csv"),row.names = F)

##top
cr.sub.top <- cr.aggr.whole[,-c(3:9)]
describe(cr.sub.top)
#rate
cr.sub.top.rate <- subset(cr.sub.top,is.na(cr.sub.top$top_sum_rate)==FALSE&is.na(cr.sub.top$top_count_rate)==FALSE,select = c("MID", "Date","top_sum_rate","top_count_rate"))
describe(cr.sub.top.rate)
cr.sub.top.rate <- cr.sub.top.rate[order(cr.sub.top.rate$MID, cr.sub.top.rate$Date),]
attach(cr.sub.top.rate)
aggr.top.sumrate <- aggregate(top_sum_rate~MID, FUN = cumsum)
cr.sub.top.rate <- cbind(cr.sub.top.rate, top_sum_rate_cum = melt(aggr.top.sumrate$top_sum_rate)[,1])
aggr.top.countrate <-aggregate(top_count_rate~MID, FUN = cumsum)
cr.sub.top.rate <- cbind(cr.sub.top.rate, top_count_rate_cum = melt(aggr.top.countrate$top_count_rate)[,1])
cr.sub.top.rate <- cbind(cr.sub.top.rate, top_cr_avg = cr.sub.top.rate$top_sum_rate_cum/cr.sub.top.rate$top_count_rate_cum)
cr.sub.top.rate <- cbind(cr.sub.top.rate, top_cr_avg_display = ifelse(cr.sub.top.rate$top_count_rate_cum<5,NA,cr.sub.top.rate$top_cr_avg))
describe(cr.sub.top.rate)
detach(cr.sub.top.rate)
write.csv(cr.sub.top.rate,file.path(path.output,"cr_aggr_cum_top_1_rate.csv"),row.names = F)

#fresh

cr.sub.top.fresh <- subset(cr.sub.top,is.na(cr.sub.top$top_count_fresh)==FALSE&is.na(cr.sub.top$top_count_whole)==FALSE,select = c("MID", "Date","top_count_fresh","top_count_whole"))
describe(cr.sub.top.fresh)
cr.sub.top.fresh <- cr.sub.top.fresh[order(cr.sub.top.fresh$MID, cr.sub.top.fresh$Date),]
attach(cr.sub.top.fresh)
aggr.top.countfresh <- aggregate(top_count_fresh~MID, FUN = cumsum)
cr.sub.top.fresh <- cbind(cr.sub.top.fresh, top_count_fresh_cum = melt(aggr.top.countfresh$top_count_fresh)[,1])
aggr.top.countwhole <-aggregate(top_count_whole~MID, FUN = cumsum)
cr.sub.top.fresh <- cbind(cr.sub.top.fresh, top_count_whole_cum = melt(aggr.top.countwhole$top_count_whole)[,1])
cr.sub.top.fresh <- cbind(cr.sub.top.fresh,top_Tomatometer = cr.sub.top.fresh$top_count_fresh_cum/cr.sub.top.fresh$top_count_whole_cum)
describe(cr.sub.top.fresh)
detach(cr.sub.top.fresh)
write.csv(cr.sub.top.fresh,file.path(path.output,"cr_aggr_cum_top_2_fresh.csv"),row.names = F)

##attach back to the whole dataset
cr.sub.fresh<-cr.sub.fresh[,-c(3:4)]
cr.aggr.whole.ex <- left_join(cr.aggr.whole,cr.sub.fresh,by=c("MID","Date"))

cr.sub.rate<-cr.sub.rate[,-c(3:4)]
cr.aggr.whole.ex <- left_join(cr.aggr.whole.ex,cr.sub.rate,by=c("MID","Date"))

cr.sub.top.fresh<-cr.sub.top.fresh[,-c(3:4)]
cr.aggr.whole.ex <- left_join(cr.aggr.whole.ex,cr.sub.top.fresh,by=c("MID","Date"))

cr.sub.top.rate<-cr.sub.top.rate[,-c(3:4)]
cr.aggr.whole.ex <- left_join(cr.aggr.whole.ex,cr.sub.top.rate,by=c("MID","Date"))
write.csv(cr.aggr.whole.ex,file.path(path.output,"cr_aggr_whole_2_excum.csv"),row.names = F)
describe(cr.aggr.whole.ex)

# math tomalabel
attach(cr.aggr.whole.ex)
Tomatometer_label <- data.frame(Tomatometer_label = ifelse(cr.aggr.whole.ex$Tomatometer>=0.6,ifelse(cr.aggr.whole.ex$Tomatometer>=0.75&cr.aggr.whole.ex$count_whole_cum>=80&cr.aggr.whole.ex$top_count_whole_cum>=5,1,2),3))
describe(Tomatometer_label)
cr.aggr.whole.ex <- cbind(cr.aggr.whole.ex,Tomatometer_label$Tomatometer_label)
write.csv(cr.aggr.whole.ex,file.path(path.output,"cr_aggr_whole_3_excum_tolabel.csv"),row.names = F)
