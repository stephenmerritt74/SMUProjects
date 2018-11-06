library(readr)
library(tibble)
library(dplyr)
library(ggplot2)
library(GGally)
library(purrr)
library(scales)
library(investr)
library(broom)
library(infer)
library(mlr)
library(fastDummies)
library(car)
library(ggcorrplot)
library(MASS)
library(caret)
library(leaps)
library(cowplot)
setwd("~/SMUProjects/AmesIowaHousingPredictions/")
train <- as_tibble(read_csv("Data/train_cleaned.csv"))
glimpse(train)
test <- as_tibble(read_csv("Data/test_cleaned.csv"))
glimpse(test)
#Remove scientific notation
options(scipen = 999)

catvariables <- c('MSSubClass', 'MSZoning', 'Street', 'Alley', 'LotShape', 'LandContour', 'Utilities', 'LotConfig', 'LandSlope',
                  'Neighborhood', 'Condition1', 'Condition2', 'BldgType', 'HouseStyle', 'RoofStyle', 'RoofMatl', 'Exterior1st',
                  'Exterior2nd', 'MasVnrType', 'ExterQual', 'ExterCond', 'Foundation', 'BsmtQual', 'BsmtCond', 'BsmtExposure',
                  'BsmtFinType1', 'BsmtFinType2', 'Heating', 'HeatingQC', 'CentralAir', 'Electrical', 'KitchenQual', 'Functional',
                  'FireplaceQu', 'GarageType', 'GarageFinish', 'GarageQual', 'GarageCond',
                  'PavedDrive', 'Fence', 'PoolQC', 'MiscFeature', 'SaleType', 'SaleCondition')

ordvariables <- c('OverallQual', 'OverallCond', 'BsmtFullBath', 'BsmtHalfBath', 'FullBath', 'HalfBath', 'BedroomAbvGr', 'KitchenAbvGr',
                  'TotRmsAbvGrd', 'Fireplaces', 'GarageCars', 'MoSold', 'YrSold', 'GarageYrBlt', 'YearBuilt', 'YearRemodAdd')

contvariables <- c('LotFrontage', 'LotArea', 'MasVnrArea', 'BsmtFinSF1', 'BsmtFinSF2', 'BsmtUnfSF', 'TotalBsmtSF', "FirstFlrSF",
                   "SecondFlrSF", 'LowQualFinSF', 'GrLivArea', 'GarageArea', 'WoodDeckSF', 'OpenPorchSF', 'EnclosedPorch', 'ScreenPorch',
                   "SsnPorch", 'PoolArea', 'MiscVal')

###############################################################
#        EDA For Continuous and Ordinal Variables             #
###############################################################
# Create Scatterplot Matrix for LogSalePrice, LogLotArea, and LogLotFrontage
train['LogSalePrice'] = log(train['SalePrice'])
train['LogLotArea'] = log(train['LotArea'])
train['LogLotFrontage'] = log(train['LotFrontage'])
GenHome = c('LogSalePrice', 'LogLotArea', 'LogLotFrontage')
SqFtRm = c('LogSalePrice', 'GrLivArea', 'FirstFlrSF', 'SecondFlrSF', 'TotRmsAbvGrd')
BsmtGar = c('LogSalePrice', 'TotalBsmtSF', 'GarageArea', 'GarageCars')
DeckPool = c('LogSalePrice', 'WoodDeckSF', 'OpenPorchSF', 'PoolArea')
theme_update(plot.title = element_text(hjust = 0.5))
ggpairs(train[,GenHome], title = "ScatterPlot Matrix of General Home Data", lower = list(continuous = 'smooth'), 
        diag=list(continuous = 'barDiag'))
ggpairs(train[,SqFtRm], title = "ScatterPlot Matrix of Rooms and Sqft", lower = list(continuous = 'smooth'), 
        diag=list(continuous = 'barDiag'))
ggpairs(train[,BsmtGar], title = "ScatterPlot Matrix of Basements and Garages", lower = list(continuous = 'smooth'), 
        diag=list(continuous = 'barDiag'))
ggpairs(train[,DeckPool], title = "ScatterPlot Matrix of Decks and Pools", lower = list(continuous = 'smooth'), 
        diag=list(continuous = 'barDiag'))

#Review TotRmsAbvGrd
ggplot(train, aes(x = factor(TotRmsAbvGrd), y = SalePrice)) +
geom_boxplot(aes(fill = factor(TotRmsAbvGrd))) +
theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none")
#The Median value for home prices drops significantly above 9 rooms

train %>%
    group_by(TotRmsAbvGrd) %>%
    summarize(median_sale_price = median(SalePrice), n = n()) %>% print()

#Review MoSold and YrSold
ggplot(train, aes(x = factor(MoSold), y = SalePrice)) +
geom_boxplot(aes(fill = factor(MoSold))) +
theme(axis.text.x = element_text(angle = 0, size = 10), legend.position = "none")

#Create HomeAgeSold and YearRemodAdd
train_Age <- train %>%
    mutate(HomeAgeSold = YrSold - YearBuilt, AgeRemod = YrSold - YearRemodAdd)
train_Age_group <- train_Age %>%
    group_by(HomeAgeSold) %>%
    summarize(median_sale_price = median(SalePrice), n = n()) %>% print()

#Review Review median SalePrice vs. HomeAgeSold
ggplot(train_Age_group, aes(x = HomeAgeSold, y = log(median_sale_price))) +
geom_point(col = "blue") +
geom_vline(xintercept = 25, colour = 'red') +
geom_vline(xintercept = 75, colour = 'red')

# Create 3 home age categories
attach(train_Age)
train_Age$Agecat[HomeAgeSold >= 75] <- "Historic"
train_Age$Agecat[HomeAgeSold > 25 & HomeAgeSold < 75] <- "Older Home"
train_Age$Agecat[HomeAgeSold <= 25] <- "Newer Home"
detach(train_Age)

#Compare these outliers later to outliers determined by the linear regression model
index <- which(train_Age['HomeAgeSold'] == 74 | train_Age['HomeAgeSold'] == 75 | train_Age['HomeAgeSold'] == 114 | train_Age['HomeAgeSold'] == 115 | train_Age['HomeAgeSold'] == 126 | train_Age['HomeAgeSold'] == 129)
oldexphomes <- train_Age[index, ]
print(oldexphomes)

catvariables <- c('MSSubClass', 'MSZoning', 'Street', 'Alley', 'LotShape', 'LandContour', 'Utilities', 'LotConfig', 'LandSlope',
                  'Neighborhood', 'Condition1', 'Condition2', 'BldgType', 'HouseStyle', 'RoofStyle', 'RoofMatl', 'Exterior1st',
                  'Exterior2nd', 'MasVnrType', 'ExterQual', 'ExterCond', 'Foundation', 'BsmtQual', 'BsmtCond', 'BsmtExposure',
                  'BsmtFinType1', 'BsmtFinType2', 'Heating', 'HeatingQC', 'CentralAir', 'Electrical', 'KitchenQual', 'Functional',
                  'FireplaceQu', 'GarageType', 'GarageFinish', 'GarageQual', 'GarageCond', 'PavedDrive', 'Fence', 'PoolQC',
                  'MiscFeature', 'SaleType', 'SaleCondition', 'Agecat')
ordvariables <- c('OverallQual', 'OverallCond', 'BsmtFullBath', 'BsmtHalfBath', 'FullBath', 'HalfBath', 'BedroomAbvGr', 'KitchenAbvGr',
                  'TotRmsAbvGrd', 'Fireplaces', 'GarageCars', 'MoSold', 'YrSold', 'GarageYrBlt', 'YearBuilt', 'YearRemodAdd')
contvariables <- c('LotFrontage', 'LotArea', 'MasVnrArea', 'BsmtFinSF1', 'BsmtFinSF2', 'BsmtUnfSF', 'TotalBsmtSF', "FirstFlrSF",
                   "SecondFlrSF", 'LowQualFinSF', 'GrLivArea', 'GarageArea', 'WoodDeckSF', 'OpenPorchSF', 'EnclosedPorch', 'ScreenPorch',
                   "SsnPorch", 'PoolArea', 'MiscVal', 'HomeAgeSold', 'AgeRemod')

#Review correlation plots for Ordinal and Continous Variables
corord <- round(cor(train_Age[ordvariables]),1)
corcont <- round(cor(train_Age[contvariables]), 1)
corordcont <- round(cor(train_Age[ordvariables], train_Age[contvariables]), 1)
ggcorrplot(corord, hc.order = TRUE, lab = TRUE)
ggcorrplot(corcont, hc.order = TRUE, lab = TRUE)
ggcorrplot(corordcont, hc.order = TRUE, type = "lower", lab = TRUE, ggtheme = ggplot2::theme_gray)

#Remove GarageCars from future analysis 0.9 correlation with GarageArea.
#Also remove FirstFlrSF due to 0.8 correlation with TotalBsmtSF and GrLivArea
#Also remove SecondFlrSF due to 0.7 correlation with GrLivArea
#Also removing TotalRmsAbvGrd due to 0.8 correlation with GrLivArea
#Update variable vectors

ordvariablesup <- c('OverallQual', 'OverallCond', 'BsmtFullBath', 'BsmtHalfBath', 'FullBath', 'HalfBath', 'BedroomAbvGr',
                    'KitchenAbvGr', 'Fireplaces', 'MoSold', 'YrSold', 'YearBuilt', 'GarageYrBlt', 'YearRemodAdd')
contvariablesup <- c('LogLotFrontage', 'LogLotArea', 'MasVnrArea', 'BsmtFinSF1', 'BsmtFinSF2', 'BsmtUnfSF', 'TotalBsmtSF',
                     'GrLivArea', 'GarageArea', 'WoodDeckSF', 'HomeAgeSold', 'AgeRemod', 'OpenPorchSF', 'EnclosedPorch',
                     'ScreenPorch', "SsnPorch", 'PoolArea', 'LowQualFinSF', 'MiscVal')
catvariablesup <- c('MSSubClass', 'MSZoning', 'Street', 'Alley', 'LotShape', 'LandContour', 'Utilities', 'LotConfig', 'LandSlope',
                    'Neighborhood', 'Condition1', 'Condition2', 'BldgType', 'HouseStyle', 'RoofStyle', 'RoofMatl', 'Exterior1st',
                    'Exterior2nd', 'MasVnrType', 'ExterQual', 'ExterCond', 'Foundation', 'BsmtQual', 'BsmtCond', 'BsmtExposure',
                    'BsmtFinType1', 'BsmtFinType2', 'Heating', 'HeatingQC', 'CentralAir', 'Electrical', 'KitchenQual', 'Functional',
                    'FireplaceQu', 'GarageType', 'GarageFinish', 'GarageQual', 'GarageCond',
                    'PavedDrive', 'Fence', 'PoolQC', 'MiscFeature', 'SaleType', 'SaleCondition', 'Agecat')


corord <- round(cor(train_Age[ordvariablesup]),1)
corcont <- round(cor(train_Age[contvariablesup]), 1)
corordcont <- round(cor(train_Age[ordvariablesup], train_Age[contvariablesup]), 1)
ggcorrplot(corord, hc.order = TRUE, lab = TRUE)
ggcorrplot(corcont, hc.order = TRUE, lab = TRUE)
ggcorrplot(corordcont, hc.order = TRUE, type = "lower", lab = TRUE, ggtheme = ggplot2::theme_gray)
#Removing YearRemodAdd due to -1 correlation with AgeRemod and Removing YrSold and YrBuilt for similar correlation with HomeAgeSold

#Final variable vector update
ordvariablesup <- c('OverallQual', 'OverallCond', 'BsmtFullBath', 'BsmtHalfBath', 'FullBath', 'HalfBath', 'BedroomAbvGr',
                    'KitchenAbvGr', 'Fireplaces', 'MoSold', 'GarageYrBlt')
contvariablesup <- c('LogLotFrontage', 'LogLotArea', 'MasVnrArea', 'BsmtFinSF1', 'BsmtFinSF2', 'BsmtUnfSF', 'TotalBsmtSF',
                     'GrLivArea', 'GarageArea', 'WoodDeckSF', 'HomeAgeSold', 'AgeRemod', 'OpenPorchSF', 'EnclosedPorch',
                     'ScreenPorch', "SsnPorch", 'PoolArea', 'LowQualFinSF', 'MiscVal')


###############################################################
#             Create Variable Selection MLR Models            #
###############################################################
predictorvariables <- c(ordvariablesup, contvariablesup, catvariablesup)
alpha <- 0.05
crit_val <- qt(1-alpha/2, df = nrow(train) - 2)
Formula <- formula(paste("LogSalePrice ~ ",
paste(predictorvariables, collapse=" + ")))

#Create Backward Selection model
train_lm <- lm(Formula, train_Age)
# Set seed for reproducibility
set.seed(123)
# Set up repeated k-fold cross-validation
train.control <- trainControl(method = "cv", number = 10)
# Train the model
step.model <- train(Formula, train_Age,
                    method = "leapBackward",
                    tuneGrid = data.frame(nvmax = 1:40),
                    trControl = train.control)
step.model$results
step.model$bestTune

#Create Forward Selection model
set.seed(123)
# Set up repeated k-fold cross-validation
train.control <- trainControl(method = "cv", number = 10)
# Train the model
step.model <- train(Formula, train_Age,
method = "leapForward",
tuneGrid = data.frame(nvmax = 1:40),
trControl = train.control
)
step.model$results
step.model$bestTune

#Create StepWise Selection model
set.seed(123)
# Set up repeated k-fold cross-validation
train.control <- trainControl(method = "cv", number = 10)
# Train the model
step.model <- train(Formula, train_Age,
                    method = "leapSeq",
                    tuneGrid = data.frame(nvmax = 1:40),
                    trControl = train.control)
step.model$results
step.model$bestTune
coef(step.model$finalModel, 27)

train_best_lm <- lm(LogSalePrice ~ OverallQual + OverallCond + BsmtFullBath + LogLotArea + GrLivArea + HomeAgeSold + AgeRemod +
                        GarageArea + WoodDeckSF + OpenPorchSF + Neighborhood + SsnPorch + Condition2 + GarageType + KitchenQual +
                        SaleType + Foundation + Exterior1st + BsmtFinType2, data = train_Age)

#Run diagnostic tests to determine model validity
summary(train_best_lm)
train_best_lm %>%
tidy(conf.int = TRUE, conf.level = 1-alpha)
train_best_lm_aug <- train_best_lm %>%
augment()
index <- which(train_best_lm_aug$.cooksd >= 0.25)
high_cooksd <- train_best_lm_aug[index, ]
print(high_cooksd)
outlierTest(train_best_lm)
vif(train_best_lm)

#Remove outliers IDed during the Model testing 
train_Age <- train_Age[!(train_Age$Id %in% c(1299, 524, 584, 633, 496, 31, 969, 917, 1325, 813)),]

#Run the final Model to create the SalesPrice predictions
set.seed(123)
# Set up repeated k-fold cross-validation
train.control <- trainControl(method = "cv", number = 10)
# Train the model
step.model <- train(Formula, train_Age,
                    method = "leapForward",
                    tuneGrid = data.frame(nvmax = 1:40),
                    trControl = train.control)
step.model$results
step.model$bestTune
coef(step.model$finalModel, 29)

train_final_lm <- lm(LogSalePrice ~ OverallQual + OverallCond  + BsmtFullBath + KitchenAbvGr + LogLotArea + BsmtFinSF1  + GrLivArea + 
                         GarageYrBlt + GarageArea + WoodDeckSF + HomeAgeSold + AgeRemod + OpenPorchSF + SsnPorch + MSZoning + 
                         Neighborhood + Street + Condition2 + Exterior1st + Foundation + BsmtFinType1 + FireplaceQu + GarageType + 
                         Agecat, data = train_Age)                          

train_final_lm %>%
    tidy(conf.int = TRUE, conf.level = 1-alpha)
train_final_lm_aug <- train_final_lm %>%
augment()
vif(train_final_lm)
plot(train_final_lm)

train_Age <- train_Age[!(train_Age$Id %in% c(993, 991, 410, 409)),]

#Refit the model following Outlier Removal
train_final_lm <- lm(LogSalePrice ~ OverallQual + OverallCond  + BsmtFullBath + KitchenAbvGr + LogLotArea + BsmtFinSF1  + GrLivArea + 
                         GarageYrBlt + GarageArea + WoodDeckSF + HomeAgeSold + AgeRemod + OpenPorchSF + SsnPorch + MSZoning + 
                         Neighborhood + Street + Condition2 + Exterior1st + Foundation + BsmtFinType1 + FireplaceQu + GarageType + 
                         Agecat, data = train_Age)                          

train_final_lm %>%
    tidy(conf.int = TRUE, conf.level = 1-alpha)
train_final_lm_aug <- train_final_lm %>%
    augment()
vif(train_final_lm)
plot(train_final_lm)
###############################################################
#             Create Predictions on Test Dataset              #
###############################################################
#Transformations and Feature Engineering in the test dataset
test['LogLotArea'] = log(test['LotArea'])
test['LogLotFrontage'] = log(test['LotFrontage'])
test <- test %>%
    mutate(HomeAgeSold = YrSold - YearBuilt, AgeRemod = YrSold - YearRemodAdd)
attach(test)
test$Agecat[HomeAgeSold >= 75] <- "Historic"
test$Agecat[HomeAgeSold > 25 & HomeAgeSold < 75] <- "Older Home"
test$Agecat[HomeAgeSold <= 25] <- "Newer Home"
detach(test)

#Create Predictions for test Dataset and back transform SalesPrice
pred <- exp(predict(train_final_lm, test))
pred <- data.frame(id = test[,1], pred)
colnames(pred)[2] <- 'SalePrice'
index <- which(pred$PricePredicitons <= 0)
pred[index, 'SalePrice'] <- 100000
print(head(pred))

#Create .csv for Kaggle
write_csv(pred, 'Data/prediction.csv')





