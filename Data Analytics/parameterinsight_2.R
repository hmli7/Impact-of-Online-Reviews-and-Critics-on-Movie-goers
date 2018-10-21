library(data.table)
library(Hmisc)
library(dplyr)
library(tidyr)
library(VIM)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(caret)
library(fpc)#culculate kmeans lunkuozhi

path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
user.model <- fread(file.path(path.output,"user_info_model.csv"))
user.rate <- fread(file.path(path.input,"model_input_rate.csv"))
userlist <- fread(file.path(path.input,"ar_rate_input_userlist.csv"))
user.rate.predict <- fread(file.path(path.input,"result.csv"))
user.rate <- cbind(userlist,user.rate)
user.cluster <- left_join(user.rate, user.model, by = "UID")

write.csv(user.cluster, file.path(path.output,"user_info_rate_cluster.csv"),row.names = F)

#cluster


# k取2到8，评估K
K <- 2:8
round <- 30 # 每次迭代30次，避免局部最优
distance <- dist(user.rate.predict)
rst <- sapply(K, function(i){
  print(paste("K=",i))
  mean(sapply(1:round,function(r){
    print(paste("Round",r))
    result <- kmeans(user.rate.predict, i)
    stats <- cluster.stats(distance, result$cluster)
    stats$avg.silwidth
  }))
})
plot(K,rst,type='l',main='轮廓系数与K的关系', ylab='轮廓系数')

model.kmeans <- kmeans(user.cluster[,2:2192],2)
model.kmeans.pred <- kmeans(user.rate.predict,2)
# model.kmeans
plot(user.cluster[c("cr","ar")],col=model.kmeans$cluster) #画出
plot(user.cluster[c("cr","ar")],col=model.kmeans.pred$cluster) #画出
plot(model.kmeans$cluster)
# summary(model.kmeans$cluster)
# table(user.cluster$ar,model.kmeans$cluster)
user.model.clst <- cbind(user.model, model.kmeans$cluster)
colnames(user.model.clst)[20] <- "cluster"
user.model.clst$cluster <- as.factor(user.model.clst$cluster)
summary(user.model.clst$cluster)
o <- order(model.kmeans.pred$cluster)
user.model.clst <- cbind(user.model.clst[o], model.kmeans.pred$cluster[o])
colnames(user.model.clst)[21] <- "cluster_2"
user.model.clst$cluster <- as.factor(user.model.clst$cluster_2)
summary(user.model.clst$cluster_2)
plot(user.model.clst$cluster_2)
model.centers <- model.kmeans.pred$centers
subset(user.model.clst,user.model.clst$cluster_2 == 1&user.model.clst$cr>0.5)
#0.5 is the cutline
model.centers <- as.data.frame(t(model.centers))
write.csv(model.centers, file.path(path.output, "model_centers.csv"),row.names = F)
#movie genre
movielist <- fread(file.path(path.input,"movieinfo_sample_2.csv"))
movieid <- fread(file.path(path.input,"movieID.csv"))
moviegenre <- fread(file.path(path.input,"movieGenre.csv"))
movielist <- movielist[,-c(2,3,4)]
model.centers <- cbind(movielist, model.centers)

movieinfo <- left_join(movielist, movieid, by = "MID")
movieinfo <- left_join(movieinfo, moviegenre, by = "mlID")
sum(duplicated(cbind(movieinfo$MID, movieinfo$genre)))
movieinfo <- movieinfo[!duplicated(cbind(movieinfo$MID, movieinfo$genre)),]
write.csv(movieinfo, file.path(path.output,"movie_sample_genreinfo.csv"),row.names = F)
movieinfo.short <- movieinfo[,-c(2,3)]
rm(movieinfo)
#
model.centers <- left_join(model.centers, movieinfo.short, by = "MID")
model.centers.aggr <- aggregate(cbind(model.centers$`1`,model.centers$`2`)~model.centers$genre, FUN = mean)
write.csv(model.centers.aggr, file.path(path.output, "model_centers_genre.csv"),row.names = F)


#insights
mean(model.centers$`2`)
colnames(model.centers.aggr)[1] <- "genre"
model.centers.aggr$genre <- as.factor(model.centers.aggr$genre)
model.centers.aggr[order(-model.centers.aggr$V1),][["genre"]]
model.centers.aggr[order(-model.centers.aggr$V2),][["genre"]]

plot <- ggplot(model.centers.aggr[order(-model.centers.aggr$V1),], aes(x = genre, y = V1))+
  geom_point()
plot
