# Load the Alzheimer's disease data
library(AppliedPredictiveModeling)
library(caret)
data(AlzheimerDisease)

# Create training and test sets with about 50%
adData = data.frame(diagnosis,predictors)
testIndex = createDataPartition(diagnosis, p = 0.50, list=FALSE)
training = adData[testIndex,]
testing = adData[-testIndex,]

# Exploration Raw Data
summary(AlzheimerDisease)
head(training, 3)
# colnm <- names(training, 2)
# colnm <- dimnames(training)[[2]]
colnm <- colnames(training)

# Find all the predictor variables in the training set that begin with IL
#grx <- glob2rx("IL*")
#IL_str <- grep(grx, colnm, value=TRUE)

IL_str <- grep("^IL", colnm, value = TRUE)