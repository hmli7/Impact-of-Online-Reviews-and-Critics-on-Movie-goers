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

ar.rate.wtsni <- subset(ar.rate, ar.rate$Rate>-3&ar.rate$Rate<0)
describe(ar.rate.wtsni$SR)

glm.1 <- glm(Rate~)

#由于项目没有wtsni的完整数据，因此。。