library(knitr)
library(dplyr)
library(plyr)
library(ggplot2)
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
    kable(report, digits = 3, caption = paste0("Summary Statisitics for", property, sep = " "))
   
}
funcsummary(tidydata18_67, "Age")
funcsummary(tidydata18_67, "AnnIncome")
funcsummary(tidydata18_67, "HDI")
funcsummary(tidydata18_67, "DPMean")
funcsummary(tidydata18_67, "AIPMean")
funcsummary(tidydata18_67, "GPMean")
funcsummary(tidydata18_67, "SWLSMean")

# 4b (cont.) Created a histogram for both Annual Income and General Procrastination Scale Mean
hist(tidydata18_67$AnnIncome, col = "blue3", main = "Histogram of Annual Income",
     xlab = "Annual Income in USD")
hist(tidydata18_67$GPMean, col = "blue3", main = "Histogram of the General Procrastination Mean",
     xlab = "Mean of General Procastation Scale")
#AnnIncome is right skewed while GPMean is left skewed

# 4c Created dataframes to provide the frequency of Gender, WorkStatus, and Occupation
tidydata18_67$WorkStatus <- as.factor(tidydata18_67$WorkStatus)
tidydata18_67$Gender <- as.factor(tidydata18_67$Gender)
#tidydata18_67$Country <- as.factor(tidydata18_67$Country)
#str(tidydata18_67$Country)
ws <- as.data.frame(count(tidydata18_67, 'WorkStatus'))
kable(ws, caption = "Frequency of Work Status Responses")
gen <- as.data.frame(count(tidydata18_67, 'Gender'))
kable(gen, caption = "Frequency of Gender Responses")

occ <- as.data.frame(count(tidydata18_67, 'Occupation'))
# Labeled all occupations with a count of 1 as "Other"
occ$Occupation[which(occ$freq == 1)] <- "Other"
occ <- as.data.frame(count(occ, 'Occupation'))
kable(occ, caption = "Frequency of Occupation Responses")

# 4d Determined the counts of participants per country
ppc <- setNames(tally(group_by(tidydata18_67, Country), sort = TRUE), c("Country", "Count"))
kable(ppc, caption = "Frequency of Response per Country")

# 4e Determine where self assessment of procrastination match others assessment
tidydata18_67$ProsMatch <- mapply(grepl, pattern = tidydata18_67$SelfP, x = tidydata18_67$OthersP)
#tidydata18_67[, ProsMatch := grepl("SelfP", "OthersP"), by = x]
match <- setNames(tally(group_by(tidydata18_67, ProsMatch)), c("Logical", "Count"))
kable(match, caption = "Number of Self Perception Matches")

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

#5e Determine if there is a relationship between Human Development and Satisfaction With Life
ggplot(tidydata18_67, aes(HDI, SWLSMean, color = HDICategory)) + 
    geom_point(shape = 16, size = 5, show.legend = FALSE, alpha = 1) + 
    geom_smooth(method = 'lm', color = "red") + 
    ggtitle("HDI vs. Satisfaction With Life Scale (SWLS) Mean") + labs(x = "HDI", y = "SWLSMean")
cor(tidydata18_67$HDI, tidydata18_67$SWLSMean, method = "pearson", use = "na.or.complete")

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

#6c Table of topfifteen nations for General Procrastiantion Mean
kable(topfifteen, caption = "Top 15 Countries for General Procrastination (GP) Mean")