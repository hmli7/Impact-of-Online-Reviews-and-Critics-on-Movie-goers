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
movielastinfo <- fread(file.path(path.input,"movielastdateinfo_whole.csv"))
# generate movie info dataset
describe(movielastinfo)
qplot(movielastinfo$Ascore)
qplot(movielastinfo$ar_avg)
qplot(movielastinfo$ar_volume_cum)
qplot(movielastinfo$cr_volume_cum)
qplot(movielastinfo$ml_ar_volume_cum)
qplot(movielastinfo$cr_avg)
qplot(movielastinfo$Tomatometer)
qplot(movielastinfo$ml_ar_avg)
qplot(movielastinfo$Alabel)
qplot(movielastinfo$Tomatometer_label)

#convert ar rate to 1-10
movielastinfo <- data.frame(movielastinfo, ar_avg_2 = movielastinfo$ar_avg * 2)
marginplot(movielastinfo[,c("ar_avg_2","cr_avg")],main = "AR平均分 vs CR平均分")

featurePlot(x=movielastinfo[,c("Ascore","ar_avg","cr_avg")],
            y=movielastinfo[,c("Tomatometer","ml_ar_avg")],
            plot="pairs",
            type = c("p", "smooth" ,col = col.smooth),
            span = .5)
featurePlot(x=movielastinfo$ar_avg_2,
            y=movielastinfo$cr_avg,
            plot="box")

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

pairs(movielastinfo[,c("Ascore","ar_avg_2","Tomatometer","cr_avg")], pch=".",
      upper.panel = panel.cor,
      diag.panel  = panel.hist,
      lower.panel = panel.lm)
marginmatrix(movielastinfo[,c("Ascore","Tomatometer")])
marginplot(movielastinfo[,c("Ascore","Tomatometer")],main = "Ascore vs. Tomatometer")

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

#about huoyuedu
qplot(movielastinfo$ar_volume_cum)
qplot(movielastinfo$cr_volume_cum)
qplot(movielastinfo$ml_ar_volume_cum)
