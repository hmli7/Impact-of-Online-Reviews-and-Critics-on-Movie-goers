library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
library(reshape2)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
ar.ml <- fread(file.path(path.input,"Movielens_ratings.csv"))
ar.ml <- ar.ml[,2:4]
colnames(ar.ml)<-c("mlID","Rate","timestamp")
idtable <- fread(file.path(path.input,"movieID.csv"))
ar.rate <- fread(file.path(path.input,"ar_rate_8_input.csv"))

# list movie and date pool
movietime <- unique(subset(ar.rate,select = c("MID","Date")))
movietime <- movietime[order(movietime$MID,movietime$Date),]
write.csv(movietime,file.path(path.output,"MID_Date_table_ar.csv"),row.names = F)
describe(ar.ml)
describe(movietime$Date)
movietime <- left_join(movietime,idtable[,2:3],by = "MID")
#convert time format to date and subset
date.ml <- ar.ml$timestamp
class(ar.ml$timestamp) <- c('POSIXt','POSIXct')
ar.ml$timestamp <- as.Date(ar.ml$timestamp)
colnames(ar.ml)<-c("mlID","Rate","Date")
#subset
movietime$Date <- as.Date(movietime$Date)
movietime.mlID <- subset(movietime,select = c("MID","mlID"))
ar.ml.sub <- subset(ar.ml,ar.ml$mlID %in% unique(movietime$mlID))
# ar.ml.sub <- left_join(ar.ml.sub,movietime.mlID,by = "mlID")
attach(ar.ml.sub)
aggrfun_1 <- function(x) {
  s = sum(x)
  n = length(x)
  c = length(subset(x,x>=3.5))
  return(c(sum_rate = s,count_rate = n,count_35 = c))
}
ml.aggr.mix <- aggregate(Rate ~ mlID+Date,FUN = aggrfun_1)
ml.aggr <- data.frame(ml.aggr.mix, ml.aggr.mix[["Rate"]])
ml.aggr <- ml.aggr[,-3]
ml.aggr <- left_join(ml.aggr,movietime.mlID,by="mlID")

describe(ml.aggr)
write.csv(ml.aggr,file.path(path.output,"Movielens_aggr_1.csv"),row.names = F)
write.csv(ar.ml.sub,file.path(path.output,"Movielens_aggr_0_subbymovie.csv"),row.names = F)

#change movielens id name to mlID
ml.aggr <- fread(file.path(path.output,"Movielens_aggr_1.csv"))
movietime<-fread(file.path(path.output,"MID_Date_table_ar.csv"))
idtable <- fread(file.path(path.input,"movieID.csv"))
idtable <- idtable[,-1]
ml.aggr <- left_join(ml.aggr,idtable,by="mlID")
ml.aggr <- ml.aggr[,-1]
describe(ml.aggr)
write.csv(ml.aggr,file.path(path.output,"Movielens_aggr_3_sub2000.csv"),row.names = F)

fix(ml.aggr)
##sub to 2000
ml.aggr <- subset(ml.aggr,ml.aggr$Date>"2001-02-18")
#convert movie id to mid


#aggr