## Courera R Programming
## Programming Assignment 1: Air Pollution
## Part 2
complete <- function(directory, id = 1:332) {
    ## 'directory' is a character vector of length 1 indicating
    ## the location of the CSV files
    
    ## 'id' is an integer vector indicating the monitor ID numbers
    ## to be used
    
    ## Return a data frame of the form:
    ## id nobs
    ## 1  117
    ## 2  1041
    ## ...
    ## where 'id' is the monitor ID number and 'nobs' is the
    ## number of complete cases
    
    ## Loop read files
    firstrow <- TRUE
    for(monid in id) {
        ## paste filenames into a string vector
        filename <- sprintf("%s/%03d.csv", directory, monid)
        dataset <- read.csv(filename, header=TRUE, sep=',', na.strings=c("NA","#DIV/0!",""))
        
        ## get sum and count from one dataset, ignoring NA values
        subset <- dataset[!is.na(dataset$sulfate) & !is.na(dataset$nitrate),]
        if(firstrow) {
            vec.id <- monid
            vec.nobs <- nrow(subset)
            firstrow <- FALSE
        } else {
            vec.id <- c(vec.id, monid)
            vec.nobs <- c(vec.nobs, nrow(subset))
        }
    }
    
    d <- data.frame(id=vec.id, nobs=vec.nobs)
    d
}