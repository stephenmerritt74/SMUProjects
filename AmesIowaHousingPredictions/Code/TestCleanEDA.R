library(readr)
library(tibble)
library(dplyr)
library(ggplot2)
library(GGally)
library(purrr)
library(scales)

#Read in the training data set and view
setwd("~/SMUProjects/AmesIowaHousingPredictions/")
test <- as_tibble(read_csv("Data/test.csv"))
glimpse(test)

colnames(test)[colnames(test)=="3SsnPorch"] <- "SsnPorch"

#Determine the NAs and missing data in the dataset
na.feature = which(colSums(is.na(test)) > 0)
sort(colSums(sapply(test[na.feature], is.na)), decreasing = TRUE)

################################################################
#                        NA Removal                            #
################################################################

# Due to significant number of NAs and previous analysis in SAS, NAs converted to "No Alley, Fence, etc....."
index <- which(is.na(test$Alley))
test[index, 'Alley'] <- 'No Alley'

index <- which(is.na(test$Fence))
test[index, 'Fence'] <- 'No Fence'

index <- which(is.na(test$MiscFeature))
test[index, 'MiscFeature'] <- 'No Feature'

index <- which(is.na(test$PoolQC))
test[index, 'PoolQC'] <- 'No Pool'

index <- which(is.na(test$FireplaceQu))
test[index, 'FireplaceQu'] <- 'No Fireplace'

# Garage Variables produce 81 NAs
# Verify no NA GarageTypes have an Area or Car number > 0
GarTypeNA <- test[!is.na(test$GarageType) & is.na(test$GarageQual), ]

index <- which(!is.na(test$GarageType) & is.na(test$GarageCars))
test[index, 'GarageType'] <- 'No Garage'

index <- which(!is.na(test$GarageType) & !is.na(test$GarageCars) & is.na(test$GarageQual))
test[index, 'GarageQual'] <- 'TA'
test[index, 'GarageCond'] <- 'TA'
test[index, 'GarageFinish'] <- 'Unf'
test[index, 'GarageYrBlt'] <- test[index, 'YearBuilt']

# Verifying no outliers in GarageYrBlt  
summary(test$GarageYrBlt)
index <- which(test$GarageYrBlt == 2207)
test[index, 'GarageYrBlt'] <- test[index, 'YearBuilt']


garagecatvariables <- c('GarageType', 'GarageFinish', 'GarageQual', 'GarageCond')
for (i in seq_along(garagecatvariables)){
    index <- which(is.na(test[garagecatvariables[i]]))
    test[index, garagecatvariables[i]] <- 'No Garage'
    #summary(as.factor(train$garagevariables[i])) receiving error with this line of code will investigate
}

summary(as.factor(test$GarageQual))
summary(as.factor(test$GarageCond))
summary(as.factor(test$GarageType))
summary(as.factor(test$GarageFinish))

garagecontvariables <- c('GarageYrBlt', 'GarageArea', 'GarageCars')

for (i in seq_along(garagecontvariables)){
    index <- which(is.na(test[garagecontvariables[i]]))
    test[index, garagecontvariables[i]] <- 0
    #summary(as.factor(train$garagevariables[i])) receiving error with this line of code will investigate
}

summary(test$GarageYrBlt)
summary(test$GarageArea)
summary(test$GarageCars)

#Determine the NAs and missing data in the dataset
na.feature = which(colSums(is.na(test)) > 0)
sort(colSums(sapply(test[na.feature], is.na)), decreasing = TRUE)

#Basement Variable NAs
bsmtvariables <- c('BsmtQual', 'BsmtCond', 'BsmtExposure', 'BsmtFinType1', 'BsmtFinType2')
bsmtCondNA <- test[(!is.na(test$BsmtFinType1) & is.na(test$BsmtCond)), ]
bsmtExposureNA <- test[(!is.na(test$BsmtCond) & is.na(test$BsmtExposure)), ]
bsmtQualNA <- test[(!is.na(test$BsmtCond) & is.na(test$BsmtQual)), ]

index <- which(!is.na(test$BsmtCond) & is.na(test$BsmtExposure))
test[index, 'BsmtExposure'] <- 'No'

index <- which(!is.na(test$BsmtQual) & is.na(test$BsmtCond))
test[index, 'BsmtCond'] <- 'TA'

index <- which(!is.na(test$BsmtCond) & is.na(test$BsmtQual))
test[index, 'BsmtQual'] <- 'TA'

for (i in seq_along(bsmtvariables)){
    index <- which(is.na(test[bsmtvariables[i]]))
    test[index, bsmtvariables[i]] <- 'No Basement'
    #summary(as.factor(train$garagevariables[i])) receiving error with this line of code will investigate
}

summary(as.factor(test$BsmtQual))
summary(as.factor(test$BsmtCond))
summary(as.factor(test$BsmtExposure))
summary(as.factor(test$BsmtFinType1))
summary(as.factor(test$BsmtFinType2))

#Impute LotFrontage by Median per each neighborhood
index <- which(is.na(test$LotFrontage))
head(test[index,])
table(test[index, 'Neighborhood'])

frontage_by_neighborhood <- test %>%
    dplyr::select(Neighborhood, LotFrontage) %>%
    group_by(Neighborhood) %>%
    summarise(median_frontage = median(LotFrontage, na.rm = TRUE))

any(is.na(frontage_by_neighborhood$median_frontage)) 
index <- which(is.na(test$LotFrontage))

for (i in index) {
    med_frontage = frontage_by_neighborhood[frontage_by_neighborhood == test$Neighborhood[i], 'median_frontage']
    # then replace the missing value with the median
    test[i, 'LotFrontage'] = med_frontage[[1]]
}

#MasVnrArea and MasVnrType cleaning
masvnrNA <- test[(!is.na(test$MasVnrArea) & is.na(test$MasVnrType)), ]
index <- which(is.na(test$MasVnrType) & test$MasVnrArea != 0)
test[index, 'MasVnrType'] <- 'BrkFace'

index <- which(is.na(test$MasVnrType))
test[index, 'MasVnrType'] <- 'None'
test[index, 'MasVnrArea'] <- 0

#Electrical types, median sale price for NA home is very near SBrkr median sale prices.
index <- which(is.na(test$Electrical))
test[index,'Electrical'] <- 'SBrkr'

#MSZone cleaning
MSZoneNA <- test[(is.na(test$MSZoning)), ]
index <- which(is.na(test$MSZoning))
test[index, 'MSZoning'] <- 'RL'
test[index, 'Utilities'] <- 'AllPub'

#BsmtFullBath cleaning
BsmtFullNA <- test[(is.na(test$BsmtFullBath)), ]
index <- which(is.na(test$BsmtFullBath))
test[index, 'BsmtFullBath'] <- 0
test[index, 'BsmtHalfBath'] <- 0
test[index, 'BsmtFinSF1'] <- 0
test[index, 'BsmtFinSF2'] <- 0
test[index, 'BsmtUnfSF'] <- 0
test[index, 'TotalBsmtSF'] <- 0

FunctionalNA <- test[(is.na(test$Functional)), ]
index <- which(is.na(test$Functional))
test[index, 'Functional'] <- 'Typ'

UtilitiesNA <- test[(is.na(test$Utilities)), ]
index <- which(is.na(test$Utilities))
test[index, 'Utilities'] <- 'AllPub'

ExteriorNA <- test[(is.na(test$Exterior1st)), ]
index <- which(is.na(test$Exterior1st))
test[index, 'Exterior1st'] <- 'VinylSd'
test[index, 'Exterior2nd'] <- 'VinylSd'

SaleTypeNA <- test[(is.na(test$SaleType)), ]
index <- which(is.na(test$SaleType))
test[index, 'SaleType'] <- 'WD'

KitchenQualNA <- test[(is.na(test$KitchenQual)), ]
index <- which(is.na(test$KitchenQual))
test[index, 'KitchenQual'] <- 'TA'


################################################################
#               Cleaning For Categorical Variables             #
################################################################
#Combine all Low Downpayment and Low Intereste contracts into one category
index <- which(test$SaleType == 'ConLD' | test$SaleType == 'ConLI' | test$SaleType == 'ConLw')
test[index, 'SaleType'] <- 'ConLdLi'

#Combine all Low Downpayment and Low Intereste contracts into one category
index <- which(test$Heating == 'Floor' | test$Heating == 'OthW' | test$Heating == 'Wall' | test$Heating == 'Grav')
test[index, 'Heating'] <- 'Furnace'

index <- which(test$Functional == 'Min1' | test$Functional == 'Min2')
test[index, 'Functional'] <- 'Minor'

#Review proximity to various conditions
index <- which(test$Condition1 == 'PosA' | test$Condition1 == 'PosN')
test[index, 'Condition1'] <- 'NearPos'

index <- which(test$Condition2 == 'PosA' | test$Condition2 == 'PosN')
test[index, 'Condition2'] <- 'NearPos'

index <- which(test$Condition1 == 'RRAe' | test$Condition1 == 'RRAn' | test$Condition1 == 'RRNe' | test$Condition1 == 'RRNn')
test[index, 'Condition1'] <- 'NearTrain'

index <- which(test$Condition2 == 'RRAe' | test$Condition2 == 'RRAn' | test$Condition2 == 'RRNe' | test$Condition2 == 'RRNn')
test[index, 'Condition2'] <- 'NearTrain'

#Combine IR2 and IR3
index <- which(test$LotShape == 'IR2' | test$LotShape == 'IR3')
test[index, 'LotShape'] <- 'IR2 + 3'

# MSZoning Shorten to C (all) to C
index <- which(test$MSZoning == "C (all)")
test[index, 'MSZoning'] <- "C"


############################################################
#              Cleaning for Ordinal Variables             #
############################################################

#Determine number and type of homes with 2 kitchens
index <- which(test$KitchenAbvGr == 2)
twokitchens <- test[index, ]
twokitchens %>%
    group_by(BldgType) %>% print()
    

index <- which(test$BldgType == '1Fam' & test$KitchenAbvGr == '2')
singlefam2kitchen <- test[index, ]

#Changed all Single-Family home types to have 1 Kitchen Above Ground
index <- which(test$BldgType == '1Fam')
test[index, 'KitchenAbvGr'] <- 1
test[index, 'TotRmsAbvGrd'] <- test[index, 'TotRmsAbvGrd'] - 1

write_csv(test, 'Data/test_cleaned.csv')