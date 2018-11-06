
***
# Codebook for Case Study 2

---

### Data Selection

---

The data in this project consists of two primary files: train.csv and test.csv.  Between the two files, there are 2930 observations, 82 variables (23 nominal, 23 ordinal, 14 discrete, and 20 continuous variables, and 2 additional observation identifiers).


## Train.csv

---

| Variable Name |                      Description                     |         Type |
| :-------------- | :-----------------------------------------------  | :----------- |
| SalePrice | The property's sale price in dollars. This is the target variable that you're trying to predict | Continuous |
| MSSubClass | The building class | Categorical | 
| MSZoning | The general zoning classification | Categorical |
| LotFrontage | Linear feet of street connected to property | Continuous |
| LotArea | Lot size in square feet | Continuous | 
| Street | Type of road access | Categorical | 
| Alley |  Type of alley access | Categorical | 
| LotShape | General shape of property | Categorical |
| LandContour | Flatness of the property | Cateogrical | 
| Utilities | Type of utilities available | Categorical |
| LotConfig |  Lot configuration | Categorical | 
| LandSlope | Slope of property | Categorical | 
| Neighborhood | Physical locations within Ames city limits | Categorical | 
| Condition1 | Proximity to main road or railroad | Categorical | 
| Condition2 | Proximity to main road or railroad (if a second is present) | Categorical | 
| BldgType | Type of dwelling | Categorical | 
| HouseStyle | Style of dwelling | Categorical | 
| OverallQual | Overall material and finish quality | Ordinal | 
| OverallCond | Overall condition rating | Ordinal | 
| YearBuilt | Original construction date | Ordinal |
| YearRemodAdd | Remodel date | Ordinal | 
| RoofStyle | Type of roof | Categorical | 
| RoofMatl | Roof material | Categorical | 
| Exterior1st | Exterior covering on house | Categorical | 
| Exterior2nd | Exterior covering on house (if more than one material) | Categorical | 
| MasVnrType | Masonry veneer type | Categorical | 
| MasVnrArea | Masonry veneer area in square feet | Continuous | 
| ExterQual | Exterior material quality | Categorical | 
| ExterCond | Present condition of the material on the exterior | Categorical | 
| Foundation | Type of foundation | Categorical | 
| BsmtQual | Height of the basement | Categorical | 
| BsmtCond | General condition of the basement | Categorical | 
| BsmtExposure | Walkout or garden level basement walls | Categorical |
| BsmtFinType1 | Quality of basement finished area | Categorical |
| BsmtFinSF1 | Type 1 finished square feet | Continuous |
| BsmtFinType2 | Quality of second finished area (if present) | Categorical |
| BsmtFinSF2 | Type 2 finished square feet | Continuous |
| BsmtUnfSF | Unfinished square feet of basement area | Continuous |
| TotalBsmtSF | Total square feet of basement area | Continuous |
| Heating | Type of heating | Categorical |
| HeatingQC | Heating quality and condition | Categorical |
| CentralAir | Central air conditioning | Categorical |
| Electrical | Electrical system | Categorical |
| 1stFlrSF | First Floor square feet  | Continuous |
| 2ndFlrSF | Second floor square feet | Continuous |
| LowQualFinSF | Low quality finished square feet (all floors) | Continuous |
| GrLivArea | Above grade (ground) living area square feet | Continuous | 
| BsmtFullBath | Basement full bathrooms | Ordinal |
| BsmtHalfBath | Basement half bathrooms | Ordinal |
| FullBath | Full bathrooms above grade | Ordinal |
| HalfBath | Half baths above grade | Ordinal |
| Bedroom | Number of bedrooms above basement level | Ordinal |
| Kitchen | Number of kitchens | Ordinal |
| KitchenQual | Kitchen quality | Categorical |
| TotRmsAbvGrd | Total rooms above grade (does not include bathrooms) | Ordinal |
| Functional | Home functionality rating | Categorical |
| Fireplaces | Number of fireplaces | Ordinal |
| FireplaceQu | Fireplace quality | Categorical |
| GarageType | Garage location  | Categorical |
| GarageYrBlt | Year garage was built | Ordinal |
| GarageFinish | Interior finish of the garage | Categorical |
| GarageCars | Size of garage in car capacity | Ordinal |
| GarageArea | Size of garage in square feet | Continuous |
| GarageQual | Garage quality | Categorical |
| GarageCond | Garage condition | Categorical |
| PavedDrive | Paved driveway | Categorical |
| WoodDeckSF | Wood deck area in square feet | Continuous |
| OpenPorchSF | Open porch area in square feet | Continuous |
| EnclosedPorch | Enclosed porch area in square feet | Continuous |
| 3SsnPorch | Three season porch area in square feet | Continuous | 
| ScreenPorch | Screen porch area in square feet | Continuos | 
| PoolArea | Pool area in square feet | Continuous | 
| PoolQC | Pool quality | Categorical | 
| Fence | Fence quality | Categorical | 
| MiscFeature | Miscellaneous feature not covered in other categories | Categorical | 
| MiscVal | Dollar Value of miscellaneous feature | Continuous | 
| MoSold | Month Sold | Ordinal | 
| YrSold | Year Sold | Ordinal | 
| SaleType | Type of sale | Categorical | 
| SaleCondition | Condition of sale | Categorical | 

### Additional Variables created during Feature Engineering

---

| Variable Name |                      Description                     |         Type |
| :-------------- | :-----------------------------------------------  | :----------- |
| HomeAgeSold | Calculated by subtracting the YearBuilt from YrSold variables | Continuous |
| AgeRemod | Calculated by subtracting the YearRemodAdd from YrSold variables | Continuous | 
| Agecat | Created by cutting the YearBuilt Variable into < 25, between 25 and 75, and > 75 Years Old | Categorical |
| LogLotFrontage | Log Transformation of the LotFrontage variable | Continuous |
| LogLotArea | Log Transformation of the LotArea variable | Continuous |


### Data Frames and Data Tables
---
| Data Name | Variables | Observations | Method |
| :-------------: | :------------:| :----------: | ------------ |
| train | 81 | 1460 | Result of read.csv on train.csv |
| test | 80 | 1459 | Result of read.csv on test.csv missing Variable is SalePrice |
| HDI_df | 4 | 189 | Scraped Human Development Index Data from Wikipedia |
| df2 | 1 | 189 | Subset HDI_df for discrete 'Country' names |
| HDI_df2 | 3 | 189 | cbind HDI_df and df2 adding Human Development levels |
| tidydata1 | 67 | 4367 | Merged tidydata with HDI_df2 via 'Country' Variable |
| tidydata18_67 | 68 | 4009 | Removed Ages less than 18 and above 67.5 from tidydata1 |
| ws | 2 | 6 | peform count function on tidydata18_67 for 'WorkStatus' |
| gen | 2 | 3 | peform count function on tidydata18_67 for 'Gender' |
| occ | 2 | 117 | peform count function on tidydata18_67 for 'Occupation' |
| ppc | 2 | 84 | peform tally, group_by function on tidydata18_67 for 'Country' |
| match | 2 | 2 | add ProsMatch column to tidydata18_67 and peform tally, group_by function | 
| topfifteen | 5 | 15 | subset tidydata18_67 top 15 countries based on 'GPMean' & 'AIPMean' |
| SWLSHDICat | 2 | 4 | subset and aggregate tidydata18_67 for 'HDICategory' and 'SLWSMean' |

