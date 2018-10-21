library(data.table)
library(Hmisc)
library(dplyr)
library(VIM)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
ar.rate.orig <- fread(file.path(path.output,"ar_rate_5_minus.csv"))
cr.rate.org <- fread(file.path(path.output,"cr_rate_1_clean.csv"))
moviepool <- fread(file.path(path.output,"moviepool.csv"))
describe(cr.rate.moviesub)

ar.rate.moviesub <- inner_join(ar.rate.orig,moviepool,by="MID")
cr.rate.moviesub <- inner_join(cr.rate.org,moviepool,by="MID")
fix(ar.rate.moviesub)
#trans mid to sid
original.movietable <- fread(file.path(path.input,"original.csv"))
smidpool <- data.frame(SID = original.movietable$id, MID = original.movietable$rtID)
rm(original.movietable)
fix(smidpool)
moviepool <- moviepool[,ID := 1:2554]
moviepool <- left_join(moviepool, smidpool, by = "MID")
movieid_mid <- unique(moviepool[,1:2])
describe(moviepool)

#trans cr ar table mid
rm(ar.rate.orig)
rm(cr.rate.org)
ar.rate.idtrans <- left_join(ar.rate.moviesub,movieid_mid,by="MID")
cr.rate.idtrans <- left_join(cr.rate.moviesub,movieid_mid,by="MID")

#generate input datasets
ar.rate <- fread(file.path(path.output,"ar_rate_7_idtrans.csv"))
cr.rate <- fread(file.path(path.output,"cr_rate_3_idtrans.csv"))
ar.rate <- ar.rate[,c(2:4):=NULL]
ar.rate <- ar.rate[,2:=NULL]
ar.rate <- ar.rate[,MID:=NULL]
fix(ar.rate)
describe(ar.rate_date)
Sys.setlocale('LC_TIME', "C")
ar.rate_date <- data.frame(Date = as.Date(ar.rate$Date,format = "%d-%b-%y"))
ar.rate$Date <- ar.rate_date$Date
fix(ar.rate)
ar.rate <- ar.rate[,-7]

cr.rate[,c("MID","Index_sub"):=NULL]
setnames(cr.rate,"ID","MID")
criticstable <- data.table(UID = unique(cr.rate$UID))
criticstable[,ID := 1:3165]
describe(criticstable)
cr.rate <- left_join(cr.rate, criticstable, by="UID")
cr.rate <- cr.rate[,-2]
setnames(cr.rate, "ID", "UID")
setnames(cr.rate,"V1", "Index")
cr.rate_date <- data.frame(Date = as.Date(cr.rate$Date, format = "%Y/%m/%d" ))
cr.rate$Date <- cr.rate_date$Date
describe(cr.rate)
describe(ar.rate)
write.csv(cr.rate,file.path(path.output,"cr_rate_4_input.csv"),row.names = F)
