# Practical Machine Learning
# Course Project Result Submission Code

# Load results.txt file
setwd("D:/4 - Works/GitHub/MyStudy/PML Course Project")
answers <- read.table('results.txt', header=FALSE, sep=",")

pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}

pml_sub_files = function(x){
  n = (x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}

# pml_write_files(t(answers))