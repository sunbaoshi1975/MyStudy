# Exploratory Data Analysis
# Course Porject 2 - Plot 5
#--------------------------------
## Q5: How have emissions from motor vehicle sources changed from 1999-2008 in Baltimore City?
#--------------------------------
plot5 <- function(genPNG=TRUE) {
    
    #--------------------------------
    # The following code snippet is shared through plot 1 to plot 6
    ## Loading Data
    ## This first line will likely take a few seconds. Be patient!
    NEI <- readRDS("summarySCC_PM25.rds")
    SCC <- readRDS("Source_Classification_Code.rds")
    #--------------------------------
    
    #--------------------------------
    ## Prepare plotting data
    ### motor vehicle sources: 'vehicle' in short.Name
    scc_motor <- as.vector(SCC[grepl("vehicle", SCC$Short.Name, ignore.case = TRUE),1])
    
    library(dplyr)
    data.all <- tbl_df(NEI)
    data.baltimore_motor <- filter(data.all, (SCC %in% scc_motor) & (fips == "24510")) %>%
        group_by(year) %>%
        summarize(sumEmissions=sum(Emissions))
    #--------------------------------
    
    #--------------------------------
    ## Save as png
    if (genPNG) {
        png("./plot5.png")
    }
    
    ## Draw Plot
    with(data.baltimore_motor, {
        plot(year, sumEmissions, type="b", col="blue", xlab="Year", ylab="Total Motor Emissions", main="Q5: Trend of Motor Vehicle Emissions in the Baltimore")
    })
    
    ## Close device
    if (genPNG) {
        dev.off()
    }    
    #--------------------------------
}