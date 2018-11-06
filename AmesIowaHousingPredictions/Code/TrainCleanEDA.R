library(readr)
library(tibble)
library(dplyr)
library(ggplot2)
library(GGally)
library(purrr)
library(scales)

#Read in the training data set and view
setwd("~/SMUProjects/AmesIowaHousingPredictions/")
train <- as_tibble(read_csv("Data/train.csv"))
glimpse(train)

colnames(train)[colnames(train)=="3SsnPorch"] <- "SsnPorch"

#Determine the NAs and missing data in the dataset and list in descending order
na.feature = which(colSums(is.na(train)) > 0)
sort(colSums(sapply(train[na.feature], is.na)), decreasing = TRUE)

# Due to significant number of NAs and previous analysis in SAS, NAs converted to "No Alley, Fence, etc....."
index <- which(is.na(train$Alley))
train[index, 'Alley'] <- 'No Alley'

index <- which(is.na(train$Fence))
train[index, 'Fence'] <- 'No Fence'

index <- which(is.na(train$MiscFeature))
train[index, 'MiscFeature'] <- 'No Feature'

index <- which(is.na(train$PoolQC))
train[index, 'PoolQC'] <- 'No Pool'

index <- which(is.na(train$FireplaceQu))
train[index, 'FireplaceQu'] <- 'No Fireplace'

# Garage Variables produce 81 NAs
# Verify no NA GarageTypes have an Area or Car number > 0
train[(is.na(train$GarageType) & train$GarageArea >0) | (is.na(train$GarageType) & train$GarageCars > 0), ]
# Verifying no outliers in GarageYrBlt 
summary(train$GarageYrBlt)
train %>%
    filter(is.na(GarageCond) & !is.na(GarageType))

garagecatvariables <- c('GarageType', 'GarageFinish', 'GarageQual', 'GarageCond')
for (i in seq_along(garagecatvariables)){
    index <- which(is.na(train[garagecatvariables[i]]))
    train[index, garagecatvariables[i]] <- 'No Garage'
    #summary(as.factor(train$garagevariables[i])) receiving error with this line of code will investigate
}

summary(as.factor(train$GarageQual))
summary(as.factor(train$GarageCond))
summary(as.factor(train$GarageType))
summary(as.factor(train$GarageFinish))

garagecontvariables <- c('GarageYrBlt', 'GarageArea', 'GarageCars')

for (i in seq_along(garagecontvariables)){
    index <- which(is.na(train[garagecontvariables[i]]))
    train[index, garagecontvariables[i]] <- 0
    #summary(as.factor(train$garagevariables[i])) receiving error with this line of code will investigate
}

summary(train$GarageYrBlt)
summary(train$GarageArea)
summary(train$GarageCars)

#Basement Variable NAs
bsmtvariables <- c('BsmtQual', 'BsmtCond', 'BsmtExposure', 'BsmtFinType1', 'BsmtFinType2')
train[(is.na(train$BsmtFinType1) & train$BsmtFinSF1 >0) | (is.na(train$BsmtFinType2) & train$BsmtFinSF2 > 0), ]
train[(is.na(train$BsmtExposure) & train$BsmtFinSF1 >0) | (is.na(train$BsmtCond) & train$BsmtFinSF1 > 0), ]
for (i in seq_along(bsmtvariables)){
    index <- which(is.na(train[bsmtvariables[i]]))
    train[index, bsmtvariables[i]] <- 'No Basement'
    #summary(as.factor(train$garagevariables[i])) receiving error with this line of code will investigate
}

summary(as.factor(train$BsmtQual))
summary(as.factor(train$BsmtCond))
summary(as.factor(train$BsmtExposure))
summary(as.factor(train$BsmtFinType1))
summary(as.factor(train$BsmtFinType2))

#Impute LotFrontage by Median per each neighborhood
index <- which(is.na(train$LotFrontage))
head(train[index,])
table(train[index, 'Neighborhood'])

frontage_by_neighborhood <- train %>%
    dplyr::select(Neighborhood, LotFrontage) %>%
    group_by(Neighborhood) %>%
    summarise(median_frontage = median(LotFrontage, na.rm = TRUE))

any(is.na(frontage_by_neighborhood$median_frontage)) 
index <- which(is.na(train$LotFrontage))

for (i in index) {
    med_frontage = frontage_by_neighborhood[frontage_by_neighborhood == train$Neighborhood[i], 'median_frontage']
    # then replace the missing value with the median
    train[i, 'LotFrontage'] = med_frontage[[1]]
}

index <- which(is.na(train$LotFrontage))

#MasVnrArea and MasVnrType cleaning
index <- which(train$MasVnrType == 'None' & train$MasVnrArea != 0)
train[index,'MasVnrArea']
train[index, 'MasVnrArea'] <- 0
index <- which(train$MasVnrType != 'None' & train$MasVnrArea == 0)
train[index,'MasVnrType']
train[index, 'MasVnrType'] <- 'None'
index <- which(is.na(train$MasVnrType) & is.na(train$MasVnrArea))
train[index, 'MasVnrType'] <- 'None'
train[index, 'MasVnrArea'] <- 0

#Electrical types, median sale price for NA home is very near SBrkr median sale prices.
index <- which(is.na(train$Electrical))
train[index,'Electrical'] <- 'SBrkr'

################################################################
#       EDA and Cleaning For Categorical Variables             #
################################################################
catvariables <- c('MSZoning', 'Street', 'Alley', 'LotShape', 'LandContour', 'Utilities', 'LotConfig', 'LandSlope', 'Condition1', 'Condition2', 
                  'BldgType', 'HouseStyle', 'RoofStyle', 'RoofMatl', 'Exterior1st', 'Exterior2nd', 'MasVnrType', 'ExterQual', 'ExterCond', 
                  'Foundation', 'BsmtQual', 'BsmtCond', 'BsmtExposure', 'BsmtFinType1', 'BsmtFinType2', 'Heating', 'HeatingQC', 'CentralAir', 
                  'Electrical', 'KitchenQual', 'Functional', 'FireplaceQu', 'GarageType', 'GarageFinish', 'GarageQual', 'GarageCond', 
                  'PavedDrive', 'Fence', 'PoolQC', 'MiscFeature', 'SaleType', 'SaleCondition')

#Variables combined during cleaning 
modcats <- c('SaleType', 'MSZoning', 'Functional', 'Condition1', 'Condition2', 'LotShape', 'Heating')



# Function to create bar chart for Categorical variables
plotCategorical = function(cols, dataframe) {
    for (col in cols) {
        # Remove NA's & sort categories by tally
        order.cols = names(sort(table(dataframe[,col]), decreasing = TRUE))
        # qplot is ggplot's equivalent of base R's high-level plotting function `plot`
        num.plot = ggplot(dataframe, aes(dataframe[,col])) +
            # change bar color 
            geom_bar(fill = 'cornflowerblue') +
            # add the value labels to each bar
            geom_text(aes(label = ..count..), stat='count', vjust=-0.5) +
            # minimal theme
            theme_minimal() +
            # set scales for each plot to go from 0 to max of categorical feature
            scale_y_continuous(limits = c(0,max(table(dataframe[,col]))*1.1)) +
            scale_x_discrete(limits = order.cols) +
            xlab(col) +
            # rotate x-axis label text 30 degrees and set font size to 12
            theme(axis.text.x = element_text(angle = 30, size=12))
        # Show plot and suppress warning messages from plot function
        suppressWarnings(print(num.plot))
    }
}

ggplot(train, aes(x = factor(SaleType), y = SalePrice)) + 
    geom_boxplot(aes(fill = factor(SaleType))) + 
    theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none") 

#Combine all Low Downpayment and Low Intereste contracts into one category
index <- which(train$SaleType == 'ConLD' | train$SaleType == 'ConLI' | train$SaleType == 'ConLw')
train[index, 'SaleType'] <- 'ConLdLi'

ggplot(train, aes(x = factor(Heating), y = SalePrice)) + 
    geom_boxplot(aes(fill = factor(Heating))) + 
    theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none") 

#Combine all Low Downpayment and Low Intereste contracts into one category
index <- which(train$Heating == 'Floor' | train$Heating == 'OthW' | train$Heating == 'Wall' | train$Heating == 'Grav')
train[index, 'Heating'] <- 'Furnace'

ggplot(train, aes(x = factor(Functional), y = SalePrice)) + 
    geom_boxplot(aes(fill = factor(Functional))) + 
    theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none") 

index <- which(train$Functional == 'Min1' | train$Functional == 'Min2')
train[index, 'Functional'] <- 'Minor'

#Review LotShape Variable 
ggplot(train, aes(x = factor(Condition1), y = SalePrice)) + 
    geom_boxplot(aes(fill = factor(Condition1))) + 
    theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none") 

#Review proximity to various conditions
index <- which(train$Condition1 == 'PosA' | train$Condition1 == 'PosN')
train[index, 'Condition1'] <- 'NearPos'

index <- which(train$Condition2 == 'PosA' | train$Condition2 == 'PosN')
train[index, 'Condition2'] <- 'NearPos'

index <- which(train$Condition1 == 'RRAe' | train$Condition1 == 'RRAn' | train$Condition1 == 'RRNe' | train$Condition1 == 'RRNn')
train[index, 'Condition1'] <- 'NearTrain'

index <- which(train$Condition2 == 'RRAe' | train$Condition2 == 'RRAn' | train$Condition2 == 'RRNe' | train$Condition2 == 'RRNn')
train[index, 'Condition2'] <- 'NearTrain'

#Review LotShape Variable 
ggplot(train, aes(x = factor(LotShape), y = SalePrice)) + 
    geom_boxplot(aes(fill = factor(LotShape))) + 
    theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none") 

#Combine IR2 and IR3
index <- which(train$LotShape == 'IR2' | train$LotShape == 'IR3')
train[index, 'LotShape'] <- 'IR2 + 3'

# MSZoning Shorten to C (all) to C
index <- which(train$MSZoning == "C (all)")
train[index, 'MSZoning'] <- "C"

############################################################
#               Cleaning for Ordinal Variables             #
############################################################

#Determine number and type of homes with 2 kitchens
index <- which(train$KitchenAbvGr == 2)
train[index, ] %>%
    summarize(median_sale_price = median(SalePrice), n = n()) %>% print()

twokitchens <- train[index, ]
twokitchens %>%
    group_by(BldgType) %>%
    summarize(median_sale_price = median(SalePrice), n = n()) %>% print()

index <- which(train$BldgType == '1Fam' & train$KitchenAbvGr == '2')
singlefam2kitchen <- train[index, ]

#Changed all Single-Family home types to have 1 Kitchen Above Ground
index <- which(train$BldgType == '1Fam')
train[index, 'KitchenAbvGr'] <- 1
train[index, 'TotRmsAbvGrd'] <- train[index, 'TotRmsAbvGrd'] - 1

#Loop to print all bar charts for the categorical variables along with a summary of median price
for (i in seq_along(modcats)){
    plotCategorical(modcats[i], train)
    train %>%
        group_by_at(vars(modcats[i])) %>%
        summarize(median_sale_price = median(SalePrice), n = n()) %>% print()
}


write_csv(train, 'Data/train_cleaned.csv')





