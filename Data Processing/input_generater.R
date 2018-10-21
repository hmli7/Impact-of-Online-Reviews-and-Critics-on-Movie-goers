library(data.table)
library(Hmisc)
library(dplyr)
library(tidyr)
library(VIM)
library(reshape2)
library(ggplot2)
library(ggthemes)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output","Analysis")
ar.rate <- fread(file.path(path.output,"AR_table_input.csv"))

attach(ar.rate)
user.rate = aggregate(Rate ~ UID,FUN = length)
colnames(user.rate) <- c("UID","num_of_rate")
aggrfun_1 <- function(x) {
  s = max(x)
  n = min(x)
  return(c(lastdate = s,firstdate = n))
}
user.date = aggregate(Date ~ UID,FUN = aggrfun_1)
user.date = data.frame(UID = user.date$UID, user.date$Date)
describe(user.date)
plot(user.rate$Rate)
detach(ar.rate)
#insight
attach(user.rate)
ratecount <- aggregate(UID ~ Rate, FUN = length)
detach(user.rate)
colnames(ratecount) <- c("NumberOfRate","UserCount")
qplot(NumberOfRate, UserCount, data = ratecount,geom = c("line","point"))
plot <- ggplot(ratecount, aes(x = NumberOfRate,y = UserCount))
plot <- plot + geom_point(alpha=0.3,size = 3) + 
  geom_line(linetype = "dashed") +
  ggtitle("用户评价次数分布图") +
  # scale_colour_stata()
  theme_stata()
plot
colnames(ratecount) <- c("NumberOfRate","UserCount")
user.date$firstdate <- as.Date(user.date$firstdate)
user.date$lastdate <- as.Date(user.date$lastdate)
user.date <- data.frame(user.date, datelength = user.date$lastdate - user.date$firstdate)
user.date$datelength <- as.numeric(user.date$datelength)
user <- full_join(user.date, user.rate, by = "UID")
write.csv(user,file.path(path.output,"userinfo.csv"),row.names = F)
rm(user.date,user.rate)

attach(user)
rateage = aggregate(UID~datelength,FUN = length)
colnames(rateage) <- c("datelength","usercount")
detach(user)
plot2 = ggplot(rateage, aes(x = datelength, y = usercount))
plot2 = plot2 + geom_point(alpha=0.2,size = 2.5) +
  ggtitle("用户评价历史时长分布图") +
  geom_line(linetype = "dashed") +
  theme_stata()
  # theme_solarized_2()
  # theme_wsj()
plot2
qplot(user$num_of_rate)
describe(user)
user <- cbind(user, Index = rep(1:dim(user)[1],1))




#add sr
ar.rate.subsr <- unique(subset(ar.rate,select = c("UID","SR")))
sum(duplicated(ar.rate.subsr))
user <- left_join(user, ar.rate.subsr,by = "UID")

#subset by numofrate
user.sub <- subset(user,user$num_of_rate>10)
user.sub_2 <- subset(user,user$num_of_rate>=20)
describe(user.sub)
describe(user.sub_2)
write.csv(user,file.path(path.output,"userinfo.csv"),row.names = F)
write.csv(user.sub,file.path(path.output,"userinfo_subrate20.csv"),row.names = F)

#sub insights
attach(user.sub_2)
ratecount_sub <- aggregate(UID ~ num_of_rate, FUN = length)
rateage_sub = aggregate(UID~datelength,FUN = length)
colnames(rateage_sub) <- c("datelength","usercount")
colnames(ratecount_sub) <- c("NumberOfRate","UserCount")
describe(rateage_sub)

detach(user.sub_2)

png(filename = file.path(path.output,"pictures", "3-sub-userratecount.png"),width = 650, height = 550, units = "px")
plot3 <- ggplot(ratecount_sub, aes(x = NumberOfRate,y = UserCount))
plot3 <- plot3 + geom_point(alpha=0.3,size = 3) + 
  geom_line(linetype = "dashed") +
  labs(x = "评价次数", y = "用户数") + 
  ggtitle("大于二十次评价次数的用户评价次数分布图", element_text(size=30)) +
  theme_stata() +
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=14),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = -5))
  # scale_colour_stata()

print(plot3)
dev.off()

png(filename = file.path(path.output,"pictures","sub20", "4-datelength0ratecount.png"),width = 650, height = 550, units = "px",res = NA)
plot4 = ggplot(rateage_sub, aes(x = datelength, y = usercount))
plot4 = plot4 + geom_point(alpha=0.2,size = 2.5) +
  ggtitle("大于二十次评价次数的用户评价历史时长分布图", element_text(size=30)) +
  labs(x = "评价历史（日）", y = "用户数") + 
  geom_line(linetype = "dashed") +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=14),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
# theme_solarized_2()
# theme_wsj()

print(plot4)
dev.off()
#sampling by user

user.sample <- user.sub[sample(1:dim(user.sub)[1],500),]

#sample insights
attach(user.sample)
ratecount_sample <- aggregate(UID ~ num_of_rate, FUN = length)
rateage_sample = aggregate(UID~datelength,FUN = length)
colnames(rateage_sample) <- c("datelength","usercount")
colnames(ratecount_sample) <- c("NumberOfRate","UserCount")

detach(user.sample)

png(filename = file.path(path.output,"pictures","sub20", "5-sub-userrateagecount.png"),width = 650, height = 550, units = "px",res = NA)
plot5 <- ggplot(ratecount_sample, aes(x = NumberOfRate,y = UserCount))
plot5 <- plot5 + geom_point(alpha=0.3,size = 3) + 
  labs(x = "评价次数", y = "用户数") + 
  geom_line(linetype = "dashed") +
  ggtitle("抽样用户评价次数分布图",element_text(size=30)) +
  # scale_colour_stata()
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot5

print(plot5)
dev.off()

png(filename = file.path(path.output,"pictures","sub20", "6-sampleratecountdistri.png"),width = 650, height = 550, units = "px",res = NA)
plot6 = ggplot(rateage_sample, aes(x = datelength, y = usercount))
plot6 = plot6 + geom_point(alpha=0.2,size = 2.5) +
  ggtitle("抽样用户评价历史时长分布图",element_text(size=30)) +
  labs(x = "评价历史（日）", y = "用户数") + 
  
  geom_line(linetype = "dashed") +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
# theme_solarized_2()
# theme_wsj()
plot6

print(plot6)
dev.off()


#generate input table
describe(user.sample)
write.csv(user.sample,file.path(path.output,"userinfo_sample_2.csv"),row.names = F)
rm(userpool,userpool.sample)
user.sample.list <- subset(user.sample,select = c("UID","Index"))
ar.rate.input <- left_join(user.sample.list,ar.rate, by = "UID")
fix(ar.rate.input)#change index to userindex
write.csv(ar.rate.input,file.path(path.output,"ar_rate_input_2.csv"),row.names = F)

#insight into movie
qplot(ar.rate.input$MID)
attach(ar.rate.input)
moviecount <- aggregate(UID~MID, FUN = length)
movieascore <- aggregate(Ascore~MID, FUN = mean)
movietomatometer <- aggregate(Tomatometer~MID, FUN = mean)

movie.sample.info <- left_join(movieascore,moviecount,by = "MID")
movie.sample.info <- left_join(movie.sample.info, movietomatometer,by = "MID")
fix(movie.sample.info)
write.csv(movie.sample.info,file.path(path.output,"movieinfo_sample_2.csv"),row.names = F)
rm(moviecount,movieascore,movietomatometer)
qplot(movie.sample.info$MID,movie.sample.info$Ascore)
qplot(movie.sample.info$MID,movie.sample.info$Tomatometer)

detach(ar.rate.input)

#find movie last date info
attach(ar.rate)
movielastdate <- aggregate(Date~MID, FUN = max)
describe(movielastdate)
str(ar.rate.subinfo)
ar.rate.subinfo[,c("Index","UID"):=NULL]
ar.rate.subinfo[,c("Rate","SR"):=NULL]
movielastdate <- left_join(movielastdate,ar.rate.subinfo,by=c("MID","Date"))
fix(movielastdate)
movielastdate <-unique(movielastdate,by = "MID")
write.csv(movielastdate,file.path(path.output,"movielastdateinfo_whole.csv"),row.names = F)
detach(ar.rate)

attach(movie.sample.info)
countdistri <- aggregate(MID~RateCount,FUN = length)
ascoredistri <- aggregate(MID~Ascore, FUN = length)
Tomatometerdistri <- aggregate(MID~Tomatometer, FUN = length)
fix(countdistri)

png(filename = file.path(path.output,"pictures","sub20", "14-samplemovie_ratecountdis.png"),width = 650, height = 550, units = "px",res = NA)

plot7 = ggplot(countdistri, aes(x = RateCount, y = Amount))
plot7 = plot7 + geom_point(alpha=0.2,size = 2.5) +
  ggtitle("抽样电影评分活跃度分布图",element_text(size=30)) +
  labs(x = "评分数量", y = "电影数") + 
  geom_line(linetype = "dashed") +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))

# theme_solarized_2()
# theme_wsj()
plot7
print(plot7)
dev.off()

png(filename = file.path(path.output,"pictures","sub20", "15-sampemovie_ascoredis.png"),width = 650, height = 550, units = "px",res = NA)
plot8 = ggplot(ascoredistri, aes(x = Ascore, y = Amount))
plot8 = plot8 + geom_point(alpha=0.2,size = 2.5) +
  ggtitle("抽样电影Ascore分布图",element_text(size=30)) +
  labs(x = "Ascore", y = "电影数") + 
  geom_line(linetype = "dashed") +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))

# theme_solarized_2()
# theme_wsj()
plot8
print(plot8)
dev.off()


png(filename = file.path(path.output,"pictures","sub20", "16-samplemovie_tomatometerdis.png"),width = 650, height = 550, units = "px",res = NA)
plot9 = ggplot(Tomatometerdistri, aes(x = Tomatometer, y = Amount))
plot9 = plot9 + geom_point(alpha=0.2,size = 2.5) +
  ggtitle("抽样电影Tomatometer分布图",element_text(size=30)) +
  labs(x = "Tomatometer", y = "电影数") + 
  geom_line(linetype = "dashed") +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))

# theme_solarized_2()
# theme_wsj()
print(plot9)
dev.off()
detach(movie.sample.info)
#sub rate ar cr
ar.rate.rate <- data.frame(UID = ar.rate.input$UID,MID = ar.rate.input$MID,Rate = ar.rate.input$Rate)
ar.rate.ar <- data.frame(UID = ar.rate.input$UID,MID = ar.rate.input$MID,Ascore = ar.rate.input$Ascore)
ar.rate.cr <- data.frame(UID = ar.rate.input$UID,MID = ar.rate.input$MID,Tomatometer = ar.rate.input$Tomatometer)

#insight into ascore and tomatometer
qplot(ar.rate.ar$Ascore)
describe(ar.rate.rate$Rate)
qplot(ar.rate.cr$Tomatometer)
qplot(ar.rate.rate$Rate)
#convert to the same magnitude
ar.rate.ar$Ascore = ar.rate.ar$Ascore * 5
ar.rate.cr$Tomatometer = ar.rate.cr$Tomatometer * 5
# dim(subset(ar.rate.input,ar.rate.input$Ascore>0&ar.rate.input$Tomatometer>0))
#generate input data
ar.input_rate <- spread(ar.rate.rate, MID, Rate, fill = 0)
ar.input_rate.na <- spread(ar.rate.rate,MID,Rate,fill = NA)
ar.input_ascore <- spread(ar.rate.ar, MID, Ascore, fill = NA)
ar.input_Tomatometer <- spread(ar.rate.cr, MID, Tomatometer, fill = NA)
describe(ar.rate.rate)

#generate inputuserlist
ar.input_userlist <- data.frame(UID = ar.input_rate$UID)
write.csv(ar.input_userlist,file.path(path.output,"ar_rate_input_userlist.csv"),row.names = F)

ar.input_rate <- ar.input_rate[,-1]
ar.input_rate.na <- ar.input_rate.na[,-1]
write.csv(ar.input_rate.na, file.path(path.output,"model_input_rate_na.csv"),row.names = F)
#math rate ratio
ar.input_rate_gather = gather(ar.input_rate)
describe(ar.input_rate_gather)

#impute ar cr table
ar.input_ascore <- ar.input_ascore[,-1]
ar.input_Tomatometer <- ar.input_Tomatometer[,-1]
colnamelist <- data.frame(colname = as.numeric(colnames(ar.input_ascore)))
colnamelist2 <- data.frame(colname = as.numeric(colnames(ar.input_Tomatometer)))
dim(full_join(colnamelist,colnamelist2))
rm(colnamelist2)

ar.input_ascore.impute <- ar.input_userlist
ar.input_tomatometer.impute <- ar.input_userlist
for (i in 1:dim(ar.input_ascore)[2]){
  movieid <- colnamelist[i,1]
  insert.ascore <- movielastdate[movielastdate$MID == movieid,][["Ascore"]]*5
  insert.tomatometer <- movielastdate[movielastdate$MID == movieid,][["Tomatometer"]]*5
  ar.input_ascore.impute <- data.frame(ar.input_ascore.impute,a = impute(ar.input_ascore[[paste(movieid)]],insert.ascore))
  ar.input_tomatometer.impute <- data.frame(ar.input_tomatometer.impute,a = impute(ar.input_Tomatometer[[paste(movieid)]],insert.tomatometer))
}
ar.input_ascore.impute <- ar.input_ascore.impute[,-1]
ar.input_tomatometer.impute <- ar.input_tomatometer.impute[,-1]
##change colname
colnames(ar.input_ascore.impute) <- colnamelist$colname
colnames(ar.input_tomatometer.impute) <- colnamelist$colname
describe(ar.input_ascore.impute)



#generate test sets
# ar.input_rate <- data.frame(D1 = c(5,4,1,1,0),D2 = c(3,0,1,0,1),D3 = c(0,0,0,0,5),D4 = c(1,1,5,4,4))
# ar.input_ar_avg <- data.frame(D1 = c(3.5,4,1.5,1,0),D2 = c(3.5,0,1.5,0,1),D3 = c(1,0,0.5,2,4.5),D4 = c(1,1.5,5,4.5,2))
# ar.input_cr_avg <- data.frame(D1 = c(3,4,2.5,1,0.5),D2 = c(4.5,2,1.5,3,1),D3 = c(1,0,4.5,3,5),D4 = c(1.5,2.5,5,4,3))
write.csv(ar.input_rate,file.path(path.output,"model_input_rate_2.csv"),row.names = F)
write.csv(ar.input_ascore.impute,file.path(path.output,"model_input_ar_2.csv"),row.names = F)
write.csv(ar.input_tomatometer.impute,file.path(path.output,"model_input_cr_2.csv"),row.names = F)
