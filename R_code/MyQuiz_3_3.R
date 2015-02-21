# Practical Machine Learning
# Quiz 3, question 3
# Code exercise
install.packages("prmm")
#install.packages("olive")
library(pgmm)
library(caret)
load("olive.rda")
data(olive)

names(olive)
# output:  [1] "Region"      "Area"        "Palmitic"    "Palmitoleic"
# output:  [5] "Stearic"     "Oleic"       "Linoleic"    "Linolenic"  
# output:  [9] "Arachidic"   "Eicosenoic" 
 
# remove column "Region"
olive = olive[,-1]

# These data contain information on 572 different Italian olive oils from multiple regions in Italy.
## Fit a classification tree where Area is the outcome variable. 
## Then predict the value of area for the following data frame using the tree command with all defaults
training <- olive
dim(training)
# output: [1] 572   9

modFit <- train(Area ~., method="rpart", data=training)
print(modFit$finalModel)

newdata = as.data.frame(t(colMeans(olive)))
pred <- predict(modFit, newdata=newdata)
pred