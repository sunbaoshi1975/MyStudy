# Load the Alzheimer's disease data
library(AppliedPredictiveModeling)
data(concrete)
library(caret)
set.seed(975)
inTrain = createDataPartition(mixtures$CompressiveStrength, p = 3/4)[[1]]
training = mixtures[ inTrain,]
testing = mixtures[-inTrain,]

# Load Hmisc for cut2()
library(Hmisc)
cutComp <- cut2(training$CompressiveStrength, g=5)

# Make a plot of the outcome (CompressiveStrength) versus the index of the samples
## Color by FlyAsh in the data set
pl_FlyAsh <- qplot(, cutComp, color=FlyAsh, data=training)
## Color by Age in the data set
pl_Age <- qplot(, cutComp, color=Age, data=training)

pl_FlyAsh
pl_Age
# Both show step-like pattern, while the colors(the 3rd variable) distribute throughout all steps.
