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
w <- fread(file.path(path.input,"ar_w.csv"))
m <- fread(file.path(path.input,"cr_m.csv"))
w_2 <- fread(file.path(path.input,"ar_w_2.csv"))
m_2 <- fread(file.path(path.input,"cr_m_3.csv"))

user.list <- fread(file.path(path.input,"ar_rate_input_userlist.csv"))
ar.personal <- fread(file.path(path.output,"audience_userinfo_short_frequent.csv"))
user <- data.frame(user.list, cr = m$V1, ar = w$V1, cr_2 = m_2$V1, ar_2 = w_2$V1)
describe(user)
user.info <- left_join(user, ar.personal, by = "UID")
write.csv(user.info, file.path(path.output, "user_info_model.csv"),row.names = F)
qplot(user.info$ar)

t.arcr <- t.test(user.info$cr, user.info$ar)
t.arcr
ar_cr <- melt(data.frame(ar_index = user.info$ar, cr_index = user.info$cr))
plot <- ggplot(ar_cr,aes(x = factor(variable), y=value))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "AR指数和CR指数", y = "数值分布") + 
  ggtitle("ar_index vs. cr_index",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
ar_cr.aov <- aov(ar_cr[,2]~ar_cr[,1])
summary(ar_cr.aov)

describe(user.info$Frequent)
describe(user.info$pr_SR)
dim(user.info[user.info$pr_SR==1&user.info$Frequent==1,])[1]

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = cr, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot
#mf_index
user.info <- as.data.table(user.info)
user.info[, mf_index := (1-ar-cr)]

describe(user.info$mf_index)
qplot(user.info$mf_index)

t.arcr <- t.test(user.info$mf_index, user.info$ar)
t.arcr
ar_cr_mf <- melt(data.frame(ar_index = user.info$ar, cr_index = user.info$cr, mf_index = user.info$mf_index))
plot <- ggplot(ar_cr_mf,aes(x = factor(variable), y=value))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "AR指数 CR指数 MF指数", y = "数值分布") + 
  ggtitle("三指数分布对比",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
ar_cr_mf.aov <- aov(ar_cr_mf[,2]~ar_cr_mf[,1])
summary(ar_cr_mf.aov)

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = mf_index, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

#subdivision user sets
##
user.info.sr <- subset(user.info, user.info$pr_SR == 1)
user.info.isr <- subset(user.info, user.info$pr_SR == 0)
user.info.fm <- subset(user.info, user.info$Frequent == 1)
user.info.ifm <- subset(user.info, user.info$Frequent == 0)
user.info.inormmind <- subset(user.info, user.info$normflag_2 == 0)
user.info.normmind <- subset(user.info, user.info$normflag_2 == 1)

t.test(user.info.sr$cr, user.info.sr$ar)
t.test(user.info.isr$cr, user.info.isr$ar)

t.test(user.info.fm$cr, user.info.fm$ar)
t.test(user.info.ifm$cr, user.info.ifm$ar)

t.test(user.info.normmind$cr, user.info.normmind$ar)
t.test(user.info.inormmind$cr, user.info.inormmind$ar)


## ar cr difference between srisr ariar normalinormal
sr.anova <- aov(user.info$cr~user.info$pr_SR)
summary(sr.anova)
# summary(aov(ar.rate.add$cr~ar.rate.add$SR))

ar.anova <- aov(user.info$ar~user.info$pr_SR)
summary(ar.anova)
##freq
sr.anova <- aov(user.info$cr~user.info$Frequent)
summary(sr.anova)
ar.anova <- aov(user.info$ar~user.info$Frequent)
summary(ar.anova)
##normal
sr.anova <- aov(user.info$cr~user.info$normflag_2)
summary(sr.anova)
ar.anova <- aov(user.info$ar~user.info$normflag_2)
summary(ar.anova)
##graph sr
ar_cr.sub.sr <- melt(data.frame(ar_index = user.info.normmind$ar, cr_index = user.info.normmind$cr, mf_index = user.info.normmind$mf_index))
plot <- ggplot(user.info,aes(x = factor(user.info$pr_SR), y=user.info$ar))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "iSR vs. SR ", y = "ar数值分布") + 
  ggtitle(element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot

plot <- ggplot(user.info,aes(x = factor(user.info$pr_SR), y=user.info$cr))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "iSR vs. SR ", y = "cr数值分布") + 
  ggtitle(element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
##graph freq
plot <- ggplot(user.info,aes(x = factor(user.info$Frequent), y=user.info$ar))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "ifM vs. fM ", y = "ar数值分布") + 
  ggtitle(element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot

plot <- ggplot(user.info,aes(x = factor(user.info$Frequent), y=user.info$cr))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "ifM vs. fM ", y = "cr数值分布") + 
  ggtitle(element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot

##graph norm
plot <- ggplot(user.info,aes(x = factor(user.info$normflag_2), y=user.info$ar))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "iNormal vs. Normal", y = "ar数值分布") + 
  ggtitle(element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot

plot <- ggplot(user.info,aes(x = factor(user.info$normflag_2), y=user.info$cr))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "iNormal vs. Normal", y = "cr数值分布") + 
  ggtitle(element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
#compare three in one chart
mt.data <- subset(user.info, select = c("cr","ar","mf_index","pr_RateCount"))
mt <- melt(mt.data, id.vars = c("pr_RateCount"),measure.vars = c("cr","ar","mf_index"))
describe(mt)
mt.sub <- subset(mt, mt$pr_RateCount < 250)
plot <- ggplot(mt.sub, aes(x = pr_RateCount, y = value, color=variable))+
  geom_point(alpha = 0.4,size = 1.5)+
  geom_smooth(method = lm)
plot
attach(user.info)
cr.aggr <- aggregate(cr~pr_RateCount, FUN = )

#abs
user.info[, ar_abs := abs(ar)]
user.info[, cr_abs := abs(cr)]
user.info[, mf_abs := abs(mf_index)]

ar_cr_mf <- melt(data.frame(ar_index = user.info$ar_abs, cr_index = user.info$cr_abs, mf_index = user.info$mf_abs))
plot <- ggplot(ar_cr_mf,aes(x = factor(variable), y=value))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "AR指数 CR指数 MF指数", y = "数值分布") + 
  ggtitle("三指数（绝对值）分布对比",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot

plot <- ggplot(user.info, aes(x = pr_RateCount, y = cr_abs, color=pr_SR))+
  geom_point()+
  geom_smooth(method = loess)
plot

plot <- ggplot(user.info, aes(x = pr_RateCount, y = ar_abs, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

#cut out outliar
qplot(user.info$pr_RateCount)
user.info.sub <- subset(user.info, user.info$pr_RateCount < 250)

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar_abs, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = cr_abs, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = mf_abs, color=pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

#avg fangqi
attach(user.info.sub)
ar.avg <- aggregate(ar~pr_RateCount, FUN = mean)
cr.avg <- aggregate(cr~pr_RateCount, FUN = mean)
mf.avg <- aggregate(mf_index~pr_RateCount, FUN = mean)

predictvals <- function(model, xvar, yvar, xrange=NULL, samples=100, ...) {
  
  # If xrange isn't passed in, determine xrange from the models.
  # Different ways of extracting the x range, depending on model type
  if (is.null(xrange)) {
    if (any(class(model) %in% c("lm", "glm")))
      xrange <- range(model$model[[xvar]])
    else if (any(class(model) %in% "loess"))
      xrange <- range(model$x)
  }
  
  newdata <- data.frame(x = seq(xrange[1], xrange[2], length.out = samples))
  names(newdata) <- xvar
  newdata[[yvar]] <- predict(model, newdata = newdata, ...)
  newdata
}
model.ar <- lm(ar~pr_RateCount + I(pr_RateCount^2), ar.avg)
ar.predicted <- predictvals(model.ar, "pr_RateCount", "ar")
plot <- ggplot(ar.avg, aes(x = pr_RateCount, y = ar))+
  geom_point()+
  geom_smooth(method = lm)
plot
model.cr <- lm(cr~pr_RateCount + I(pr_RateCount^2), cr.avg)
cr.predicted <- predictvals(model.cr, "pr_RateCount", "cr")
plot <- ggplot(cr.avg, aes(x = pr_RateCount, y = cr))+
  geom_point()+
  geom_smooth(method = lm)
plot



detach(user.info.sub)

#dif 
user.info[,ar_cr:=cr-ar]
user.info.sub <- subset(user.info, user.info$pr_RateCount < 250)
ar_cr.aggr <- aggregate(ar_cr~pr_RateCount,data = user.info.sub, FUN = var)
plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar_cr, color = pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

rm(ar_cr)
ar_cr.aggr.sub <- ar_cr.aggr[complete.cases(ar_cr.aggr),]
plot <- ggplot(ar_cr.aggr.sub, aes(x = pr_RateCount, y = ar_cr))+
  labs(y = "Variance")+
  geom_point(color = "grey60")+
  geom_smooth(se = F, color = "red")
plot

plot <- ggplot(user.info.sub, aes(x = pr_rateage, y = ar_abs, color = pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot
#compare two in one chart
mt.data_2 <- subset(user.info.sub, select = c("cr_abs","ar_abs","mf_abs","pr_RateCount"))
mt_2 <- melt(mt.data_2, id.vars = c("pr_RateCount"),measure.vars = c("cr_abs","ar_abs","mf_abs"))
describe(mt)
plot <- ggplot(mt_2, aes(x = pr_RateCount, y = value, color=variable))+
  geom_point(alpha = 0.4,size = 1.5)+
  geom_smooth(method = lm)
plot

#var
ar.aggr_var <- aggregate(ar~pr_RateCount,data = user.info.sub, FUN = var)
cr.aggr_var <- aggregate(cr~pr_RateCount,data = user.info.sub, FUN = var)

describe(ar.aggr_var.sub)

##del outliers
ar.aggr_var <- ar.aggr_var[complete.cases(ar.aggr_var),]

ar.aggr_var.sub <- subset(ar.aggr_var, !pr_RateCount %in% c("75","84", "138"))
model.var.ar <- lm(ar~pr_RateCount + I(pr_RateCount^2), ar.aggr_var.sub)
ar.var.predicted <- predictvals(model.var.ar, "pr_RateCount", "ar")
plot <- ggplot(ar.aggr_var.sub, aes(x = pr_RateCount, y = ar))+
  geom_point()+
  labs(y = "Variance(ar)")+
  geom_smooth(method = lm)
  # geom_line(data = ar.var.predicted)
plot

cr.aggr_var <- cr.aggr_var[complete.cases(cr.aggr_var),]
describe(cr.aggr_var)
cr.aggr_var.sub <- subset(cr.aggr_var, !pr_RateCount %in% c("75","84", "138"))
model.var.cr <- lm(cr~pr_RateCount + I(pr_RateCount^2), cr.aggr_var.sub)
cr.var.predicted <- predictvals(model.var.cr, "pr_RateCount", "cr")
plot <- ggplot(cr.aggr_var.sub, aes(x = pr_RateCount, y = cr))+
  geom_point()+
  labs(y = "Variance(cr)")+
  # geom_smooth(method = lm)
  geom_line(data = cr.var.predicted)
plot
# model2 3
ar_cr_2 <- melt(data.frame(ar_index = user.info$ar_2, cr_index = user.info$cr_2))
plot <- ggplot(ar_cr_2,aes(x = factor(variable), y=value))
plot <- plot +
  geom_violin(trim = F)+
  geom_boxplot(width = 0.1, fill = "black")+
  stat_summary(fun.y="mean", geom="point", shape=21, size=2.5, fill="white")+
  labs(x = "AR指数 CR指数", y = "数值分布") + 
  ggtitle("指数分布对比",element_text(size=30)) +
  theme_stata()+
  theme(plot.title = element_text(size = 17), axis.text=element_text(size=10),axis.title.x = element_text(size=15, vjust = -2),axis.title.y = element_text(size=15,vjust = 3))
plot
ar_cr_2.aov <- aov(ar_cr_mf[,2]~ar_cr_mf[,1])
summary(ar_cr_2.aov)

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar_2, color = pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = cr_2, color = pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar_2, color = pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot

# for average rating users
mean(user.info.sub$pr_Rate_avg)
qplot(user.info.sub$pr_Rate_avg)
user.info.normmind <- subset(user.info, pr_Rate_avg>3&pr_Rate_avg<4)
qplot(user.info.normmind$pr_Rate_avg)
plot <- ggplot(user.info.normmind, aes(x = pr_RateCount, y = ar, color = pr_SR))+
  geom_point()+
  geom_smooth(method = lm)
plot
user.info[,normflag_2:=ifelse(pr_Rate_avg>2.5&pr_Rate_avg<3.5,1,0)]
describe(user.info$normflag)
user.info$normflag_2 <- as.factor(user.info$normflag_2)
user.info.sub <- subset(user.info, user.info$pr_RateCount < 250)

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar, color = normflag_2))+
  geom_point()+
  geom_smooth(method = loess)
plot
plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = cr, color = normflag_2))+
  geom_point()+
  geom_smooth(method = lm)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = ar_abs, color = normflag_2))+
  geom_point()+
  geom_smooth(method = loess)
plot

plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = cr_abs, color = normflag_2))+
  geom_point()+
  geom_smooth(method = loess)
plot
plot <- ggplot(user.info.sub, aes(x = pr_RateCount, y = cr_abs, color = normflag_2))+
  geom_point()+
  geom_smooth(method = lm)
plot
#other insight
plot <- ggplot(user.info, aes(x = UID, y = cr, color = Frequent))+
  geom_point()
plot

plot <- ggplot(user.info, aes(x = UID, y = ar, color = Frequent))+
  geom_point()
plot

plot <- ggplot(user.info, aes(x = UID, y = ar_cr, color = Frequent))+
  geom_point()
plot

mt_3 <- melt(user.info, id.vars = c("UID"),measure.vars = c("cr","ar","mf_index"))
plot <- ggplot(mt_3, aes(x = UID, y = value, color = variable))+
  geom_point()
plot
marginplot(user.info[,c("cr","ar")])
plot <- ggplot(user.info, aes(x = cr, y = ar, color = pr_SR))+
  geom_point()
plot

plot <- ggplot(user.info, aes(x = UID, y = ar_cr, color = pr_SR))+
  geom_point()
plot
#count neutral
dim(user.info[user.info$cr>-0.01&user.info$cr<0.01,])
dim(user.info[user.info$ar>-0.01&user.info$ar<0.01,])
describe(user.info[user.info$cr<(-0.01),][["cr"]])
describe(user.info[user.info$ar<(-0.01),][["ar"]])
describe(user.info[user.info$cr>0.01,][["cr"]])
describe(user.info[user.info$ar>0.01,][["ar"]])
#corelation bewteen fAr and if
user.info.f <- subset(user.info, user.info$Frequent == 1)
user.info.if <- subset(user.info, user.info$Frequent == 0)
user.info.sr <- subset(user.info,user.info$pr_SR == 1)
user.info.isr <- subset(user.info,user.info$pr_SR==0)
rm(user.info.f,user.info.if,user.info.isr,user.info.sr)
ar.rate.add <- left_join(user.info,ar.rate,by = "UID")
write.csv(ar.rate.add,file.path(path.output,"sample_ar_rate_userinfo.csv"),row.names = F)
ar.rate.f <- subset(ar.rate.add, ar.rate.add$Frequent == 1)
ar.rate.if <- subset(ar.rate.add, ar.rate.add$Frequent == 0)
ar.rate.sr <- subset(ar.rate.add,ar.rate.add$pr_SR == 1)
ar.rate.isr <- subset(ar.rate.add,ar.rate.add$pr_SR==0)

cor.test(ar.rate.f$Rate,ar.rate.f$Ascore)
cor.test(ar.rate.f$Rate,ar.rate.f$Tomatometer)
