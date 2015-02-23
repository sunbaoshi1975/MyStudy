# Practical Machine Learning
# Lecture 027 forecasting
# Code exercise on Google data
install.packages("quantmod")
library(quantmod)
from.dat <- as.Date("01/01/08", format="%m/%d/%y")
to.dat <- as.Date("12/31/13", format="%m/%d/%y")
getSymbols("GOOG", src="google", from=from.dat, to=to.dat)

head(GOOG)		# no date column ???
# output:      GOOG.Open GOOG.High GOOG.Low GOOG.Close GOOG.Volume
# output: <NA>    346.09    348.34   338.53     342.25          NA
# output: <NA>    342.29    343.08   337.92     342.32          NA
# output: <NA>    339.51    340.14   327.17     328.17          NA
# output: <NA>    326.64    330.81   318.36     324.30          NA
# output: <NA>    326.17    329.65   315.18     315.52          NA
# output: <NA>    314.70    326.34   310.94     326.27          NA

# Summarize monthly and store as time series
mGoog <- to.monthly(GOOG)
googOpen <- Op(mGoog)
tsl <- ts(googOpen, frequency=12)
plot(ts1, xlab="Years+1", ylab="GOOG")

# Decompose a time series into parts
plot(decompose(ts1), xlab="Years+1")

# Training and test sets
ts1Train <- window(ts1, start=1, end=5)
ts1Test <- window(ts1, start=5, end=(7-0.01))
ts1Train

# Simple moving average
plot(ts1Train)
lines(ma(ts1Train, order=3), col="red")

# Exponential smoothing
ets1 <- ets(ts1Train, model="MMM")
fcast <- forecast(ets1)
plot(fcast); lines(ts1Test, col="red")

# Get the accuracy
accuracy(fcast, ts1Test)
