#---using workspace 3---
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
ar.rate <- fread(file.path(path.output,"ra_rate_lm_addfreq.csv"))

#sampling

ar.rate.sample <- ar.rate[sample(1:1579439,10000),]

#lm

lm.3 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore_10+Tomatometer_10,ar.rate.sample)
lm.3_3 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg_2+cr_avg,ar.rate.sample)
summary(lm.3)
summary(lm.3_3)
lm.4 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.sample)
lm.4_4 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std+SR,ar.rate.sample)
summary(lm.4_4)
summary(lm.4)
lm.5 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.sample)
summary(lm.5)
lm.5_5 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std+SR,ar.rate.sample)
summary(lm.5_5)
rm(lm.3,lm.3_3,lm.4,lm.4_4,lm.5,lm.5_5)



ar.rate.sample.sr <- subset(ar.rate.sample, ar.rate.sample$SR==1)
ar.rate.sample.nsr <- subset(ar.rate.sample,ar.rate.sample$SR==0)
qplot(ar.rate.sample$SR)
ar.rate.sample$SR <- as.factor(ar.rate.sample$SR)
describe(ar.rate.sample$SR)
lm.6 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.sample.sr)

lm.7 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.sample.sr)
lm.8 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.sample.sr)
lm.9 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.sample.sr)

lm.10 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.sample.nsr)

lm.11 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.sample.nsr)
lm.12 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.sample.nsr)
lm.13 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.sample.nsr)
summary(lm.6)
summary(lm.7)
summary(lm.8)
summary(lm.9)
summary(lm.10)
summary(lm.11)
summary(lm.12)
summary(lm.13)
rm(lm.6,lm.7,lm.8,lm.9,lm.10,lm.11,lm.12,lm.13)


ar.rate.sample.freq <- subset(ar.rate.sample, ar.rate.sample$prFrequent==1)
ar.rate.sample.nfreq <- subset(ar.rate.sample,ar.rate.sample$prFrequent==0)
qplot(ar.rate.sample$prFrequent)
ar.rate.sample$Frequent <- as.factor(ar.rate.sample$prFrequent)
describe(ar.rate.sample$prFrequent)
lm.6 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.sample.freq)
lm.7 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.sample.freq)
lm.8 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.sample.freq)
lm.9 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.sample.freq)

lm.10 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+Ascore+Tomatometer,ar.rate.sample.nfreq)

lm.11 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+Ascore_std+Tomatometer_std,ar.rate.sample.nfreq)
lm.12 <- lm(formula = rate_2~ar_volume_cum+cr_volume_cum+ar_avg+cr_avg,ar.rate.sample.nfreq)
lm.13 <- lm(formula = Rate_std~ar_volume_cum_std+cr_volume_cum_std+ar_avg_std+cr_avg_std,ar.rate.sample.nfreq)
summary(lm.6)
summary(lm.7)
summary(lm.8)
summary(lm.9)
summary(lm.10)
summary(lm.11)
summary(lm.12)
summary(lm.13)
rm(lm.6,lm.7,lm.8,lm.9,lm.10,lm.11,lm.12,lm.13)

