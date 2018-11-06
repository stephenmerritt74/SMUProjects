# CaseStudy2
Kevin Dickens & Stephen Merritt  
November 26, 2017  

# Abstract
---
The study described in this proposal seeks to analyze procrastination and developmental data by country in order to better understand the statistical ties between the two and the spatial distribution across the globe.  The goal of this study is to provide clients useful information to avoid large overhead costs due to procrastination costs.

# Introduction
---
[Recent reports](https://www.cnbc.com/id/46750183) state that the average cost of procrastination to businesses stands at an estimated $10,396 per employee per year.  As the world economy recovers from the recession, businesses the globe over are moving to open locations in exploding markets to gain access to valuable resources and assets to expand their reach.  Many of these hot regions exist in developing regions that are underserved by their governments.  Procrastination is known to be highly correlated with anxiety and access to necessary quality of life components such as food and housing.   Of particular interest to any business seeking to expand globally should be the levels of procrastination and the relationship to various developmental indices.  After all, a productive worker is a happy worker, and a happy worker stays highly engaged over the course of the work period reducing overheard cost to business!

Businesses requesting this analysis will be treated to a study of the spatial relationships and distributions of procrastination and human development.  This analysis will look at how procrastination rates and development patterns are distributed across the globe and look at the spatial distributions of the various procrastination scale average for participating countries and human development. The spatial interpretation of data will inform readers of hot spots of high and low procrastination rates.

This study will also perform basic statistical analysis to better understand and interpret both the spatial data and the underlying procrastination data as well.  The findings will inform readers on the distributions of the data and allow them to look at the included maps to determine which countries lie above or below mean values as well as determine underlying relationships between various procrastination indices and several other factors such as human development, occupation, gender, age, and income.

Fundamentally, this study will seek to answer the following questions:

* What is the mean AIP, GP, SWLS, and DP for each country?
* What is the HDI for each country?
* Are there any relationships between the procrastination indices and HDI?

International businesses must find locations with the greatest productivity to ensure they minimize these costs on their pocket-book.  Several indices exist to track procrastination, which is correlated strongly with anxiety, unhappiness, and lack of access to resources.  Using commonly available data we can show which countries have high rates of procrastination and attempt to point clients towards regions of the world with lower procrastination rates but also abundant resources.

## Scope
---
The scope of this analytical research is limited to the data initially scrapped for research.  As such the scope of the data pertains to 2016 UN HDI data and procrastination survey responses from 4264 individuals representing only 86 of the officially recognized 193 countries.  The survey responses only required procrastination indices to be completed, other demographic data was optional and as such, some countries, groups, or occupations may be under represented.

## Required Libraries

```r
library(rvest)
library(stringr)
library(ggplot2)
library(knitr)
library(dplyr)
```

```
## Warning: Installed Rcpp (0.12.12) different from Rcpp used to build dplyr (0.12.11).
## Please reinstall dplyr to avoid random crashes or undefined behavior.
```

```r
library(plyr)
library(maps)
```

The analysis performed by this study was created using R, a free statistical programming environment available [here.](https://www.r-project.org/) In order to recreate the research these R packages must be installed and called into the environment.

# About the Data
---
The data in this project consists of two primary files: Procrastination.csv and HumanDevelopmentIndex.csv. Procrastination.csv contains 4265 observations of survey participants and captures 61 variables that include demographic data and various procrastination index responses. HumanDevelopmentIndex.csv contains 191 records with 3 variables that capture the HDI score, category, and the country for whom the score is calculated. Both tables contain headers. Procrastination.csv comes from an online survey response while HumanDevelopmentIndex.csv was scrapped manually from Wikipedia.

The procrastination data in-particular required a great deal of cleaning to make it useful for analysis. Most of the column names required renaming to remove long names or clarify the intent of the variable. Several non-sensical responses for various fields were removed entirely and treated as missing values. The occupation variable field proved especially troublesome as most open text fields end up. Many "like" occupations were merged together however due to the nature of free text fields there were simply too many unique fields to collapse further without removing meaningful information. Eventually the two tables are merged together using the Country variable.

## Data Source
---
The Human Development Index (HDI) data comes from [Wikipedia](https://en.wikipedia.org/wiki/List_of_countries_by_Human_Development_Index#Complete_list_of_countries).  This data in turn comes from a United Nations report as indicated on the Wikipedia website and listed below.

1. "Human Development Report 2016 - "Human Development for Everyone"" (PDF). HDRO (Human Development Report Office) United Nations Development Programme. pp. 198-201. Retrieved 2 September 2017.

## Data Integrity
---
The original data provided in procrastination.csv was gathered from a survey with multiple open text fields.  Additionally, due to desired anonymity only the procrastination responses were mandatory fields.  As such, the condition of the data necessitates quite a bit of cleaning in order to perform any clear and useful analysis.


```r
#Evaluate data types of variables
#Data Ingest and initialization
rawdata<-read.csv("~/6306DoingDataScience/6306CaseStudy2/Data/Procrastination.csv", header=TRUE)

#str(rawdata)

#2a. Output Rows and Columns
nrow(rawdata)
```

```
## [1] 4264
```

```r
ncol(rawdata)
```

```
## [1] 61
```

The first step in tidying any data is to look at the data, figure out what is present, and then evaluate what transformations need to occur to make the data useful.

At first glance, we see a dataframe structure of 4264 observations with 61 separate variables.  These variables include 2 numeric, 12 factor, and 47 integer variables.  Many of the factor variables include NULL strings.  Some of the integer and numeric variables include NAs.  Both will affect analysis so it is important to understand how many of each are present in the data.


```r
#Diagnostic outputs to generate the number of NA's
NATidy<-sapply(rawdata, function(y) sum(length(which(is.na(y)))))
#NATidy

#Diagnostic outputs to generate the number of Blank string fields
BlankTidy<-sapply(rawdata, function(y) table(as.character(y)=="")["TRUE"])
BlankTidy<-BlankTidy[c("Gender.TRUE", "Kids.TRUE", "Edu.TRUE", "Work.Status.TRUE", "Current.Occupation.TRUE", "Community.size.TRUE", "Country.of.residence.TRUE", "Marital.Status.TRUE")]
```

Many of the integers and numeric variables contain NAs.  For some, such as the tenure in years and months, this is likely not an issue.  Some respondents likely left one or the other blank due to inherent rounding that takes place.  However, enough individuals left Age and Annual Income blank that it may affect analysis later.  Particularly if a country with small sample size left it blank it may skew analysis results in those countries.

Likewise, the blank character fields or levels in a factor pose similar issues that might cause analysis to skew in countries with a low number of respondents.  Roughly only half of respondents chose to fill out the occupation field.  Most of the other fields saw some blank strings too, but at a far less significant rate.

## Tidying The Qualtrics Data

```r
#Assigning to new variable.  This is done to make it easier to go back to clean data without importing again.
tidydata<-rawdata

#2b.  Renaming columns with meaningful and compressed names.  See codebook for more details.
colnames(tidydata)<-c("Age", "Gender", "Kids", "Education", "WorkStatus", "AnnIncome", "Occupation","TenureY",
                     "TenureM", "CommSize", "Country", "Marital", "Sons", "Daughters", "DP1", "DP2", "DP3", "DP4", "DP5",
                     "AIP1", "AIP2", "AIP3", "AIP4", "AIP5", "AIP6", "AIP7", "AIP8", "AIP9", "AIP10", "AIP11", "AIP12",
                     "AIP13", "AIP14", "AIP15", "GP1", "GP2", "GP3", "GP4", "GP5", "GP6", "GP7", "GP8", "GP9", "GP10",
                     "GP11", "GP12", "GP13", "GP14", "GP15", "GP16", "GP17", "GP18", "GP19", "GP20", "SWLS1", "SWLS2",
                     "SWLS3", "SWLS4", "SWLS5", "SelfP", "OthersP")

#2d A vector is created with appropriate column names to be made into characters.
char<-c("Gender", "Kids", "Education", "WorkStatus", "Occupation", "CommSize", "Country", "Marital", "Sons", "SelfP", "OthersP")
tidydata[char] <- sapply(tidydata[char], as.character) #All columns in char are converted to character fields.
```

The non-sensical or over descriptive column names are replaced with less cumbersome but still descriptive variable names.  For reference to the specific questions and to see which variables in the new data frame match the old variables, see the [codebook](https://github.com/stephenmerritt74/6306CaseStudy2/blob/master/Codebook.md) on the GitHub repository.


```r
#2c-i.  Tenure (Years of service) are rounded to the nearest integer and then converted to integers.  Finally the 999 values are converted to NAs.
tidydata$TenureY<-round(tidydata$TenureY)
tidydata$TenureY<-as.integer(tidydata$TenureY)
tidydata$TenureY[tidydata$TenureY ==999] <- NA

#2-c-i Rounding of Age to remove half-years.
tidydata$Age<-floor(tidydata$Age)

#2-c-i Remove "kids" from the Kids Variable response so the end result is a Yes/No answer.
tidydata$Kids<-gsub(" Kids", "", tidydata$Kids, fixed=TRUE)

#2-c-i Fixed several country spellings and syntax to match HDI tables (ex. Isreal to Israel)
tidydata$Country[tidydata$Country == 'Isreal'] <- "Israel"
tidydata$Country[tidydata$Country == 'Antigua'] <- "Antigua & Barbuda"
tidydata$Country[tidydata$Country == 'Columbia'] <- "Colombia"
tidydata$Country[tidydata$Country == 'Macao'] <- "China"
tidydata$Country[tidydata$Country == 'Taiwan'] <- "China"
tidydata$Country[tidydata$Country == 'Guam'] <- "United States"
tidydata$Country[tidydata$Country == 'Puerto Rico'] <- "United States"
tidydata$Country[tidydata$Country == 'Yugoslavia'] <- "Serbia"
tidydata$Country[tidydata$Country == 'Bermuda'] <- "United Kingdom"

#2c-iii.  All entries with Country=0 are replaced with blank (missing) values
tidydata$Country[tidydata$Country == '0'] <- ""

#2c-ii.  Improperly encoded male and female values are encoded into their proper values as per notes.  Finally the field is converted to an integer.
tidydata$Sons[tidydata$Sons == 'Male'] <- 1
tidydata$Sons[tidydata$Sons == 'Female'] <- 2
tidydata$Sons<-as.integer(tidydata$Sons)

#2c-iv.  Cleaning up the Occupation variable
tidydata$Occupation<-trimws(tidydata$Occupation, which=c("left")) #Trim the White space that appears in front of some values.
tidydata$Occupation <- gsub("(?<=^| )([a-z])", "\\U\\1", tolower(tidydata$Occupation), perl = T) # Converts all entries to lower space and then capitalizes the first letter of each word.

#All nonsense values that are replaced to indicate no response
tidydata$Occupation[tidydata$Occupation == '0'] <- ""
tidydata$Occupation[tidydata$Occupation == 'Please Specify'] <- ""
tidydata$Occupation[tidydata$Occupation == 'Na'] <- ""
tidydata$Occupation[tidydata$Occupation == 'Ouh'] <- ""
tidydata$Occupation[tidydata$Occupation == 'Fdsdf'] <- ""
tidydata$Occupation[tidydata$Occupation == 'Abc'] <- ""
tidydata$Occupation[tidydata$Occupation == 'S'] <- ""

#Cleaned up the occupation variable to merge several values together, cleanup spelling issues, foreign language responses, abbreviations, etc.
tidydata$Occupation[grepl("Teacher", tidydata$Occupation, ignore.case=FALSE)] <- "Educator"
tidydata$Occupation[grepl("Educator", tidydata$Occupation, ignore.case=FALSE)] <- "Educator"
tidydata$Occupation[grepl("Professor", tidydata$Occupation, ignore.case=FALSE)] <- "Educator"
tidydata$Occupation[grepl("Faculty", tidydata$Occupation, ignore.case=FALSE)] <- "Educator"
tidydata$Occupation[grepl("Profucer", tidydata$Occupation, ignore.case=FALSE)] <- "Educator"
tidydata$Occupation[grepl("Education Specialist", tidydata$Occupation, ignore.case=FALSE)] <- "Educator"
tidydata$Occupation[grepl("Assistant", tidydata$Occupation, ignore.case=FALSE)] <- "Assistant"
tidydata$Occupation[grepl("Asst", tidydata$Occupation, ignore.case=FALSE)] <- "Assistant"
tidydata$Occupation[grepl("Student", tidydata$Occupation, ignore.case=FALSE)] <- "Student"
tidydata$Occupation[grepl("Doctoral", tidydata$Occupation, ignore.case=FALSE)] <- "Student"
tidydata$Occupation[grepl("Postdoc", tidydata$Occupation, ignore.case=FALSE)] <- "Student"
tidydata$Occupation[grepl("Studey", tidydata$Occupation, ignore.case=FALSE)] <- "Student"
tidydata$Occupation[grepl("School", tidydata$Occupation, ignore.case=FALSE)] <- "Student"
tidydata$Occupation[grepl("Nurse", tidydata$Occupation, ignore.case=FALSE)] <- "Nurse"
tidydata$Occupation[grepl("Rn", tidydata$Occupation, ignore.case=FALSE)] <- "Nurse"
tidydata$Occupation[grepl("Lpn", tidydata$Occupation, ignore.case=FALSE)] <- "Nurse"
tidydata$Occupation[grepl("Crna", tidydata$Occupation, ignore.case=FALSE)] <- "Nurse"
tidydata$Occupation[grepl("Programmer", tidydata$Occupation, ignore.case=FALSE)] <- "Programmer"
tidydata$Occupation[grepl("Developer", tidydata$Occupation, ignore.case=FALSE)] <- "Programmer"
tidydata$Occupation[grepl("Engineer", tidydata$Occupation, ignore.case=FALSE)] <- "Engineer"
tidydata$Occupation[grepl("Consultant", tidydata$Occupation, ignore.case=FALSE)] <- "Consultant"
tidydata$Occupation[grepl("Businesswoman", tidydata$Occupation, ignore.case=FALSE)] <- "Business"
tidydata$Occupation[grepl("Sales", tidydata$Occupation, ignore.case=FALSE)] <- "Sales"
tidydata$Occupation[grepl("Mktg", tidydata$Occupation, ignore.case=FALSE)] <- "Marketing"
tidydata$Occupation[grepl("Supervisor", tidydata$Occupation, ignore.case=FALSE)] <- "Supervisor"
tidydata$Occupation[grepl("Coordinatore Operativo", tidydata$Occupation, ignore.case=FALSE)] <- "Operational Coordinator"
tidydata$Occupation[grepl("Md", tidydata$Occupation, ignore.case=FALSE)] <- "Doctor"
tidydata$Occupation[grepl("Vmd", tidydata$Occupation, ignore.case=FALSE)] <- "Veternarian"
tidydata$Occupation[grepl("Psychologis", tidydata$Occupation, ignore.case=FALSE)] <- "Psychologist"
tidydata$Occupation[grepl("Gove Service", tidydata$Occupation, ignore.case=FALSE)] <- "Civil Service"
tidydata$Occupation[grepl("Government", tidydata$Occupation, ignore.case=FALSE)] <- "Civil Service"
tidydata$Occupation[grepl("Vidoe", tidydata$Occupation, ignore.case=FALSE)] <- "Video"
tidydata$Occupation<-gsub("\\It\\b", "IT", tidydata$Occupation)
tidydata$Occupation<-gsub("\\Emt\\b", "EMT", tidydata$Occupation)
tidydata$Occupation<-gsub("\\Ceo\\b", "CEO", tidydata$Occupation)
tidydata$Occupation<-gsub("\\Cad\\b", "CAD", tidydata$Occupation)
tidydata$Occupation<-gsub("\\Pca\\b", "PCA", tidydata$Occupation)
```

After the initial evaluation of the data to better understand the distribution of NAs and missing character strings and cleaning up the variable names it came time to sort out the significant data issues pertinent to analysis.

Several variables contained coded values that were likely generated by collection software to indicate NULL values.  These could include 999, 0, or negative values.  All of these were recoded as either a missing string or an NA as appropriate to the variable format.

Several variables were the wrong structure type and this needed correction in order to allow for proper analysis.  Age allowed for fractional values rather than only whole integers so the values were rounded down.  The Sons and Daughters fields were both factors and Sons had a number of odd values that appear to have carried over from the gender field.  These coded values were recoded correctly and both were converted to integers since partial children shouldn't exist in the real world.

The Country variable contained two issues.  The first issue were numerous misspellings of countries which were easily corrected.  The second was a potential mismatch with the Country field of the HDI data scrapped later in this analysis.  Such conflicts were renamed in favor of the HDI data.  Some values did not exist in the HDI data because they are not separate countries so these territories, such as Guam, were rolled into their parent nation.

The occupation field required the most work and still remains of dubious value.  With over 600 unique occupations in the untidied dataset due to the nature of open text fields, we wanted to make the field more legible but not filter out the usefulness of individual respondents.  As such the many garbage responses such as "Fdsdf", "Ouh", or "Please Specify" were recoded as missing values.    Where possible common words were used to collapse like jobs together.  Examples include "Teacher", "Faculty", and "Professor" collapsing down into "Educator".  Several other typos and translation issues were corrected but the end result is still roughly 500 unique occupations.

Further work could be done to aggregate these jobs into common categories such as "Education", "Agriculture", "Finance", "Technology" etc. but since this specific analysis did not involve a deep look at occupation those decisions were left to future analysis.


```r
#2e. Generation of the mean DP, AIP, GP, and SWLS indices.  Note that na.rm=TRUE is enabled in case NAs exist.
tidydata$DPMean <- rowMeans(subset(tidydata, select = c(DP1, DP2, DP3, DP4, DP5)), na.rm = TRUE)
tidydata$AIPMean <- rowMeans(subset(tidydata, select = c(AIP1, AIP2, AIP3, AIP4, AIP5, AIP6, AIP7, AIP8, AIP9, AIP10, AIP11, AIP12, AIP13, AIP14, AIP15)), na.rm = TRUE)
tidydata$GPMean <- rowMeans(subset(tidydata, select = c(GP1, GP2, GP3, GP4, GP5, GP6, GP7, GP8, GP9, GP10, GP11, GP12, GP13, GP14, GP15, GP16, GP17, GP18, GP19, GP20)), na.rm = TRUE)
tidydata$SWLSMean <- rowMeans(subset(tidydata, select = c(SWLS1, SWLS2, SWLS3, SWLS4, SWLS5)), na.rm = TRUE)
tidydata$AIPMean<-round(tidydata$AIPMean, digits=0) #Due to math calculations the decimal place of AIP is more than the mean columns of the others.  For consistency it is shortned to match the others.
```

Finally, a mean score of AIP, DP, GP, and SWLS were generated for each respondent.  These would be used in later spatial and statistical analysis.

## HDI Data Scraping

```r
# 3a scraped Human Development index data from Wikipedia
url <- "https://en.wikipedia.org/wiki/List_of_countries_by_Human_Development_Index#Complete_list_of_countries"
webpage <- read_html(url)
# Determined tables 4 - 14 to contain the Human Development Index data
# Created an empty list, 'tbls' to house the results of the webscrape
tbls <- list()
for (i in c(4,5,7,8,10,11,13,14)){
    tbls[i] <- webpage %>%
        html_nodes("table") %>%
        .[i] %>%
        html_table(fill = TRUE) 
    }
# Used plyr command from dplyr package to convert tbls into a data frame called HDI_df
HDI_df <- (plyr::ldply(tbls))
# Created 'df2' to combine Country/Territory and Country columns of HDI_df
df2 <- data.frame(HDI_df = c(HDI_df[,"Country/Territory"], HDI_df[,"Country"]))
df2 <- sapply(df2, as.character)
# Removed NAs from df2 dataframe
df2 <- setNames(as.data.frame(df2[complete.cases(df2), ]), "Country")
# Removed "Change in rank" info from df2
df2 <- subset(df2, Country != "Change in rank from previous year[1]")
# Removed "Change in rank" info from HDI_df
HDI_df <- HDI_df[-c(1, 28, 54, 83, 112, 133, 155, 177), ]
#HDI_df2 combines HDI_df and df2 via cbind command
HDI_df2 <- cbind(HDI_df, df2)
# Question 3a. Subset unnecessary columns leaving only HDI and Country
HDI_df2 <- HDI_df2[,-c(1, 2, 4)]
# Re-index the columns for better presentation in R
rownames(HDI_df2) <- NULL

# Question 3b Create a new column categorizing the countries
# Convert the HDI column to numeric data
HDI_df2$HDI <- as.numeric(HDI_df2$HDI)
# Create levels via the cut command to mirror the webiste table categories with Swaziland being
# the cutoff for Low Human Development, Moldova being the cutoff for Medium Human Development, 
# Belarus being the cutoff for High Human Development, and Norway being at the very top 
# for very High Human Development
HDI_df2$HDICategory<- cut(HDI_df2$HDI, c(-Inf, 0.549, 0.699, 0.799, Inf))
levels(HDI_df2$HDICategory) <- c("Low human development", "Medium human development", 
                               "High human development", "Very high human development")
write.csv(HDI_df2, "~/6306DoingDataScience/6306CaseStudy2/Data/HumanDevelopmentIndex.csv", row.names = FALSE)
# Israel is mispelled as Isreal in the dataset and needs to be replaced prior to merging

# 3c Merged tidy data of procastiantion.csv to HDI dataframe 
tidydata1 <- merge(HDI_df2, tidydata, by = "Country", all = TRUE)
kable(tidydata1[1:5, c(1:3,9,64:67)], format = "markdown",
      caption = "First Five Rows of Tidy Data")
```



|Country     |   HDI|HDICategory            | AnnIncome| DPMean| AIPMean| GPMean| SWLSMean|
|:-----------|-----:|:----------------------|---------:|------:|-------:|------:|--------:|
|Afghanistan | 0.479|Low human development  |     87500|    3.2|       3|    3.2|      2.4|
|Afghanistan | 0.479|Low human development  |     10000|    3.2|       3|    2.8|      1.4|
|Afghanistan | 0.479|Low human development  |     10000|    3.0|       3|    3.2|      2.8|
|Afghanistan | 0.479|Low human development  |    150000|    3.6|       4|    3.7|      2.4|
|Albania     | 0.764|High human development |     87500|    2.4|       2|    3.0|      3.8|

```r
#6b.  Export tidydata to csv.  Includes HDI.
write.csv(tidydata1, "tidydataHDI.csv")
```

Scraping the data from [Wikipedia](https://en.wikipedia.org/wiki/List_of_countries_by_Human_Development_Index#Complete_list_of_countries) presented a unique challenge to determine which of the multiple HTML tables contained the appropriate HDI data.  HTML tables 4,5,7,8,10,11,13, and 14 contained the desired data, necessitating a loop to ensure data set integrity.  The output was not clean, with the country data coming in 2 separate columns that were offset from one another and with different column names.  Ultimately, it was necessary to create a separate dataset containing only the country column, and then combine that data with the original HDI data and subset the columns appropriately.  The resulting HumanDevelopmentIndex.csv contains HDI and HDI level data for 189 distinct countries.  This data is ultimately combined with the tidy data from the survey for further analysis.

# Analysis
---

## Statistical Analysis
---
Below are the statistical results of analysis when looking deeper into the procrastination question concerning developmental countries.  As a reminder, the survey data proves rather poor for this analysis due to inconsistent responses, missing data, and low sample size for many regions of the world.

## Exploratory Data Analysis
---


```r
# 4a. Based on average retirement ages worldwide, source https://tradingeconomics.com/country-list/retirement-age-men, decided to remove all data
# above the age of 67.5
tidydata18_67 <- subset(tidydata1, Age > 18 & Age < 67.6)

# 4b. Created a function to find the summary stats for Age, Income, HDI, DPMean, GPMean, SWLSMean, and AIPMean.  
funcsummary <- function(x, property){
    med <- median(x[[property]], na.rm = TRUE)
    IQR <- IQR(x[[property]], na.rm = TRUE)
    mn <- mean(x[[property]],  na.rm = TRUE)
    sd <- sd(x[[property]],  na.rm = TRUE)
    min <- min(x[[property]], na.rm = TRUE)
    max <- max(x[[property]], na.rm = TRUE)
    report <- setNames(data.frame(med, IQR, mn, sd, min, max, (max - min)), 
                       c("Median", "IQR", "Mean", "SD", "Min", "Max", "Range"))
    # Digits rounds the output of report to two digits
    kable(report, digits = 3, format = "markdown", 
          caption = paste0("Summary Statisitics for ", property, sep = " "))
   
}
```

After considering the available range of ages that could be examined with the survey results, we decided to keep all data for men and women between ages 18 and 67.  According to recent world [retirement](http://chartsbin.com/view/2466) age data, this subset selection appeared most appropriate.  The next lowest age cutoff would have been at 55, which would have eliminated a significant amount of the population.

### Summary Statistics for Age

```r
funcsummary(tidydata18_67, "Age")
```



| Median| IQR|   Mean|     SD| Min| Max| Range|
|------:|---:|------:|------:|---:|---:|-----:|
|     37|  17| 37.863| 13.298|  19|  67|    48|
### Summary Statistics for Annual Income

```r
funcsummary(tidydata18_67, "AnnIncome")
```



| Median|   IQR|     Mean|       SD|   Min|    Max|  Range|
|------:|-----:|--------:|--------:|-----:|------:|------:|
|  45000| 72500| 59731.65| 55174.79| 10000| 250000| 240000|
### Summary Statistics for HDI

```r
funcsummary(tidydata18_67, "HDI")
```



| Median| IQR|  Mean|    SD|   Min|   Max| Range|
|------:|---:|-----:|-----:|-----:|-----:|-----:|
|   0.92|   0| 0.905| 0.056| 0.479| 0.949|  0.47|
### Summary Statistics for DP Mean

```r
funcsummary(tidydata18_67, "DPMean")
```



| Median| IQR|  Mean|    SD| Min| Max| Range|
|------:|---:|-----:|-----:|---:|---:|-----:|
|      3| 1.4| 3.053| 0.969|   1|   5|     4|
### Summary Statistics for AIP Mean

```r
funcsummary(tidydata18_67, "AIPMean")
```



| Median| IQR|  Mean|    SD| Min| Max| Range|
|------:|---:|-----:|-----:|---:|---:|-----:|
|      3|   2| 2.972| 0.854|   1|   5|     4|
### Summary Statistics for GP Mean

```r
funcsummary(tidydata18_67, "GPMean")
```



| Median|  IQR|  Mean|    SD| Min| Max| Range|
|------:|----:|-----:|-----:|---:|---:|-----:|
|   3.25| 0.95| 3.243| 0.688|   1|   5|     4|
### Summary Statistics for SWLS

```r
funcsummary(tidydata18_67, "SWLSMean")
```



| Median| IQR|  Mean|    SD| Min| Max| Range|
|------:|---:|-----:|-----:|---:|---:|-----:|
|      3| 1.4| 3.043| 0.972|   1|   5|     4|

## Annual Income and GP Mean Histograms

```r
# 4b (cont.) Created a histogram for both Annual Income and General Procrastination Scale Mean
hist(tidydata18_67$AnnIncome, col = "blue3", main = "Histogram of Annual Income",
     xlab = "Annual Income in USD")
```

![](CaseStudy2_files/figure-html/unnamed-chunk-16-1.png)<!-- -->

```r
hist(tidydata18_67$GPMean, col = "blue3", main = "Histogram of the General Procrastination Mean",
     xlab = "Mean of General Procastation Scale")
```

![](CaseStudy2_files/figure-html/unnamed-chunk-16-2.png)<!-- -->

When reviewing annual income data in a histogram, we find that it is right skewed with the vast majority of the responses being at or below $50,000 per year.  The GP mean histogram is left skewed with the majority of mean GP scores being 3 or above.


```r
# 4c Created dataframes to provide the frequency of Gender, WorkStatus, and Occupation
tidydata18_67$WorkStatus <- as.factor(tidydata18_67$WorkStatus)
tidydata18_67$Gender <- as.factor(tidydata18_67$Gender)
#tidydata18_67$Country <- as.factor(tidydata18_67$Country)
#str(tidydata18_67$Country)
ws <- as.data.frame(count(tidydata18_67, 'WorkStatus'))
kable(ws, format = "markdown", caption = "Frequency of Work Status Responses")
```



|WorkStatus | freq|
|:----------|----:|
|           |   42|
|full-time  | 2259|
|part-time  |  463|
|retired    |  151|
|student    |  837|
|unemployed |  257|

```r
gen <- as.data.frame(count(tidydata18_67, 'Gender'))
kable(gen, format = "markdown", caption = "Frequency of Gender Responses")
```



|Gender | freq|
|:------|----:|
|       |    6|
|Female | 2295|
|Male   | 1708|

```r
occ <- as.data.frame(count(tidydata18_67, 'Occupation'))
# Labeled all occupations with a count of 1 as "Other"
occ$Occupation[which(occ$freq == 1)] <- "Other"
occ <- as.data.frame(count(occ, 'Occupation'))
```

```
## Using freq as weighting variable
```

```r
kable(occ, format = "markdown", caption = "Frequency of Occupation Responses")
```



|Occupation                              | freq|
|:---------------------------------------|----:|
|                                        | 2644|
|Academic                                |    2|
|Accountant                              |    2|
|Accounting                              |    2|
|Accounting Manager                      |    2|
|Admin Assist                            |    2|
|Administrator                           |   10|
|Analyst                                 |    5|
|Architect                               |    4|
|Art Director                            |    2|
|Artist                                  |    6|
|Assistant                               |   52|
|Associate                               |    2|
|Attorney                                |   49|
|Bank Teller                             |    3|
|Banker                                  |    2|
|Business                                |    2|
|Business Owner                          |    7|
|CEO                                     |    3|
|Chief Of Staff                          |    2|
|Civil Servant                           |    2|
|Civil Service                           |    2|
|Clerk                                   |    5|
|Clutter Clearer,  Video Editor, Caterer |    2|
|Communications                          |    2|
|Consultant                              |   43|
|Consumer Case Coordinator               |    2|
|Copy Writer                             |    2|
|Counselor                               |    2|
|Creative Director                       |    2|
|Customer Service                        |    9|
|Dentist                                 |    2|
|Deputy Director                         |    3|
|Designer                                |    4|
|Diplomat                                |    2|
|Director                                |   10|
|Doctor; Physician                       |   16|
|Driver                                  |    2|
|Editor                                  |   21|
|Educator                                |  157|
|Engineer                                |   47|
|Epidemiologist                          |    2|
|Executive Director                      |    2|
|Finance                                 |    5|
|Financial Advisor                       |   11|
|Financial Analyst                       |    2|
|Geologist                               |    2|
|Graphic Designer                        |   10|
|Home Maker                              |   11|
|Houswife                                |   16|
|Human Resource Manager                  |    3|
|Insurance                               |    2|
|Insurance Agent                         |    4|
|Internship                              |    2|
|IT                                      |    2|
|IT Director                             |    2|
|IT Specialist                           |    2|
|IT Support                              |    2|
|Journalist                              |    6|
|Journalist (freelance)                  |    2|
|Laboratory Technician                   |    2|
|Law Clerk                               |    2|
|Law Enforcement                         |    3|
|Lecturer                                |    2|
|Letter Carrier                          |    2|
|Librarian                               |    9|
|Library Technician                      |    2|
|Manager                                 |   32|
|Market Analyst                          |    5|
|Market Research Analyst                 |    2|
|Marketing                               |   21|
|Marketing Copywriter                    |    2|
|Musician                                |    3|
|Nanny                                   |    5|
|Nurse                                   |   20|
|Operations Manager                      |    4|
|Other                                   |  374|
|Owner                                   |    2|
|Paralegal                               |    2|
|Paraprofessional                        |    2|
|Pastor ; Life Coach  Clergy             |    5|
|Pharmacist                              |    3|
|Policy Analyst                          |    2|
|President                               |    7|
|Press Officer                           |    2|
|Programmer                              |   34|
|Project Manager                         |   10|
|Psychologist                            |    8|
|Psychotherapist                         |    3|
|Receptionist                            |    3|
|Research Associate                      |    4|
|Research Scientist                      |    8|
|Researcher                              |    3|
|Retail                                  |    4|
|Retired                                 |   25|
|Sales                                   |   18|
|Scientist                               |   12|
|Secretary                               |    5|
|Self Employed                           |    3|
|Self-employed Photographer              |    2|
|Server                                  |   10|
|Social Worker                           |    7|
|Software Pro                            |    2|
|Stocker                                 |    2|
|Student                                 |   27|
|Supervisor                              |   10|
|Systems Analyst                         |    2|
|Technical Writer                        |    4|
|Training Coordinator                    |    2|
|Translator                              |    6|
|Tutor                                   |    5|
|Unemployed                              |   18|
|Veterinarian                            |    2|
|Vice-president                          |    2|
|Web Designer                            |    4|
|Writer                                  |   19|
|Writer/editor                           |    2|

As discussed in the data tidying section, even following a significant cleanup of the occupation column, 500 unique occupations remained in the dataset.  Those occupations that received a count of 1 were combined into a separate category of "other", combining 374 unique entries.


```r
# 4d Determined the counts of participants per country
ppc <- setNames(tally(group_by(tidydata18_67, Country), sort = TRUE), c("Country", "Count"))
kable(ppc, format = "markdown", caption = "Frequency of Response per Country")
```



|Country            | Count|
|:------------------|-----:|
|United States      |  2771|
|Canada             |   243|
|United Kingdom     |   179|
|                   |   159|
|Australia          |    99|
|India              |    78|
|Italy              |    60|
|Germany            |    36|
|Brazil             |    20|
|Ireland            |    19|
|Israel             |    19|
|Netherlands        |    18|
|Sweden             |    15|
|China              |    14|
|Norway             |    14|
|France             |    13|
|Japan              |    13|
|Spain              |    13|
|Finland            |    12|
|New Zealand        |    12|
|South Africa       |    12|
|Mexico             |    11|
|Philippines        |    11|
|Switzerland        |    11|
|Greece             |    10|
|Belgium            |     9|
|Denmark            |     9|
|Turkey             |     9|
|Hong Kong          |     7|
|Portugal           |     7|
|Slovenia           |     6|
|Poland             |     5|
|Romania            |     5|
|Chile              |     4|
|Croatia            |     4|
|Malaysia           |     4|
|Singapore          |     4|
|Afghanistan        |     3|
|Algeria            |     3|
|Argentina          |     3|
|Austria            |     3|
|Czech Republic     |     3|
|Ecuador            |     3|
|Uruguay            |     3|
|Albania            |     2|
|Bulgaria           |     2|
|Colombia           |     2|
|Ghana              |     2|
|Iran               |     2|
|Malta              |     2|
|Peru               |     2|
|Saudi Arabia       |     2|
|Serbia             |     2|
|South Korea        |     2|
|Thailand           |     2|
|Ukraine            |     2|
|Venezuela          |     2|
|Andorra            |     1|
|Bahamas            |     1|
|Barbados           |     1|
|Bolivia            |     1|
|Botswana           |     1|
|Cyprus             |     1|
|Dominican Republic |     1|
|Egypt              |     1|
|El Salvador        |     1|
|Guyana             |     1|
|Hungary            |     1|
|Iceland            |     1|
|Jamaica            |     1|
|Kenya              |     1|
|Lithuania          |     1|
|Luxembourg         |     1|
|Macedonia          |     1|
|Morocco            |     1|
|Myanmar            |     1|
|Nicaragua          |     1|
|Pakistan           |     1|
|Panama             |     1|
|Qatar              |     1|
|Russia             |     1|
|Sri Lanka          |     1|
|Vietnam            |     1|
|Antigua & Barbuda  |     1|

```r
# 4e Determine where self assessment of procrastination match others assessment
tidydata18_67$ProsMatch <- mapply(grepl, pattern = tidydata18_67$SelfP, x = tidydata18_67$OthersP)
#tidydata18_67[, ProsMatch := grepl("SelfP", "OthersP"), by = x]
match <- setNames(tally(group_by(tidydata18_67, ProsMatch)), c("Logical", "Count"))
kable(match, format = "markdown", caption = "Number of Self Perception Matches")
```



|Logical | Count|
|:-------|-----:|
|FALSE   |  1181|
|TRUE    |  2828|

### EDA Results
The survey results indicate a bias towards Highly Developed Western nations with almost 80% of the respondents coming from the US, Canada, and the United Kingdom.  51 of the 84 countries represented with responses had under 5 total responses.  Of the people who chose to identify an occupation (there were 2644 non-responses for occupation), "educator"" was the most frequent survey occupation response (157).  The nearest competitor to "educator" as an occupation response was "assistant".  57% of the respondents were women and 70% of the respondents perceptions of their own propensity to procrastinate or not procrastinate matched the perceptions of others.  

## Top Fifteen Nations for AIP and GP (minimum 5 responses)

```r
#5b Create a barchart for the top 15 nations in average pro
topfifteen <- tidydata18_67[ ,c("Country", "GPMean", "HDI")]
topfifteen <- setNames(aggregate(topfifteen[ ,2:3], list(Country=topfifteen$Country), mean), 
                       c("Country", "GPMean", "HDI"))
topfifteen <- merge(topfifteen, ppc, by = "Country", all = TRUE)
topfifteen <- subset(topfifteen, Count >=5)
topfifteen <- topfifteen[order(-topfifteen$GPMean), ]
topfifteen$HumanDev<- cut(topfifteen$HDI, c(-Inf, 0.549, 0.699, 0.799, Inf))
levels(topfifteen$HumanDev) <- c("Low human development", "Medium human development", 
                                 "High human development", "Very high human development")
topfifteen <- topfifteen[(1:15), ]
theme_update(plot.title = element_text(hjust = 0.5))
ggplot(topfifteen, aes(x = reorder(Country, GPMean), y = GPMean, 
                    fill = HumanDev)) + 
    geom_bar(stat = "identity", width = 0.5) + 
    ggtitle("Top Fifteen Countries for General Procrastination (GP) Mean") +
    labs(x = "Country", y = "GP Mean") +
    coord_flip() +
    scale_fill_brewer(palette = "Dark2")
```

![](CaseStudy2_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

```r
#6c Table of topfifteen nations for General Procrastiantion Mean
kable(topfifteen, format = "markdown", caption = "Top 15 Countries for General Procrastination (GP) Mean")
```



|   |Country      |   GPMean|   HDI| Count|HumanDev                    |
|:--|:------------|--------:|-----:|-----:|:---------------------------|
|62 |Poland       | 3.790000| 0.855|     5|Very high human development |
|78 |Turkey       | 3.755556| 0.767|     9|High human development      |
|30 |France       | 3.692308| 0.897|    13|Very high human development |
|70 |Slovenia     | 3.666667| 0.890|     6|Very high human development |
|63 |Portugal     | 3.650000| 0.843|     7|Very high human development |
|75 |Sweden       | 3.643333| 0.913|    15|Very high human development |
|31 |Germany      | 3.608333| 0.926|    36|Very high human development |
|55 |New Zealand  | 3.583333| 0.915|    12|Very high human development |
|33 |Greece       | 3.530000| 0.866|    10|Very high human development |
|40 |Ireland      | 3.518421| 0.923|    19|Very high human development |
|15 |Brazil       | 3.495000| 0.754|    20|High human development      |
|71 |South Africa | 3.470833| 0.666|    12|Medium human development    |
|73 |Spain        | 3.469231| 0.884|    13|Very high human development |
|29 |Finland      | 3.450000| 0.895|    12|Very high human development |
|35 |Hong Kong    | 3.442857| 0.917|     7|Very high human development |

```r
write.csv(topfifteen, "~/6306DoingDataScience/6306CaseStudy2/Data/top15GP.csv", row.names = FALSE)

#5c Generating Visualization of AIP by HDI
topfifteen <- tidydata18_67[,c("Country", "AIPMean", "HDI")]
topfifteen <- setNames(aggregate(topfifteen[ ,2:3], list(Country=topfifteen$Country), mean), 
                       c("Country", "AIPMean", "HDI"))
topfifteen <- merge(topfifteen, ppc, by = "Country", all = TRUE)
topfifteen <- subset(topfifteen, Count >=5)
topfifteen <- topfifteen[order(-topfifteen$AIPMean), ]
topfifteen$HumanDev<- cut(topfifteen$HDI, c(-Inf, 0.549, 0.699, 0.799, Inf))
levels(topfifteen$HumanDev) <- c("Low human development", "Medium human development", 
                                 "High human development", "Very high human development")
topfifteen <- topfifteen[(1:15), ]
theme_update(plot.title = element_text(hjust = 0.5))
ggplot(topfifteen, aes(x = reorder(Country, AIPMean), y = AIPMean, 
                       fill = HumanDev)) + 
  geom_bar(stat = "identity", width = 0.5) + 
  ggtitle("Top Fifteen Countries for Adult Inventory of Procrastination (AIP) Mean") +
  labs(x = "Country", y = "AIP Mean") +
  coord_flip() +
  scale_fill_brewer(palette = "Dark2")
```

![](CaseStudy2_files/figure-html/unnamed-chunk-19-2.png)<!-- -->

```r
#6c Table of topfifteen nations for AIP Mean
kable(topfifteen, format = "markdown", caption = "Top 15 Countries for Adult Inventory Procrastination (AIP) Mean")
```



|   |Country     |  AIPMean|   HDI| Count|HumanDev                    |
|:--|:-----------|--------:|-----:|-----:|:---------------------------|
|62 |Poland      | 3.600000| 0.855|     5|Very high human development |
|78 |Turkey      | 3.555556| 0.767|     9|High human development      |
|30 |France      | 3.538461| 0.897|    13|Very high human development |
|55 |New Zealand | 3.500000| 0.915|    12|Very high human development |
|75 |Sweden      | 3.466667| 0.913|    15|Very high human development |
|35 |Hong Kong   | 3.428571| 0.917|     7|Very high human development |
|33 |Greece      | 3.400000| 0.866|    10|Very high human development |
|65 |Romania     | 3.400000| 0.802|     5|Very high human development |
|61 |Philippines | 3.363636| 0.682|    11|Medium human development    |
|29 |Finland     | 3.333333| 0.895|    12|Very high human development |
|31 |Germany     | 3.305556| 0.926|    36|Very high human development |
|57 |Norway      | 3.285714| 0.949|    14|Very high human development |
|54 |Netherlands | 3.277778| 0.924|    18|Very high human development |
|73 |Spain       | 3.230769| 0.884|    13|Very high human development |
|12 |Belgium     | 3.222222| 0.896|     9|Very high human development |

```r
write.csv(topfifteen, "~/6306DoingDataScience/6306CaseStudy2/Data/top15AIP.csv", row.names = FALSE)
```

When initially reviewing the data for GP and AIP, countries with only one respondent frequently appeared in the topfifteen dataframes.  We decided to set a new threshold, requiring a country to have at least five respondents before being considered in the top-15 list.  This caused a drastic change to the topfifteen dataframes for both AIP and GP, with the overall population dropping from 84 countries to 33.  Countries such as Myanmar, Sri Lanka, Qatar, Panama, Nicaragua, etc.... which only had one respondent were replaced with Greece, Romania, Norway, and Spain.  Countries that were removed from the topfifteen data frames that had more than one respondent were Austria, Malaysia, Uruguay, Ecuador and Colombia, which all had three or less respondents.  Following this threshold reset, European nations dominated both top-15 lists, with European nations owning the top seven spots for GP, and top three spots for AIP.  European nations comprised 23 of the 30 spots on both top-15 lists (~77%)

A high AIP score strongly correlates to high development of a country.  There are no countries of low human development in the top 15 and only 1/5 of the respondents are of medium development.  Fully 1/3 of the top 15 are very highly developed.  Interestingly enough 1/3 of the top 15 in AIP are island nations.

## Age versus Annual Income

```r
#5d Answering relationship of Age vs. Income
#Generate Scatterplot
ggplot(na.omit(tidydata18_67), aes(Age, AnnIncome, color = Gender)) + 
  geom_point(shape = 16, size = 5, show.legend = FALSE, alpha = 1) + 
  geom_smooth(method = 'lm', color = "red") + 
  ggtitle("Age vs. Annual Income by Gender") + labs(x = "Age", y = "AnnIncome")
```

![](CaseStudy2_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

```r
cor(tidydata18_67$AnnIncome, tidydata18_67$Age, method = "pearson", use="na.or.complete")
```

```
## [1] 0.3717334
```

```r
#Generate Linear Model & Display Statistics
AgeIncome<-lm(AnnIncome~Age, data=na.omit(tidydata))

summary(AgeIncome)
```

```
## 
## Call:
## lm(formula = AnnIncome ~ Age, data = na.omit(tidydata))
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -110877  -29102  -14393   10614  223266 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  3198.63    2531.49   1.264    0.206    
## Age          1470.98      62.91  23.382   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 51370 on 3598 degrees of freedom
## Multiple R-squared:  0.1319,	Adjusted R-squared:  0.1317 
## F-statistic: 546.7 on 1 and 3598 DF,  p-value: < 2.2e-16
```

The scatterplot in general shows a regular dispersion of points and a fit line with a positive slope.  This indicates there is some correlation between the two.  However, when running the linear regression modeling we can see that while age and annual income are indeed correlated with a low p-value, the adjusted R-squared value shows that Age explains only 13% of the variation in Annual Income.  

## HDI vs. SWLS comparison

```r
#5e Determine if there is a relationship between Human Development and Satisfaction With Life
ggplot(tidydata18_67, aes(HDI, SWLSMean, color = HDICategory)) + 
    geom_point(shape = 16, size = 5, show.legend = FALSE, alpha = 1) + 
    geom_smooth(method = 'lm', color = "red") + 
    ggtitle("HDI vs. Satisfaction With Life Scale (SWLS) Mean") + labs(x = "HDI", y = "SWLSMean")
```

```
## Warning: Removed 160 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 160 rows containing missing values (geom_point).
```

![](CaseStudy2_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

```r
cor(tidydata18_67$HDI, tidydata18_67$SWLSMean, method = "pearson", use = "na.or.complete")
```

```
## [1] 0.04184384
```

```r
SWLSHDICat <- tidydata18_67[ ,c("HDICategory", "SWLSMean")]
SWLSHDICat <- setNames(aggregate(SWLSHDICat[ ,2], list(HDICategory=SWLSHDICat$HDICategory), mean), 
                       c("HDICategory", "SWLSMean"))
ggplot(SWLSHDICat, aes(x = reorder(HDICategory, SWLSMean), y = SWLSMean, 
                       fill = HDICategory)) + 
    geom_bar(stat = "identity", width = 0.5) + 
    ggtitle("Human Development Category vs. Satisfaction With Life Scale (SWLS) Mean") +
    labs(x = "HDI Category", y = "SWLSMean") +
    coord_flip() +
    scale_fill_brewer(palette = "Dark2")
```

![](CaseStudy2_files/figure-html/unnamed-chunk-21-2.png)<!-- -->

The scatterplot data showed very little correlation when comparing HDI with the SWLS mean data.  The correlation coefficient was a miniscule positive 0.04.  The barchart demonstrates that when grouped by levels of Human Development, on average those living in more highly developed nations do have a slightly higher satisfaction with life.

## Spatial Analysis

```r
#Importing map.world data into environment to circumvent knitr's issues about environmental datasets
localmap.world<-read.csv("~/6306DoingDataScience/6306CaseStudy2/Data/map.world.csv", header=TRUE)

#Create new dataframe that contains Country and Means for each Procrastination Index used in Maps
newmap<-as.data.frame(unique(localmap.world$region))
colnames(newmap)<-c("Country")
HDI_Means<-aggregate(tidydata18_67[, c("GPMean", "DPMean", "AIPMean", "SWLSMean")], list(tidydata18_67$Country), mean, na.rm=TRUE)    #Creates a new object which stores the mean GP, DP, AIP, and SWLS by country
colnames(HDI_Means)<-c("Country","GPMean", "DPMean", "AIPMean", "SWLSMean")

mapdata<-merge(newmap, HDI_Means, by="Country", all.x=TRUE, all.y=TRUE)
mapdata$Country<-sort(mapdata$Country)

#Cleaning up Names to match necessary names in localmap.world (United States -> US, United Kingdom->UK, Antigua & Barbuda->Antigua) and removing duplicate rows
mapdata$Country[255]<-mapdata$Country[241]
mapdata$Country[254]<-mapdata$Country[237]
mapdata$Country[257]<-mapdata$Country[9]
mapdata<-mapdata[-c(9, 237, 241),]

#Generating Maps for AIPMean, GPMean, SWLSMean, and DPMean
aipmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=AIPMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean Adult Inventory of Procrastination Scores (AIP) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "darkred", space = "Lab", na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="AIPMean",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

gpmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=GPMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean General Procrastination (GP) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "navyblue", space = "Lab",na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="GPMean",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

dpmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=DPMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean Decisional Procrastination (DP) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "darkgreen", space = "Lab",na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="DPMean",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)

swlsmap<- ggplot(mapdata, aes(map_id=Country))+    #sets the data and the primary key to link map and data
  geom_map(aes(fill=SWLSMean), map=localmap.world)+         #sets the fill value that will determine color and the geographic map data
  expand_limits(x=localmap.world$long, y=localmap.world$lat)+ #Sets the latitude and longitudinal extents
  #coord_map()+                        #Sets the base geographic projection (mercator in this case)
  coord_equal()+
  scale_x_continuous(breaks=NULL)+
  scale_y_continuous(breaks=NULL)+
  labs(x = "", y = "") +
  ggtitle("Mean Satisfaction of Life (SWLS) by Country") + # Sets the title of the map
  scale_fill_gradient(low = "antiquewhite", high = "darkorange4", space = "Lab",na.value = "gray80", guide=guide_colourbar(title.position="top", barwidth=10, title="SWLS",  title.hjust=0.5))+     #contols legend elements such as color gradiant, colors for NA values, and the size of the legend bar
  theme(plot.title = element_text(lineheight=.8, face="bold"),legend.position=c(.15, .25),legend.direction="horizontal",panel.background=element_blank(), panel.border=element_rect(colour="Grey50", fill=NA, size=2))+   #Theme elements such as the border around the map plot, the position of map components like the legend
  borders(database="world", regions=".", fill=NA, colour="grey25", xlim=NULL, ylim=NULL)
```

By piecing together the survey data with other available geospatial data we can build maps of the globe to better depict areas of high procrastination.  One must be cautious in interpreting the values here though.  As presented in the data section, many countries contain only a single respondent and thus not a sample size that can be considered representative of the population.  Nonetheless, these maps of global distribution of means can show potential trends and, using further analysis, depict a clearer picture where procrastination may cause resource issues and incur greater operating costs.


```r
aipmap 
```

![](CaseStudy2_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

This map of mean Adult Inventory of Procrastination scores by country shows the global distribution of time usage variables.  It measures the chronic tendency to put off tasks in various situations.  In general, a higher score means greater tendency towards procrastination as shown in the codebook (which lists all questions given in the survey).  We see that the middle east and northern South America as well as Burma and Ethiopa score high on AIP.  Europe also appears higher than the global average while southern South America and the few other participating African countries show lower mean AIP scores.


```r
gpmap
```

![](CaseStudy2_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

GP, or the General Procrastination scale tries to measure common characteristics of procrastinators and a high score here indicating behavior tendencies.  Russia and the Pacific states of South America show lower mean scores of GP.  In general, it appears that there is a relationship between high development and GP.  The greater the development the higher the GP.


```r
dpmap
```

![](CaseStudy2_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

The Decisional Procrastination Scale measures how students approach decision making processes.  It attempts to provide a multivariate analysis to avoid confounding factors and a high score usually indicates high levels of avoidance.  With few exceptions, developed countries appear to show lower levels of DP.  Russia, Turkey, and Colombia are the outliers.


```r
swlsmap
```

![](CaseStudy2_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

Satisfaction of life survey responses ask questions to determine overall global life satisfaction.  The Pacific countries of South America appear the most content along with Algeria, Pakistan and Iran.  Many European countries appear lower in the scale along with Russia and China.

![HDI Development](https://i.pinimg.com/736x/03/ee/82/03ee82a37b06aa6760259d79ac4d8997--human-development-report-economic-development.jpg)
HDI, or Human Development Index is a multivariate statistic created by the United Nations to measure the development levels of countries.  It takes into account overall health, education, accessability of housing and food, and other factors.  The number falls between 0 and 1 with the higher numbers indicating most developed.  The map clearly shows that most countries considered "1st World" nations are highly developed while traditional "3rd world countries" fall on the lower end of the spectrum.  Of particular note are the moderately low HDI scores of southern Asia.  India, Pakistan, and others who are not seen as 3rd world countries have significantly lower HDI scores than even their nearby neighbors such as China.  War-torn nations such as Afghanistan and Somalia contain no HDI indicies.  Western Sahara also contains no data, probably due to the contentious standoff between the government of Morocco and the Sahrawi Arab Democratic Republic.

(Image source is Pinterest.  Author is [Happenstance](https://commons.wikimedia.org/wiki/User_talk:Happenstance))

# Summary & Conclusions
From the beginning, we set out to answer three primary questions when analyzing various procrastination indices vs. human development data:

* What is the mean AIP, GP, SWLS, and DP for each country?
* What is the HDI for each country?
* Are there any relationships between the procrastination indices and HDI?

Norway tops the list of highly developed nations with a HDI of 0.949, and Central Africa Republic rounds out the list with a HDI of 0.352.  When analyzing the top-15 countries for both AIP and GP, Poland tops both lists of countries with a GP Mean of 3.79 and AIP mean of 3.6.  The range for GP of the top-15 countries is from 3.79 (Poland) and 3.44(Hong Kong).  The range for AIP for the top-15 countries is from 3.6 (Poland) to 3.222 (Belgium).  Both GP and AIP positively correlate with high human development with 12 of the top-15 nations for GP and 13 of the top-15 for AIP being categorized as having very high human development.  77% of the population of both top-15 lists come from European nations, which on the surface appeared to be a hot spot for high procrastination index scores, however, the data is not conclusive on that point due to the low response numbers for other nations.  We also looked at how satisfaction with life (a possible contributing factor to procrastination) compared with the Human Development Index.  While the numerical SWLS and HDI data did not correlate, when binning SWLS mean data among the four levels of human development, the countries with very high human development score a point higher than countries with low human development for SWLS mean (3.04 compared to 2.07)

## Additional Research
This proposal hits upon the highlights of the relationships between procrastination and human development and indicates a few reasons why this might be important to businesses, investors, and government aid institutions.  Further research could be provided, at cost, to generate better data with which to provide more robust samples for every region of the world, including the regions underserved by the data presented here.  Additionally, many other avenues of research can be followed depending upon the exact desires of clients such as:

* What demographic relationships exist with procrastination?
* For countries with high rates of procrastination, are the incomes commensurate with the loss of time?
* Are there greater regional patterns for procrastination?  Why?
* Do cultural and/or societal differences play a role in procrastination?
* What aspects of HDI work best to lower procrastination rates?
* Cost benefit analysis for investing in high procrastination areas and developing resources to assist workers to avoid procrastination.

## What's Next?
Contact one of our expert program managers to set up a meeting so that we may better understand the requirements and develop a personalized proposal for your organization.  Depending on the scale and scope of research additional services may be necessary such as data collection for underserved populations in order to affect a sample size significant enough to provide meaningful analysis.  Depending on the scale of the area of interest detailed graphics can be generated after additional research to show procrastination "hot-spots".
