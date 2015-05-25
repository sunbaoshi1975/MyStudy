library(dplyr)
library(ggplot2)

# Get data for class project. Only download the file if it does not exist
# locally.
getRemoteData <-function(sourceHost, sourcePath) {

    localZip <- basename(URLdecode(sourcePath))

    # Construct a fully qualified URL for the location of the remote data.
    sourceUrl=function() {
        paste(sourceHost, sourcePath, sep="/")
    }

    if (!file.exists(localZip)) {
        download.file(sourceUrl(), localZip, method="curl")
    }
    unzip(localZip, junkpaths=TRUE)
}


# Read in the NEI RDS file if-and-only-if the NEI class does not
# exists in the parent environment and it is not NULL.
loadNEI <- function() {
    readit <- TRUE
    if (exists("NEI")) {
        if (!is.null(NEI)) {
            readit <- FALSE
        }
    }
    if(readit) {
        readRDS("summarySCC_PM25.rds")
    } else {
        return(NEI)
    }
}

loadSCC <- function() {
    readit <- TRUE
    if (exists("SCC")) {
        if (!is.null(SCC)) {
            readit <- FALSE
        }
    }
    if (readit) {
        readRDS("Source_Classification_Code.rds")
    } else {
        return(SCC)
    }
}

# Convenience wrapper to output a plotting function to a PNG file.
plot2png <- function(filename, plotfn) {
    png(filename, width=480, height=480)
    plotfn()
    dev.off()
}
# Convenience wrapper to output a plotting function to a PNG file.
qplot2png <- function(filename, plotfn) {
    png(filename, width=800, height=480)
    print(plotfn())
    dev.off()
}

getRemoteData(sourceHost="https://d396qusza40orc.cloudfront.net",
              sourcePath="exdata/data/NEI_data.zip")
NEI <- loadNEI()
SCC <- loadSCC()

# Question 1:
# Using the base plotting system, make a plot showing the
# total PM2.5 emission from all sources
# for each of the years 1999, 2002, 2005, and 2008.
question1 <- function() {
    NEI %>% group_by(year) %>% summarize(TotalEmissions=sum(Emissions)) -> q1
    plot(q1$year, q1$TotalEmissions, t="l",
         xlab="Emission Year",
         ylab="Total PM2.5 Emissions",
         main="Total PM2.5 Emission from All Sources")
}
plot2png("plot1.png", question1)
