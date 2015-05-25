# Install/load the ggplot2/quantmod/reshape2 package
install.packages("ggplot2")
install.packages("quantmod")
install.packages("reshape2")

library("ggplot2")
library("reshape2")
library("quantmod")

# Initialise the environment with the required datasets, 
# you should download the .zip from the course website
# and unzip into your working directory.
if(!exists("NEI"))
{
  print("Reading NEI data...")
  NEI <- readRDS("summarySCC_PM25.rds")  
}

if(!exists("SCC"))
{  
  print("Reading SCC data...")
  SCC <- readRDS("Source_Classification_Code.rds")
}

# Subset the data to filter on 'motor vehicles', here I have included 
# all codes returned by filtering on 'vehicle' in the EI.Sector column. 
# This can be easily changed should another definition be provided.
motorVehicles <- SCC[grepl("vehicle", SCC$EI.Sector, ignore.case=TRUE), c("SCC")]
subNEI <- NEI[NEI$SCC %in% motorVehicles,]

# Subset the data by filtering on the appropriate fips identifier, 
# return all observations for Baltimore City and LA County.
subNEI <- subNEI[subNEI$fips %in% c("24510", "06037"), ]

# Aggregate the data based upon the observation years 
aggNEI <- aggregate(subNEI$Emissions, by=list(subNEI$year, subNEI$fips), FUN=sum, na.rm=TRUE)

# Rename the columns to more appropriate names
colnames(aggNEI) <- c("obsYear", "fips", "Emissions")

# Due to the y-axis range differences, overlaying the two datasets doesn't
# provide an easy to compare plot. Therefore, I am calculating the percentage
# change between each year, and plotting this for each.
df <- data.frame(
  aggNEI[aggNEI$fips == "24510", ]$obsYear, 
  # Leveraging the quantmod package, to calculate the % change for a series
  (Delt(aggNEI[aggNEI$fips == "24510", ]$Emissions)*100),
  (Delt(aggNEI[aggNEI$fips == "06037", ]$Emissions)*100))

# Clean-up the new DF, adding appropriate names, replacing NA's and transposing
colnames(df) <- c("obsYear", "baltimore", "lacounty")
df.melted <- melt(df, id=c("obsYear"))
df.melted[is.na(df.melted)] <- 0.0

# Plot the dataset using ggplot2 to create a combined lineplot, with appropriate labels
png("plot6.png", width=800, height=600)
ggplot(data=df.melted, aes(x=obsYear, y=value, col=factor(variable))) + 
  geom_text(aes(y=value, label=round(value, 1)), color="black", vjust=-.5) +
  scale_y_continuous("Relative Change (%)", limits=c(-65, 10), breaks=seq(-65, 10, 5)) +
  scale_x_continuous("Year", limits=c(1999, 2008), breaks=(seq(1999,2008,3))) +
  scale_color_discrete(name="Locations", breaks=c("lacounty", "baltimore"), labels=c("LA County", "Baltimore")) +
  ggtitle("Baltimore vs. LA County: Motor Vehicle Emissions Change Over Time") +
  geom_line() 
dev.off()