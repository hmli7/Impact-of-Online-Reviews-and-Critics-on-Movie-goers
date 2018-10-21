library(data.table)
library(Hmisc)
library(dplyr)
library(tidyr)
library(VIM)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(caret)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
ar.rate <- fread(file.path(path.input,"AR_table_input.csv"))
ar.rate <- fread(file.path(path.output,"ra_rate_lm.csv"))
ar.rate <- data.frame(ar.rate, ar_avg_2 = ar.rate$ar_avg*2)
lm.big <- lm(formula = Rate~ar_volume_cum+cr_volume_cum+ar_avg_2+Ascore+cr_avg_display+Tomatometer,ar.rate)
ar.rate <- data.frame(ar.rate, rate_2 = ar.rate$Rate*2)
ar.rate <- data.frame(ar.rate, Ascore_10 = ar.rate$Ascore*10)
ar.rate <- as.data.table(ar.rate)
ar.rate[,Tomatometer_10:=Tomatometer*10]
lm.big2 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg_2+Ascore_10+cr_avg_display+Tomatometer_10,ar.rate)
summary(lm.big2)
lm.3 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore_10+Tomatometer_10,ar.rate)
lm.3_3 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg_2+cr_avg,ar.rate)
summary(lm.3_3)
corelation <- cor(ar.rate)
ar.rate[,ar_volume_cum_std := scale(ar_volume_cum)]
ar.rate[,cr_volume_cum_std := scale(cr_volume_cum)]
ar.rate[,ar_avg_std := scale(ar_avg)]
ar.rate[,cr_avg_std := scale(cr_avg_display)]
ar.rate[,Ascore_std := scale(Ascore)]
ar.rate[,Tomatometer_std := scale(Tomatometer)]
ar.rate[,Rate_std := scale(Rate)]
lm.4 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate)
lm.4_4 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std+SR,ar.rate)
summary(lm.4_4)
write.csv(ar.rate,file.path(path.output,"ra_rate_lm.csv"),row.names = F)
corelation <- cor(ar.rate[,-(1:21)])
summary(lm.4)
lm.5 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate)
summary(lm.5)
lm.5_5 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std+SR,ar.rate)
summary(lm.5_5)
rm(lm.3,lm.3_3,lm.4,lm.4_4,lm.5,lm.5_5)


ar.rate.sr <- subset(ar.rate, ar.rate$SR==1)
ar.rate.nsr <- subset(ar.rate,ar.rate$SR==0)
qplot(ar.rate$SR)
lm.6 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.sr)
lm.7 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.sr)
lm.8 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.sr)
lm.9 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.sr)

lm.10 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.nsr)

lm.11 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.nsr)
lm.12 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.nsr)
lm.13 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.nsr)

summary(lm.11)
write.csv(corelation,file.path(path.output,"corelation.csv"))
rm(lm.big2,lm.3,lm.4,lm.5,lm.big)
# frequency
ar.personal.sub <- as.data.table(ar.personal.sub)
ar.personal.sub[, Frequent := 0]
ar.personal.sub$Frequent <- as.numeric(ar.personal.sub$Frequent)
ar.personal.sub[order(-ar.personal.sub$pr_num_of_rate),][1:1000][["Frequent"]] <- 1
ar.personal.sub$Frequent <- as.factor(ar.personal.sub$Frequent)
describe(ar.personal.sub$Frequent)
qplot(ar.personal.sub$Frequent)
qplot(ar.personal.sub$pr_SR,ar.personal.sub$Frequent)
marginplot(ar.personal.sub[,c("pr_SR","Frequent")],main = "pr_SR vs. Frequent")
dim(ar.personal.sub[ar.personal.sub$Frequent==1&ar.personal.sub$pr_SR==1,])[1]
#add to ar.rate.table
ar.personal.frequent <- data.frame(UID = ar.personal.sub$UID, prFrequent = ar.personal.sub$Frequent)
write.csv(ar.personal.sub, file.path(path.output,"audience_userinfo_short_frequent.csv"),row.names = F)
ar.rate <- left_join(ar.rate, ar.personal.frequent, by = "UID")
sum(complete.cases(ar.rate))
sum(duplicated(ar.personal.frequent$UID))
ar.rate.lm <- fread(file.path(path.output,"ra_rate_lm.csv"))
ar.personal.sub <- unique(ar.personal.sub, by = "UID")
ar.personal.frequent <- data.frame(UID = ar.personal.sub$UID, prFrequent = ar.personal.sub$Frequent)

rm(ar.rate)
ar.rate <- left_join(ar.rate.lm, ar.personal.frequent, by = "UID")
describe(ar.rate$prFrequent)
describe(ar.rate.lm$Rate_std)
ar.rate[!complete.cases(ar.rate),][["UID"]]
ar.rate.cleanfreq <- ar.rate[complete.cases(ar.rate),]
rm(ar.rate.lm)
rm(ar.personal.frequent)
write.csv(ar.rate.cleanfreq,file.path(path.output,"ra_rate_lm_addfreq.csv"),row.names = F)



describe(ar.rate.cleanfreq$Ascore)

# lm
#overall
ar.rate.cleanfreq <- fread(file.path(path.output,"ra_rate_lm_addfreq.csv"))
lm.5 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std+prFrequent,ar.rate.cleanfreq)
summary(lm.5)
lm.5_5 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std+prFrequent,ar.rate.cleanfreq)
summary(lm.5_5)
#devide
ar.rate.freq <- subset(ar.rate.cleanfreq, ar.rate.cleanfreq$prFrequent==1)
ar.rate.nfreq <- subset(ar.rate.cleanfreq,ar.rate.cleanfreq$prFrequent==0)
qplot(ar.rate$SR)
lm.6 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.freq)
lm.7 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.freq)
lm.8 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.freq)
lm.9 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.freq)

lm.10 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.nfreq)

lm.11 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.nfreq)
lm.12 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.nfreq)
lm.13 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.nfreq)
summary(lm.13)
rm(lm.6, lm.7, lm.8, lm.9, lm.10, lm.11, lm.12, lm.13)

#aggre ar cr
ar.rate.cleanfreq <- as.data.table(ar.rate.cleanfreq)
ar.rate.cleanfreq[, Ascore_round := round(Ascore*100)/100]
ar.rate.cleanfreq[, Tomatometer_round := round(Tomatometer*100)/100]
describe(ar.rate.cleanfreq$Ascore_round)
qplot(ar.rate.cleanfreq$Ascore_round)
ar.rate.cleanfreq$Ascore_round <- as.factor(ar.rate.cleanfreq$Ascore_round)
ar.rate.cleanfreq$Tomatometer_round <- as.factor(ar.rate.cleanfreq$Tomatometer_round)
qplot(ar.rate.cleanfreq$Tomatometer_round)
attach(ar.rate.cleanfreq)
Ascore.aggr <- aggregate(Rate~Ascore_round, FUN = mean)
Tomatometer.aggr <- aggregate(Rate~Tomatometer_round, FUN = mean)
qplot(Ascore.aggr$Ascore_round,Ascore.aggr$Rate)
detach(ar.rate.cleanfreq)
lm.as <- lm(Rate~Ascore_round,Ascore.aggr)
lm.tm <- lm(Rate~Tomatometer_round,Tomatometer.aggr)



eqn.as <- as.character(as.expression(
  substitute(italic(y) == a + b * italic(x) * "," ~~ italic(r)^2 ~ "=" ~ r2,
             list(a = format(coef(lm.as)[1], digits=3),
                  b = format(coef(lm.as)[2], digits=3),
                  r2 = format(summary(lm.as)$r.squared, digits=2)
             ))))

eqn.tm <- as.character(as.expression(
  substitute(italic(y) == a + b * italic(x) * "," ~~ italic(r)^2 ~ "=" ~ r2,
             list(a = format(coef(lm.tm)[1], digits=3),
                  b = format(coef(lm.tm)[2], digits=3),
                  r2 = format(summary(lm.tm)$r.squared, digits=2)
             ))))


plot = ggplot(Ascore.aggr, aes(x = Ascore_round, y = Rate))
plot = plot + geom_point(alpha = 1,size = 1.5, col = "grey60") +
  ggtitle("Ascore vs. 平均评分", element_text(size=30)) +
  labs(x = "Ascore", y = "平均评分") + 
  # geom_line(linetype = "dashed") +
  stat_smooth(method = lm, col = "red")+
  annotate("text", label=eqn.as, parse=TRUE, x=Inf, y=-Inf, hjust=1.1, vjust=-.5)+
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=14),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = -5))
# theme_solarized_2()
# theme_wsj()
plot

plot = ggplot(Tomatometer.aggr, aes(x = Tomatometer_round, y = Rate))
plot = plot + geom_point(alpha = 1,size = 1.5, col = "grey60") +
  ggtitle("Tomatometer vs. 平均评分", element_text(size=30)) +
  labs(x = "Tomatometer", y = "平均评分") + 
  # geom_line(linetype = "dashed") +
  stat_smooth(method = lm, col = "red")+
  annotate("text", label=eqn.tm, parse=TRUE, x=Inf, y=-Inf, hjust=1.1, vjust=-.5)+
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=14),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = -5))
# theme_solarized_2()
# theme_wsj()
plot
