## Courera R Programming
## Programming Assignment 1: Air Pollution
## Part 1
pollutantmean <- function(directory, pollutant, id = 1:332) {
    ## 'directory' is a character vector of length 1 indicating
    ## the location of the CSV files
  
    ## 'pollutant' is a character vector of length 1 indicating
    ## the name of the pollutant for which we will calculate the
    ## mean; either "sulfate" or "nitrate".
  
    ## 'id' is an integer vector indicating the monitor ID numbers
    ## to be used
  
    ## Return the mean of the pollutant across all monitors list
    ## in the 'id' vector (ignoring NA values)
  
    ## paste filenames into a string vector
    filenames <- sprintf("%s/%03d.csv", directory, id)
  
    ## Loop read files
    pollutant.sum <- 0
    pollutant.count <- 0
    for(datafile in filenames) {
        
        dataset <- read.csv(datafile, header=TRUE, sep=',', na.strings=c("NA","#DIV/0!",""))
        
        ## get sum and count from one dataset, ignoring NA values
        subset <- dataset[!is.na(dataset[[pollutant]]),]
        pollutant.count <- pollutant.count + nrow(subset)
        pollutant.sum <- pollutant.sum + sum(subset[[pollutant]])        
    }

    ## result calculation
    pollutantmean <- if(pollutant.count == 0) {0} else {pollutant.sum / pollutant.count}
    round(pollutantmean, 3)
}