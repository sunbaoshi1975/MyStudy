# Practical Machine Learning
# Lecture 026 unsupervised Prediction
# see also cl_predict function in the clue package
data(iris)
library(caret)
library(ggplot2)

# Iris example ignoring species labels
inTrain <- createDataPartition(y=iris$Species, p=0.7, list=FALSE)
training <- iris[inTrain,]
testing <- iris[-inTrain,]
dim(training); dim(testing)

[1] 105   5
[1] 45  5

# Cluster with k-means
kMeans1 <- kmeans(subset(training, select=-c(Species)), centers=3)
training$clusters <- as.factor(kMeans1$cluster)
qplot(Petal.Width, Petal.Length, color=clusters, data=training)

# Compare to real labels
table(kMeans1$cluster, training$Species)

    setosa versicolor virginica
  1     22          0         0
  2      0         32        35
  3     13          3         0
  
# Build predictor
modFit <- train(clusters ~., data=subset(training,select=-c(Species)), method="rpart")  
table(predict(modFit, training), training$Species)

    setosa versicolor virginica
  1     21          0         0
  2      0         32        35
  3     14          3         0
  
# Apply on test
testClusterPred <- predict(modFit, testing)
table(testClusterPred, testing$Species)

testClusterPred setosa versicolor virginica
              1     12          0         0
              2      0         13        15
              3      3          2         0
			  
