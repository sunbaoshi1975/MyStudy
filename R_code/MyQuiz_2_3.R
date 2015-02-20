library(AppliedPredictiveModeling)
data(concrete)
library(caret)
set.seed(975)
inTrain = createDataPartition(mixtures$CompressiveStrength, p = 3/4)[[1]]
training = mixtures[ inTrain,]
testing = mixtures[-inTrain,]

# Make a histogram and confirm the SuperPlasticizer variable is skewed
# Normally you might use the log transform to try to make the data more symmetric
logSuper <- log(training$Superplasticizer)
histogram(logSuper)
# See there are lots of '-Inf' in logSupper