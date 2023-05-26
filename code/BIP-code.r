# R script for ML analysis
# BIP Nature Conservation and Artificial Intelligence
# Mobility week at Bragança



##### Basic steps ########################


# path
setwd("C:/datosR/BIP-NatConsAI")  

# installing and loading required libraries
library(plyr)
library(dplyr)
library(stringr)

# Spanish NFI3 data
data <- read.csv('finalplots-Palencia.csv')

# consolidating band3 and 4 variables
data$band3 <- ifelse(!is.na(data$band31), data$band31, data$band31_2)
data$band4 <- ifelse(!is.na(data$band41), data$band41, data$band41_2)

# generating new variables by combination of the raw variables
# number of trees by diameter classes

data$finewood <- data$CD_0_75 + data$CD_75_125 + data$CD_125_175
data$mediumwood <- data$CD_175_225 + data$CD_225_275 + data$CD_275_325
data$bigwood <- data$CD_325_375 + data$CD_375_425 + data$CD_425_

#computing proportions
data$finewood_ratio <- data$finewood/data$N
data$mediumwood_ratio <- data$mediumwood/data$N
data$bigwood_ratio <- data$bigwood/data$N

data$ba_domsp_ratio <- data$G_sp_1/data$G
data$ba_alive_ratio <-data$G_alive/data$G

#### Metrics from Landsat 05 bands 3 and 4 ####

# NDVI: Normalized Difference Vegetation Index 

data$NDVI = (data$band4 - data$band3)/(data$band4 + data$band3)

# SAVI: Soil Adjusted Vegetation Index


data$SAVI = ((data$band4 - data$band3)/(data$band4 + data$band3+0.5))*(1.5)

#### keeping only the key variables

new_data <- subset(data, select = -c(field_1, INVENTORY_ID, province,
                                     notebook, class, subclass,
                                     CD_0_75, CD_75_125, CD_125_175, CD_175_225, CD_225_275, 
                                     CD_275_325, CD_325_375, CD_375_425, CD_425_,
                                     band31, band31_2, band41, band41_2))

new_data$Deadwood <- ifelse(new_data$Deadwood=="false",0,1)
new_data$Forest_type <- ifelse(new_data$Forest_type=="plantation",1,0)

names(new_data)



##### Preparing data for ML models ########################


# Input data in this example including ten independent variables (columns from 2 to 4,
# 6, 9, 15 to 18, 21, 24 to 26, 29 to 30 and 34 to 43), 
# and the observed variables (column 5 - so-called as "Deadwood")
data_ML <- new_data[,c(2:4,5:6,9,15:18,21,24:26,29:30,34:43)]
data_ML$Deadwood <- as.factor(data_ML$Deadwood)
sample <- sample(c(TRUE, FALSE), nrow(data_ML), replace=TRUE, prob=c(0.7,0.3))
trainData  <- data_ML[sample, ]
validData   <- data_ML[!sample, ]
names(trainData)

###### Logistic regression ##############

#building the logistic model

logistic_model <- glm(Deadwood~ Y + Forest_type  + SDI  , data=trainData,
                      family= binomial)
summary(logistic_model)
validData$logistic_model_probs
validData$logistic_model_probs<-predict(logistic_model, 
                                type="response", newdata=validData)
head(validData)

# Make predictions on the validation set

validData$predictions <- ifelse(validData$logistic_model_probs >0.5, 1, 0)
ConfusionMatrix = table(validData$Deadwood, validData$predictions)
ConfusionMatrix

#sensitivity, specifity and accuracy


sensitivity <- 1/(1+14)
sensitivity

specifity <- 218/(218+1)
specifity

accuracy <- (218+1)/(218+1+14+1)
accuracy

####### Naive Bayes #############################################


# Fitting NB classifier to the train set
install.packages('e1071')
library(e1071)


m <- naiveBayes(Deadwood ~ ., data = trainData)
m
# generating the confusion matrix
table(predict(m, validData), validData[,4])

#sensitivity, specifity and accuracy


sensitivity_NB <- 2/(2+0)
sensitivity_NB

specifity_NB <- 219/(219+2)
specifity_NB

accuracy_NB <- (219+13)/(219+13+0+2)
accuracy_NB

####### SVM #############################################


# Fitting SVM to the train set
install.packages('e1071')
library(e1071)

svm_model = svm(formula = trainData$Deadwood ~ .,
                data = trainData,
                type = 'C-classification',
                cost = 100,
                kernel = 'linear')
summary(svm_model)
#### Not functioning from here
# Predicting the validData set results
validData$y_pred = predict(svm_model, newdata = validData[-4])

# Making the Confusion Matrix
cm = table(validData[,4], y_pred)
print(cm)
pred_train <- predict(svm_model, train)
mean(pred_train == train$Cluster) # Accuracy of train data
pred_validData <- predict(svm_model, validData)
mean(pred_validData == validData$Cluster) # Accuracy of validData data

confusionMatrix(y_pred, validData$Cluster)
#plot(svm_model, train, Cluster ~ .)







