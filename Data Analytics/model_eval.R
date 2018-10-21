library(data.table)
library(Hmisc)
library(dplyr)
library(tidyr)
library(VIM)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(caret)
library(recommenderlab)
path.wd <- getwd()
path.input <- file.path(path.wd,"Input")
path.output <- file.path(path.wd,"Output")
model.1 <- fread(file.path(path.input,"result.csv"))
model.2 <- fread(file.path(path.input,"result_2.csv"))
model.3 <- fread(file.path(path.input,"result_3.csv"))
model.0 <- fread(file.path(path.input,"result_0.csv"))

input_data <- fread(file.path(path.input,"model_input_rate.csv"))
model.eval <- fread(file.path(path.input,"model_input_rate_na.csv"))
model.eval <- as.matrix(model.eval)
model.1 <- as.matrix(model.1)
model.2 <- as.matrix(model.2)
model.3 <- as.matrix(model.3)
model.0 <- as.matrix(model.0)
# model.eval.real <- as(model.eval, "realRatingMatrix")
rm(model.eval.real)
# calcPredictionAccuracy(model.1, model.eval)


rmse <- function(actuals, predicts)
{
  sqrt(mean((actuals - predicts)^2, na.rm = T))
}

mae <- function(actuals, predicts)
{
  mean(abs(actuals - predicts), na.rm = T)
}

mse <- function(actuals, predicts)
{
  mean((actuals - predicts)^2, na.rm = T)
}

error.matrix <- data.frame(model_0 = 0, model_1 = 0, model_2 = 0, model_3 = 0)
error.matrix <- error.matrix[-1,]
error.matrix <- rbind(error.matrix, c(mae(model.eval, model.0),
                      mae(model.eval, model.1),
                      mae(model.eval, model.2),
                      mae(model.eval, model.3)))

error.matrix <- rbind(error.matrix, c(mse(model.eval, model.0),
                      mse(model.eval, model.1),
                      mse(model.eval, model.2),
                      mse(model.eval, model.3)))

error.matrix <- rbind(error.matrix, c(rmse(model.eval, model.0),
                      rmse(model.eval, model.1),
                      rmse(model.eval, model.2),
                      rmse(model.eval, model.3)))

colnames(error.matrix) <- c("model_0","model_1","model_2","model_3")
row.names(error.matrix) <- c("MAE" ,"MSE", "RMSE")

write.csv(error.matrix, file.path(path.output,"Model_error.csv"))
