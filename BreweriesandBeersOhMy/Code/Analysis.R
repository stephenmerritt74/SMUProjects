library(dplyr)
library(reshape2)
library(ggplot2)
library(doBy)
library(formattable)

# Set current workind directory to location where 'Breweries.csv' and 'Beers.csv' are located
setwd("~/SMUProjects/BreweriesandBeersOhMy/Data")
breweries <- read.csv("Breweries.csv", header = TRUE)
beers <- read.csv("Beers.csv", header = TRUE)
# Noted that the the two datasets shared a common integer variable brewery ID
# Renamed the column names of both data sets to be more human readable and made the Brewery_id name 
# common between both datasets

breweries <- setNames(breweries, c("Brewery_id", "Brewery_Name", "City", "State"))
beers <- setNames(beers, c("Beer_Name", "Beer_ID", "ABV", "IBU", "Brewery_id", "Style", "Ounces"))

# Create a data frame called state_count to determine the numbers of breweries per state and plot 
# for visualization
# Create a data frame called state_count to determine the numbers of breweries per state and plot 
# for visualization
state_count <- as.data.frame(count(breweries, State))
state_count_ordered <- state_count %>%
    arrange(desc(n))
par(las=3)
IScolors <- c("red", "green", "yellow", "blue",
              "black", "white", "pink", "cyan",
              "gray", "orange", "brown", "purple")
barplot(state_count_ordered[ ,2], names.arg = state_count_ordered[ ,1], col=rev(IScolors), 
        main = "Number of Breweries per State, Including DC", 
        xlab = "States", ylab = "Number of Breweries", ylim = c(0,50))
# Determine percentage of breweries in Western United States
sum_state_count <- sum(state_count$n)
percent(138/sum_state_count, 1)

# Merge the datasets breweries and beers by Brewery_id
beer_data <- merge(beers, breweries, by = "Brewery_id", all = TRUE)
str(beer_data)
head(beer_data,6)
tail(beer_data,6)
# Create a .csv file named beer_data.csv from the beer_data data frame
write.csv(beer_data, file = "~/SMUProjects/BreweriesandBeersOhMy/Data/beer_data.csv")

# Verify that there are no repeat Beer IDs, would not normally include this code in an actual 
# report
length(unique(beer_data$Beer_ID)) == nrow(beer_data)
style_count <- as.data.frame(count(beer_data, Style))

# Look at the number of different beer styles represented
length(unique(beer_data$Style))

#Count the number of NA's in each column
sapply(beer_data,function(x) sum(is.na(x)))

#Median ABV by State
median_abv_by_state<-summaryBy(ABV~State,data=beer_data,FUN=list(median),na.rm=TRUE)
par(las=3)
median_abv_by_state <- median_abv_by_state %>%
    arrange(desc(ABV.median))
barplot(median_abv_by_state$ABV.median,names=median_abv_by_state$State,col = rev(IScolors), main="Median ABV by State",xlab="State",ylab="ABV")
median_abv_by_state[order(-median_abv_by_state$ABV.median),]

#Median IBU by State
median_ibu_by_state<-summaryBy(IBU~State,data=beer_data,FUN=list(median),na.rm=TRUE)
par(las=3)
barplot(median_ibu_by_state$IBU.median,names=median_ibu_by_state$State,main="Median IBU by State",xlab="State",ylab="IBU")
median_ibu_by_state[order(-median_ibu_by_state$IBU.median),]

#Find the state with the max ABV beer
max_abv<-max(beer_data$ABV,na.rm=TRUE)
beer_data[which(beer_data$ABV==max_abv),c(2,4,8,10)]

#Find the state with the max IBU beer
max_ibu<-max(beer_data$IBU,na.rm=TRUE)
beer_data[which(beer_data$IBU==max_ibu),c(2,5,8,10)]

# Developed a function that takes two arguements, dataframe and beer property and returns the median, mean,
# minimum, maximum, standard deviation, and range of the data for 
funcsummary <- function(x, property){
    medABV <- median(x[[property]], na.rm = TRUE)
    mnABV <- mean(x[[property]],  na.rm = TRUE)
    minABV <- min(x[[property]], na.rm = TRUE)
    maxABV <- max(x[[property]], na.rm = TRUE)
    sdABV <- sd(x[[property]], na.rm = TRUE)
    report <- setNames(data.frame(medABV, mnABV, minABV, maxABV, sdABV, (maxABV - minABV)), 
                       c("Median", "Mean", "Min", "Max", "StandardDeviation", "Range"))
    # Digits rounds the output of report to two digits
    print(report, digits = 3)
    lessmnABV <- beer_data[beer_data$ABV < mnABV, ]
    nrow(lessmnABV)
}
funcsummary(beer_data, "ABV")

# Subset beersbreweries dataset for ABV and IBU 
abv_ibu <- beer_data[ ,c(4:5)]
length(abv_ibu$ABV)
# Remove NA values from abv_ibu
abv_ibu2 <- abv_ibu[complete.cases(abv_ibu), ]
# Verify number of beers removed from the data set that have NA values for either IBu or ABV
delta <- length(abv_ibu$ABV) - length(abv_ibu2$ABV)
delta

# Create scatterplot of ABV vs. IBU
theme_update(plot.title = element_text(hjust = 0.5))
ggplot(abv_ibu2, aes(ABV, IBU, color = ABV)) + geom_point(shape = 16, size = 5, show.legend = FALSE, 
                                                          alpha = .2) + theme_minimal() + geom_smooth(method = 'lm', color = "red") + 
    ggtitle("ABV vs. IBU") + labs(x = "Alcohol by Volume", y = "Int'l Bitterness Unit")
cor(abv_ibu2$ABV, abv_ibu2$IBU, method = "pearson")


