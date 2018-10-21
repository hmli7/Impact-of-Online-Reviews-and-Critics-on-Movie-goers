library(data.table)
library(Hmisc)
library(dplyr)
library(tidyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
ar.rate<- fread(file.path(path.input,"ar_rate_8_input.csv"))
ar.aggr <- fread(file.path(path.output,"ar_aggr_13_timemove_input.csv"))
cr.aggr <- fread(file.path(path.output,"cr_aggr_whole_5_timemove_input.csv"))
ml.aggr <- fread(file.path(path.output,"Movielens_timeexpand_6_input.csv"))

describe(ar.rate)

#subset to pure rate table
ar.rate.pure <- subset(ar.rate,ar.rate$Rate>0)
write.csv(ar.rate.pure,file.path(path.output,"ar_rate_9_purerate.csv"),row.names = F)
rm(ar.rate)
#test uniqueness
sum(duplicated(cbind(ar.rate.pure$UID,ar.rate.pure$MID)))
ar.rate.pure <- as.data.table(ar.rate.pure)
ar.rate.pure_unique <- unique(ar.rate.pure,by = c("UID","MID"),fromLast = T)
write.csv(ar.rate.pure_unique,file.path(path.output,"ar_rate_10_purerateunique.csv"),row.names = F)
rm(ar.rate.pure)
ar.rate.pure <- ar.rate.pure_unique
rm(ar.rate.pure_unique)
#ar date +1 
ar.aggr$Date <- as.Date(ar.aggr$Date)
ar.aggr$Date <- ar.aggr$Date+1
write.csv(ar.aggr,file.path(path.output,"ar_aggr_14_datemove.csv"),row.names = F)
ar.aggr.lean <- subset(ar.aggr,select = c("Date","MID","volume_cum","Ascore","Alabel","ar_avg"))
rm(ar.aggr)
colnames(ar.aggr.lean) <- c("Date","MID","ar_volume_cum","Ascore","Alabel","ar_avg")
write.csv(ar.aggr.lean,file.path(path.output,"ar_aggr_15_lean.csv"),row.names = F)
#add ar to ar table
ar.rate.pure$Date <- as.Date(ar.rate.pure$Date)
ar.rate.plus <- left_join(ar.rate.pure,ar.aggr.lean,by=c("MID","Date"))
describe(ar.rate.plus)

#cr date +1
cr.aggr$Date <- as.Date(cr.aggr$Date)
cr.aggr$Date <- cr.aggr$Date+1
cr.aggr.lean <- subset(cr.aggr,select = c("Date","MID","count_rate_cum","cr_avg","cr_avg_display","Tomatometer","Tomatometer_label"))
rm(cr.aggr)
colnames(cr.aggr.lean) <- c("Date","MID","cr_volume_cum","cr_avg","cr_avg_display","Tomatometer","Tomatometer_label")
write.csv(cr.aggr.lean,file.path(path.output,"cr_aggr_whole_6_lean.csv"),row.names = F)
#add cr to ar table
ar.rate.plus_2 <- left_join(ar.rate.plus,cr.aggr.lean,by=c("MID","Date"))
describe(ar.rate.plus_2)

#ml date +1
ml.aggr$Date <- as.Date(ml.aggr$Date)
ml.aggr$Date <- ml.aggr$Date+1
ml.aggr.lean <- subset(ml.aggr,select = c("Date","MID","ml_count_rate_cum","ml_ar_avg"))
rm(ml.aggr)
colnames(ml.aggr.lean) <- c("Date","MID","ml_ar_volume_cum","ml_ar_avg")
write.csv(ml.aggr.lean,file.path(path.output,"Movielens_timeexpand_7_lean.csv"),row.names = F)
#add ml to ar table
ar.rate.plus_3 <- left_join(ar.rate.plus_2,ml.aggr.lean,by=c("MID","Date"))
describe(ar.rate.plus_3)
write.csv(ar.rate.plus_3,file.path(path.output,"AR_table_input.csv"),row.names = F)
str(ar.rate.plus_3)
rm(ar.rate.plus,ar.rate.plus_2,cr.aggr.lean,ml.aggr.lean)
rm(ar.aggr.lean,ar.rate.pure)


#generate test table
ar.rate.test <- ar.rate.plus_3[sample(1:dim(ar.rate.plus_3)[1],1000),]
ar.rate.test <- ar.rate.test[,-1]
ar.rate.rate <- data.frame(ar.rate.test$UID,ar.rate.test$MID,ar.rate.test$Rate)
fix(ar.rate.rate)
#generate test input data
ar.input_rate <- spread(ar.rate.rate, MID, Rate, fill = 0 , convert = FALSE, drop = TRUE)

describe(ar.rate.rate)

#generate user table
usertable <- ar.input_rate$UID
ar.input_rate <- ar.input_rate[,-1]
ar.input_rate <- as.numeric(ar.input_rate[])
write.csv(ar.input_rate,file.path(path.output,"model_input_rate_test.csv"),row.names = F)

#generate test sets
ar.input_rate <- data.frame(D1 = c(5,4,1,1,0),D2 = c(3,0,1,0,1),D3 = c(0,0,0,0,5),D4 = c(1,1,5,4,4))
ar.input_ar_avg <- data.frame(D1 = c(3.5,4,1.5,1,0),D2 = c(3.5,0,1.5,0,1),D3 = c(1,0,0.5,2,4.5),D4 = c(1,1.5,5,4.5,2))
ar.input_cr_avg <- data.frame(D1 = c(3,4,2.5,1,0.5),D2 = c(4.5,2,1.5,3,1),D3 = c(1,0,4.5,3,5),D4 = c(1.5,2.5,5,4,3))
write.csv(ar.input_rate,file.path(path.output,"model_input_rate_test.csv"),row.names = F)
write.csv(ar.input_ar_avg,file.path(path.output,"model_input_ar_test.csv"),row.names = F)
write.csv(ar.input_cr_avg,file.path(path.output,"model_input_cr_test.csv"),row.names = F)
