## Courera R Programming
## Programming Assignment 1: Air Pollution
## Part 3
corr <- function(directory, threshold = 0) {
    ## 'directory' is a character vector of length 1 indicating
    ## the location of the CSV files
    
    ## 'threshold' is a numeric vector of length 1 indicating the
    ## number of completely observed observations (on all
    ## variables) required to compute the correlation between
    ## nitrate and sulfate; the default is 0
    
    ## Return a numeric vector of correlations
    
    ## get the number of completed cases for every file
    #source("complete.R")
    #completecases <- complete(directory)
    
    result <- vector(mode = "numeric", length = 0)
    #for( index in 1:nrow(completecases) ) {
    for(monid in 1:332) {
        filename <- sprintf("%s/%03d.csv", directory, monid)
        dataset <- read.csv(filename, header=TRUE, sep=',', na.strings=c("NA","#DIV/0!",""))
        subset <- dataset[!is.na(dataset$sulfate) & !is.na(dataset$nitrate),]
        if( nrow(subset) > threshold ) {
            result <- c(result, cor(x=subset$sulfate, y=subset$nitrate))
        }
    }
    
    corr <- result
}