# Quiz 4, question 4
# Code exercise
install.packages("lubridate")
install.packages("forecast")

library(lubridate)  # For year() function below
# setwd("D:/4 - Works/GitHub/MyStudy/R_code")
dat = read.csv("./gaData.csv")
training = dat[year(dat$date) < 2012,]
testing = dat[(year(dat$date)) > 2011,]
tstrain = ts(training$visitsTumblr)

# Fit a model using the bats() function in the forecast package to the training time series
library(forecast)
fit <- bats(tstrain)

# Then forecast this model for the remaining time points
pred <- forecast(fit, level=95, h=nrow(testing))
plot(pred)

# For how many of the testing points is the true value within the 95% prediction interval bounds?
accuracy(pred, testing$visitsTumblr)
sum(testing$visitsTumblr > pred$lower & testing$visitsTumblr < pred$upper) / nrow(testing)
# output: [1] 0.9617021
