# Practical Machine Learning
# Lecture 020 Bagging (bootstrap aggregating)
# Code exercise
install.packages("ElemStatLearn")
library(ElemStatLearn)
data(ozone, package="ElemStatLearn")

head(ozone)
# output:   ozone radiation temperature wind
# output: 1    41       190          67  7.4
# output: 2    36       118          72  8.0
# output: 3    12       149          74 12.6
# output: 4    18       313          62 11.5
# output: 5    23       299          65  8.6
# output: 6    19        99          59 13.8

# Bagged loess
ll <- matrix(NA, nrow=10, ncol=155)
for(i in 1:10) {
	ss <- sample(1:dim(ozone)[1], replace=T)
	ozone0 <- ozone[ss,]; ozone0 <- ozone0[order(ozone0$ozone),]
	loess0 <- loess(temperature ~ ozone, data=ozone0, span=0.2)
	ll[i,] <- predict(loess0, newdata=data.frame(ozone=1:155))
}

# Plot
plot(ozone$ozone, ozone$temperature, pch=19, cex=0.5)
for(i in 1:10) {lines(1:155, ll[i,], col="grey", lwd=2)}
lines(1:155, apply(ll,2,mean), col="red", lwd=2)

# Bagging in caret
library(caret)
predictors = data.frame(ozone=ozone$ozone)
temperature = ozone$temperature
treebag <- bag(predictors, temperature, B=10, 
					bagControl=bagControl(fit=ctreeBag$fit, 
										predict=ctreeBag$pred,
										aggregate=ctreeBag$aggregate))
# Plot
plot(ozone$ozone, ozone$temperature, col='lightgrey', pch=19)
plot(ozone$ozone, predict(treebag$fit[[1]]$fit,predictors), col='red', pch=19)
plot(ozone$ozone, predict(treebag,predictors), col='blue', pch=19)

