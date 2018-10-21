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
movielastinfo <- fread(file.path(path.input,"movielastdateinfo_whole_pls.csv"))
ar.personal <- fread(file.path(path.input,"userinfo.csv"))
#generate user info set based on rate>0
attach(ar.rate)
ar.rate$Date <- as.Date(ar.rate$Date)
ar.personal.count <- aggregate(Index~UID, FUN = length)
colnames(ar.personal.count) <- c("UID","RateCount")
aggrfun <- function(x){
  l <- length(subset(x,x>3.5))
  return(c(RateCount_35 = l))
}
ar.personal.35 <- aggregate(Rate~UID, FUN = aggrfun)
colnames(ar.personal.35) <- c("UID","Rate_35_Count")
ar.personal.avgrate <- aggregate(Rate~UID, FUN = mean)
colnames(ar.personal.avgrate) <- c("UID","Rate_avg")
ar.personal.ascoreavg <- aggregate(Ascore~UID, FUN = mean)
colnames(ar.personal.ascoreavg) <- c("UID","pr_ascore_avg")
ar.personal.tmavg <- aggregate(Tomatometer~UID, FUN = mean)
colnames(ar.personal.tmavg) <- c("UID","pr_tm_avg")
ar.personal.aravg <- aggregate(ar_avg~UID, FUN = mean)
colnames(ar.personal.aravg) <- c("UID","pr_ar_avg")
ar.personal.cravg <- aggregate(cr_avg~UID, FUN = mean)
colnames(ar.personal.cravg) <- c("UID","pr_cr_avg")

# ar.personal.startdate <- aggregate(Date~UID, FUN = min)
# colnames(ar.personal.startdate) <- c("UID","date_start")
# ar.personal.lastdate <- aggregate(Date~UID, FUN = max)
# colnames(ar.personal.lastdate) <- c("UID","date_last")

# ar.personal.sr <- data.frame(unique(cbind(ar.rate$UID,ar.rate$SR)))
# ar.personal.sr <- as.data.table(ar.personal.sr)
# ar.personal.sr <- data.frame(unique(ar.personal.sr,by = "UID", fromLast = T))
# describe(ar.personal.sr)
ar.personal <- full_join(ar.personal, ar.personal.avgrate,by = "UID")
ar.personal <- full_join(ar.personal,ar.personal.count,by = "UID")
ar.personal <- full_join(ar.personal,ar.personal.35,by = "UID")
ar.personal <- full_join(ar.personal,ar.personal.ascoreavg,by = "UID")
ar.personal <- full_join(ar.personal,ar.personal.tmavg,by = "UID")
ar.personal <- full_join(ar.personal,ar.personal.aravg,by = "UID")
ar.personal <- full_join(ar.personal,ar.personal.cravg,by = "UID")
# ar.personal <- full_join(ar.personal,ar.personal.startdate,by = "UID")
# ar.personal <- full_join(ar.personal,ar.personal.lastdate,by = "UID")
# ar.personal <- full_join(ar.personal,ar.personal.sr,by = "UID")
rm(ar.personal.35,ar.personal.aravg,ar.personal.ascoreavg,ar.personal.ascoreavg,ar.personal.avgrate,ar.personal.count,ar.personal.cravg,ar.personal.cravg,ar.personal.tmavg)

describe(ar.rate$UID)
ar.personal.clean <- ar.personal[!duplicated(ar.personal.clean$UID),]
ar.personal.sub <- ar.personal[complete.cases(ar.personal.clean),]

sum(duplicated(ar.personal.clean$UID))

describe(cr.personal)
fix(ar.personal)
write.csv(ar.personal, file.path(path.output,"audience_userinfo.csv"),row.names = F)
write.csv(ar.personal.sub, file.path(path.output,"audience_userinfo_short.csv"),row.names = F)
rm(ar.personal,ar.personal.clean)
detach(ar.rate)

#insight 
# plot pair
panel.cor <- function(x, y, digits=2, prefix="", cex.cor, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y, use="complete.obs"))
  txt <- format(c(r, 0.123456789), digits=digits)[1]
  txt <- paste(prefix, txt, sep="")
  if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex =  cex.cor * (1 + r) / 2)
}

panel.hist <- function(x, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks
  nB <- length(breaks)
  y <- h$counts
  y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="white", ...)
}

panel.lm <- function (x, y, col = par("col"), bg = NA, pch = par("pch"),
                      cex = 1, col.smooth = "red", ...) {
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)
  abline(stats::lm(y ~ x),  col = col.smooth, ...)
}

pairs(ar.personal.sub[,c("pr_ascore_avg","pr_tm_avg","pr_Rate_avg","pr_RateCount")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)
pairs(ar.personal.sub[,c("pr_ar_avg","pr_cr_avg","pr_Rate_avg","pr_RateCount")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)
pairs(ar.personal.sub[,c("pr_RateCount","pr_Rate_35_Count","pr_Rate_avg")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)

marginmatrix(movielastinfo[,c("Ascore","Tomatometer")])
marginplot(ar.personal.sub[,c("pr_RateCount","pr_Rate_avg")],main = "pr_RateCount vs. pr_Rate_avg")
ar.personal.sub$pr_SR <- as.factor(ar.personal.sub$pr_SR)
featurePlot(x = ar.personal.sub[,c("pr_RateCount","pr_Rate_35_Count","pr_Rate_avg")], 
            y = ar.personal.sub$pr_SR, 
            plot = "ellipse",
            ## Add a key at the top
            auto.key = list(columns = 2))

plot <- ggplot(ar.personal.sub,aes(x = pr_SR, y=pr_Rate_avg))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "是否为SuperReviewer", y = "生涯平均评分") + 
  ggtitle("SR与非SR的用户生涯平均评分分布",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
#t test
t.test(movielastinfo$Ascore,movielastinfo$Tomatometer,paired = T)
t.test(movielastinfo$ar_avg_2,movielastinfo$cr_avg,paired = T)
t.test(movielastinfo$Ascore,movielastinfo$Tomatometer,paired = T)


#boxplot
as_tm <- melt(data.frame(Ascore = movielastinfo$Ascore, Tomatometer = movielastinfo$Tomatometer))
plot <- ggplot(as_tm,aes(x = factor(variable), y=value))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "评分类别", y = "数值分布") + 
  ggtitle("Ascore vs. Tomatometer",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
as_tm.aov <- aov(as_tm[,2]~as_tm[,1])
summary(as_tm.aov)

ar_cr_avg <- melt(data.frame(用户平均评分 = movielastinfo$ar_avg_2, 专家平均评分 = movielastinfo$cr_avg))
plot <- ggplot(ar_cr_avg,aes(x = factor(variable), y=value))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "评分类别", y = "数值分布") + 
  ggtitle("用户平均评分 vs. 专家平均评分",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
ar_cr_avg.aov <- aov(ar_cr_avg[,2]~ar_cr_avg[,1])
summary(ar_cr_avg.aov)

#about rating amount
pairs(movielastinfo[,c("ar_volume_cum","Ascore","cr_volume_cum","Tomatometer")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)
pairs(movielastinfo[,c("ar_volume_cum","ar_avg_2","cr_volume_cum","cr_avg")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)
pairs(movielastinfo[,c("ml_ar_volume_cum","ml_ar_avg","cr_volume_cum","cr_avg")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)
write.csv(movielastinfo, file.path(path.output,"movielastdateinfo_whole_pls.csv"),row.names = F)

#about frequency
audience_userinfo_short_frequent.csv

plot <- ggplot(user.info,aes(x = Frequent, y=pr_Rate_avg))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "是否为Frequent Reviewer", y = "生涯平均评分") + 
  ggtitle("freq与ifreq的用户生涯平均评分分布",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot

mean(user.info[user.info$Frequent==1,][["pr_Rate_avg"]])#3.16436
mean(user.info[user.info$Frequent==0,][["pr_Rate_avg"]])#3.408508
mean(user.info[user.info$pr_SR==1,][["pr_Rate_avg"]])#3.390494
mean(user.info[user.info$pr_SR==0,][["pr_Rate_avg"]])#3.401469
