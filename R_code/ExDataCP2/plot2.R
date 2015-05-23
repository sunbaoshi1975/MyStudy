# Exploratory Data Analysis
# Course Porject 2 - Plot 2
#--------------------------------
## Q2: Have total emissions from PM2.5 decreased in the Baltimore City, Maryland (fips == "24510") from 1999 to 2008? 
### Use the base plotting system to make a plot answering this question.
#--------------------------------
plot2 <- function(genPNG=TRUE) {
    
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
    data.baltimoretotal <- filter(data.all, fips=="24510") %>%
        group_by(year) %>%
        summarize(sumEmissions=sum(Emissions))
    #--------------------------------
    
    #--------------------------------
    ## Save as png
    if (genPNG) {
        png("./plot2.png")
    }
    
    ## Draw Plot
    with(data.baltimoretotal, {
        plot(year, sumEmissions, type="b", xlab="Year", ylab="Total Emissions", main="Q2: Trend of PM2.5 Emissions in Baltimore", col="blue", xlim=c(1999,2008))
        text(year+0.5, sumEmissions+0.5, labels=format(sumEmissions, digits=4))
    })
    
    ## Close device
    if (genPNG) {
        dev.off()
    }    
    #--------------------------------
}