# Exploratory Data Analysis
# Course Porject 2 - Plot 1
#--------------------------------
## Q1: Have total emissions from PM2.5 decreased in the United States from 1999 to 2008?
#--------------------------------
plot1 <- function(genPNG=TRUE) {
    
    #--------------------------------
    # The following code snippet is shared through plot 1 to plot 6
    ## Loading Data
    ## This first line will likely take a few seconds. Be patient!
    NEI <- readRDS("summarySCC_PM25.rds")
    SCC <- readRDS("Source_Classification_Code.rds")
    #--------------------------------
    
    #--------------------------------
    ## Prepare plotting data
    library(dplyr)
    data.all <- tbl_df(NEI)
    data.yeartotal <- group_by(data.all, year) %>%
        summarize(sumEmissions=sum(Emissions))
    #--------------------------------
    
    #--------------------------------
    ## Save as png
    if (genPNG) {
        png("./plot1.png")
    }
    
    ## Draw Plot
    with(data.yeartotal, {
        plot(year, sumEmissions, type="b", xlab="year", ylab="Total Emissions", main="Q1: Trend of PM2.5 Emissions in U.S.", col="red", xlim=c(1999,2008))
        ##text(year+0.05, sumEmissions+0.05, labels=sumEmissions)
    })
    
    ## Close device
    if (genPNG) {
        dev.off()
    }    
    #--------------------------------
}