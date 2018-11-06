# The Code Book

# Introduction
This report contains our findings about the beer and brewery industry in the United States. The completed analysis includes: number of breweries in each state, the average alcohol content (ABV) and bitterness (IBU) of beers in each state, the distribution of alcohol content in beers nationwide, and how the alcohol content of a beer affects its bitterness.  The data was originally housed in two .csv files,beers.csv and breweries.csv.

## Required R libraries
    * dplyr
    * reshape2
    * ggplot2
    * doBy
    * formattable

## Specifications
    * 'breweries' is a data frame consisting of 558 observations and 4 human readable variables named '1Brewery_id', 'Brewery_Name', 'City', and 'State'
    * 'beers' is a data frame consisting of 2410 observations and 7 human readable variables named 'Beer_Name', 'Beer_ID', 1ABV', 'IBU', 'Brewery_id', 'Style', and 'Ounces'
    * 'state_count' is a data frame consisting of 51 observations and 2 variables that is used to create a barplot showing number of breweries per state
    * 'sum_state_count returns a single integer that is the sum of all breweries in the United States
    * 'beer_data' is a data frame that is the result of merging 'beers' and 'breweries' by 'Brewery_id' consisting of 2410 observations and 10 human readable variables named 'Brewery_id', 'Brewery_Name', 'City', 'State', 'Beer_Name', 'Beer_ID', 'ABV', 'IBU', 'Brewery_id', 'Style', and 'Ounces'
    * 'median_abv_by_state' is a data frame consisting of 51 observations and 2 variables that calculates the median abv per state and is used to create a barplot of the data
    *  'median_ibu_by_state' is a data frame consisting of 51 observations and 2 variables that calculates the median ibuprofen per state and is used to create a barplot of the data
    *  'max_abv' is a data frame that subsets beer_data by ABV and state to find the overall max ABV observation
    * 'max_ibu' is a data frame that subsets beer_data by IBU and state to find the overall max IBU observation
    * 'funcsummary' is a function that takes one argument and produces the summary statistics, median, mean, min, max, standard deviation, and range of the 'ABV' variable.  The argument is typically a data frame.
    * 'medABV' calculates the median ABV value inside of 'funcsummary'    
    * 'mnABV' calculates the mean ABV value inside of 'funcsummary'    
    * 'minABV' calculates the min ABV value inside of 'funcsummary'
    * 'maxABV' calculates the max ABV value inside of 'funcsummary'
    * 'sdABV' calculates the standard deviation ABV value inside of 'funcsummary'     
    * 'report' is a data frame consisting of one observation and 6 variables that is the output of the 'funcsummary' function
    * 'abv_ibu' is a data frame consisting of 2410 observations and 2 variables that subsets 'beer_data' for ABV and IBU
    * 'abv_ibu2' is data frame consisting of 1405 observations and 2 variables that subsets 'abv_ibu', removing all NA values.  This data is used to create a scatterplot showing the relationship between ABV and IBU

## Research and Task Delineation
This was a Collaborative analysis completed by Matthew Rega and Stephen Merritt using R.  Both researchers completed independent merges of the beers and breweries data frame to verify accuracy and completeness of the merged dataset.  Matthew completed the code for questions 3, 4, and 5, along with creating the READme file on Github.  He also found the cor() function in R for question 7.  Stephen completed the code for questions 1, 6, and 7, along with creating this codebook.  All beer styles were verified for accuracy on www.beeradvocate.com. 
