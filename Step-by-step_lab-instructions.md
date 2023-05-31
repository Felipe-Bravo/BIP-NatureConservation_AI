# Dead wood detection by ML
## Workflow
### 1. Preparatory actions
### 2. Obtaining ground data
### 3. Importing remote sensing data from Earth Explorer
### 4. Extract base information to compute remote sensing metrics
### 5. Managing the dataset
### 6. Preparing data for ML models
### 7. Fitting ML models
   Binomial logistic regression
   
   Naive bayes
   
   Suport Vector Machinge
### 8. Assessing ML models
---------------------


### Preparatory actions
Define a working directory for your work (I used to have a folder in the root directory and create inside a folder for each project. In this case my working directory will be C:\datosR\BIP-NatureConsAI

### Obtaining ground data
We'll use data from the National Forest Inventory of Spain, 3rd edition. You can get detailed information at this paper by [Alberdi et al, 2021](https://pfb.cnpf.embrapa.br/pfb/index.php/pfb/article/view/1337/580) In the following two images (from Alberdi et al, 2021) you can outlook the NFI field methodology

<img src="https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/blob/master/images/Spanish-NFI-dendrometrics.png" style="display: block; margin: auto;" />

Dendrometric measurements in the Spanish NFI plots

<img src="https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/blob/master/images/Spanish-NFI-biodiversity.png" style="display: block; margin: auto;" />

Biodiversity and associated measurements in the Spanish NFIplots

The raw NFI data are freely available at this [link](https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/cartografia_informacion_disp.aspx) We'll use the data from the Palencia province NFI3 (you can find the preprocessed data at the data folder in this repository and the R code to obtain such data set in this [SMART Global Ecosystems repository](https://github.com/SMART-Global-Ecosystems/BIP_2022-23).
By coding you invest time in understanding the data structure and the processes to get the desired input but also saving time in future iteration where the dataset should be used for similar analysis.

### Importing remote sensing data from Earth Explorer
First we should select the adequate satellite for our project. As the NFI3 field data in Palencia where obtained in 2003, we'll use Landsat05 resources.

<img src="https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/blob/master/images/LANDSAT_missions.jpg"  style="display: block; margin: auto;" />

The 40 year history of landsat satellite missions. Source: [USGS - USGS Landsat Timeline](https://www.earthdatascience.org/courses/use-data-open-source-python/multispectral-remote-sensing/landsat-in-Python/) More details at [this link](https://www.earthdatascience.org/courses/use-data-open-source-python/multispectral-remote-sensing/landsat-in-Python/) 

The actions you must do are the following:
1. Go to https://earthexplorer.usgs.gov and login in the web (if necessary create a new user) Once loged search for your area of interest (in our case Norhern Spain) 
2. Then set up the following: in the search criteria set up choose circle, and select one place centered in your area of interest (ie, Center latitude: 42.65597990029712, Center longitud: -4.577442456870926 and radius: 50 km) and then apply (a circle will bound our work area) also you have to set up the the time of interest (in our case 2003 because was the year of the IFN3 field work in Palencia); normally we choose from May to September because are the less cloudy months.
3. In the Data sets choose Landsat ->Landsat Collection 2 Level 2 -> Landsat 4-5 TM C2 L2 and select Results (in the blue button, lower right part of the scheen) Choose (in the results area that will appear in your screen) the less cloudy image (maybe you need more than one image to cover the full circle defined above but select the same day for all the images needed) You can overlap the images by choosing 'Show Browse Overlay') Once the image(s) fits in your requirements you can download (press the 'Product options' and press the upper button to download the 'Landsat Collection 2 Level-2 Product Bundle') You must repeat this for each image (previously selected to overlap our area of interest)
4. Now you must unzip the downloaded files (place before the zip files in your working directory) in your dedicated directory for each set of images (a different name for each image)

If you don't have the requested files, you can download it from here: https://uvaes-my.sharepoint.com/:f:/g/personal/felipe_bravo_uva_es/EoXqa5_mnn9Ok5ul_oMtaBgBtK-dSODS3MkZFN-J8gWKmA?e=PZikj3

**OPTIONAL (to use GEE only)** If you use Google Earth Engine (instead Earth Explorer) you should convert the UTM coordinates to geographic coordinates by doing the following:
Transform the X, Y coordinates from the original dataset to global latitude and longitude coordinates (We'll do in QGIS). Follow the instructions (ands see https://gis.stackexchange.com/questions/64535/converting-x-y-coordinates-to-longitude-latitude-using-qgis for details):

0) Localize your data csv file in your computer and open QGIS (previously installed)
1) Import it (plots_IFN3_Palencia.csv) by Layer (instruction in the top bar in QGIS) -> Add delimited text layer.
The next dialogue should be fairly self explanatory. After clicking OK from this dialogue you will be asked for the coordinate system of your input coordinates. You can work through the list or use the Filter box to help find the right projection.
2) Once it's imported right click on the layer in the Layers panel, and choose "Export" and then 'Save features as".
3) Save it as a shapefile, and change "Layer CRS" to "Selected CRS", then browse the projections (click on the globe) to find "WGS84 geographiques (dms). Select to add it to the map and click ok. You must indicate a new file name
4) Once your new shapefile is created, right click on it the layer's dialogue and "Open Attribute Table". Toggle editing (ctrl-E) and open the calculator (ctrl-I). Select "create a new field", call it "longitude", chang the output field type to "Decimal number (real)" and precision to "6" and make the expression "$X", repeat to created the field "latitude" with the expression "$Y". You should now have latitude and longitude in your attribute table.

Optional:
5) If you want it in a spreadsheet a quick solution is to click on the invert selection icon (Ctrl-R) and then copy to clipboard (Ctrl-C). You can then paste it directly into a spreadsheet.

### Extract base information to compute remote sensing metrics

Open QGIS and follow this instructions:
0) Localize your data csv file in your computer and open QGIS (previously installed)
1) Import it (plots_IFN3_Palencia.csv) by Layer (instruction in the top bar in QGIS) -> Add delimited text layer.
The next dialogue should be fairly self explanatory. After clicking OK from this dialogue you will be asked for the coordinate system of your input coordinates. You can work through the list or use the Filter box to help find the right projection.
2) Once it's imported right click on the layer in the Layers panel, and choose "Export" and then 'Save features as".
3) Save it as a shapefile, and change "Layer CRS" to "Selected CRS", then browse the projections (click on the globe) to find "WGS84 geographiques (dms). Select to add it to the map and click ok. You must indicate a new file name.
4) Add the band 3 and 4 for each image from the unzip files (you can select and drop or follow the previous instruction to include new layers in the QGIS project)
5) Now we can extract the information from the bands 3 and 4 and included as attributes in our "plots_IFN3_Palencia-L05bandsn" layer Select now the toolbox (the wheel in the upper bar) and choose Raster analysis -> Sample raster values You must select the input layer (first your original data set and then the one create by the process) and the image layer (one by one the selected bands images)

You will get a new layer with the bands values as columns. Now you can export the final file by right click on the layer in the Layers panel, and choose "Export", then 'Save features as" and finallay as format choose 'Comma Separated Value [CSV]'

### Managing the dataset
Now we'll start to work with R to manage the dataset: import and data consolidation.

```{r, setup, include=FALSE}
#### Basic steps ####

# path
setwd("C:/Writehere/yourdesiredfolder") 

# installing and requesting libraries
library(plyr)
library(dplyr)
library(stringr)

# Spanish NFI3 data
data <- read.csv('finalplots-Palencia.csv')

# consolidating band3 and 4 variables
data$band3 <- ifelse(!is.na(data$band31), data$band31, data$band31_2)
data$band4 <- ifelse(!is.na(data$band41), data$band41, data$band41_2)
```
To continue we'll define new field metrics (proportions of trees by size classes and proportion of the dominant species by basal area)

```{r, setup, include=FALSE}
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
```
Once we have this we're going to compute diferent remote sensing metrics (NDVI and SAVI)

**NDVI** (Normalized Difference Vegetation Index) isused to quantify vegetation greenness and is useful n understanding vegetation density and assessing changes in plant health. NDVI is calculated as a ratio between the red (R) and near infrared (NIR) values (see details at https://www.usgs.gov/landsat-missions/landsat-normalized-difference-vegetation-index)

NDVI =  (NIR - R) / (NIR + R)

```{r, setup, include=FALSE}
data$NDVI = (data$band4 - data$band3)/(data$band4 + data$band3)
```
**SAVI** (Soil Adjusted Vegetation Index) is used to correct Normalized Difference Vegetation Index (NDVI) for the influence of soil brightness in areas where vegetative cover is low. Landsat Surface Reflectance-derived SAVI is calculated as a ratio between the R and NIR values with a soil brightness correction factor (L) defined as 0.5 to accommodate most land cover types.

SAVI = ((NIR - R) / (NIR + R + L)) * (1 + L)

```{r, setup, include=FALSE}
data$SAVI = ((data$band4 - data$band3)/(data$band4 + data$band3+0.5))*(1.5)
```

To finalize the preparatory management we'll adequate the dataset for further analysis by keeping only the key variables in the dataset

```{r, setup, include=FALSE}
new_data <- subset(data, select = -c(field_1, INVENTORY_ID, province
                                     ,notebook, class, subclass
                                     ,CD_0_75, CD_75_125, CD_125_175, CD_175_225, CD_225_275
                                     ,CD_275_325, CD_325_375, CD_375_425, CD_425_
                                     ,band31, band31_2, band41, band41_2))

new_data$Deadwood <- ifelse(new_data$Deadwood=="false",0,1)
new_data$Forest_type <- ifelse(new_data$Forest_type=="plantation",1,0)

names(new_data)
```

### Preparing data for ML models

Input data in this example including 25 independent variables (columns from 2 to 4, 6, 9, 15 to 18, 21, 24 to 26, 29 to 30 and 34 to 43) and the observed variables (column 5 - so-called as "Deadwood")

```{r, setup, include=FALSE}
data_ML <- new_data[,c(2:4,5:6,9,15:18,21,24:26,29:30,34:43)]
data_ML~Deadwood <- as.factor(data_ML~Deadwood)
sample <- sample(c(TRUE, FALSE), nrow(data_ML), replace=TRUE, prob=c(0.7,0.3))
trainData  <- data_ML[sample, ]
validData   <- data_ML[!sample, ]
```
### Fitting ML models

*Binomial logistic regression*

Our first ML model will be based on a [binomial logistic regression](https://en.wikipedia.org/wiki/Logistic_regression) where the response variable will be deadwood presence (Variable Deadwood in the dataset) After several attemps we arrived to a model where the explanatory variables are the latitude (Y), the forest type (Plantation=1, otherwise=0) and SDI ([Stand Density Index](https://en.wikipedia.org/wiki/Stand_density_index))

```{r, setup, include=FALSE}
#building the logistic model

logistic_model <- glm(Deadwood~ Forest_type  + SDI + NDVI  , data=trainData,
                      family= binomial)
summary(logistic_model)
validData$logistic_model_probs
validData$logistic_model_probs<-predict(logistic_model, 
                                type="response", newdata=validData)
head(validData)

```
Now is the moment to create the predictions for the validation dataset (validData) and to generate the confusion matrix to detect the true/false positives and the true/false negatives. The confusion matrix is defined in our case as follows:

<img src="https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/blob/master/images/ConfusionMatrix-example.png" style="display: block; margin: auto;" />

```{r, setup, include=FALSE}
# Make predictions on the validation set

validData$predictions <- ifelse(validData$logistic_model_probs >0.5, 1, 0)
ConfusionMatrix = table(validData$Deadwood, validData$predictions)
ConfusionMatrix
```
In this example our values are:
          True Negative (TN): 226
          False Negative (FN): 8
          False Positive (FP): 6
          True Positive (TP): 2

and now we can compute the [sensitivity, specifity](https://en.wikipedia.org/wiki/Sensitivity_and_specificity) and [accuracy](https://en.wikipedia.org/wiki/Accuracy_and_precision#In_classification) of the model as follows:

Sensitivity = TP/(TP + FN) = (Number of true positive assessment)/(Number of all positive assessment)

Specificity = TN/(TN + FP) = (Number of true negative assessment)/(Number of all negative assessment)

Accuracy = (TN + TP)/(TN+TP+FN+FP) = (Number of correct assessments)/(Number of all assessments)

```{r, setup, include=FALSE}
sensitivity_log <- 226/(226+8)
sensitivity_log

specifity_log <- 226/(226+6)
specifity_log

accuracy_log <- (226+2)/(218+2+8+6)
accuracy_log
```
It seems that accuracy is quite high (if you run the code, you get accuracy = 0.974359) However, if you observe the original dataset, you can see that absence of deadwood (Deadwood=0) is the most frequent situation in our plots (over the whole dataset, no deadwood is the outcome in a 93,7 % of the plots) Later we'll go back on this issue.

*Naive Bayes*

Now we'll develop a [Naive Bayes classifier](https://en.wikipedia.org/wiki/Naive_Bayes_classifier) based on applying Bayes' theorem with strong (naive) independence assumptions between the features. As previously the response variable will be deadwood presence (Variable Deadwood in the dataset) . We'll develop the Naive Bayes classifier with the train dataset and later we'll test with the validation dataset. 

```{r, setup, include=FALSE}

# Fitting NB classifier to the train set
install.packages('e1071')
library(e1071)


m <- naiveBayes(Deadwood ~ ., data = trainData)
m
# generating the confusion matrix
table(predict(m, validData), validData[,4])
```
In this example our values, from the confusion matrix are:
          True Negative (TN): 224
          False Negative (FN): 8
          False Positive (FP): 8
          True Positive (TP): 2

and now we can compute the sensitivity, specifity and accuracy as above

```{r, setup, include=FALSE}
sensitivity_NB <- 2/(2+8)
sensitivity_NB

specifity_NB <- 224/(224+8)
specifity_NB

accuracy_NB <- (224+2)/(224+2+8+2)
accuracy_NB
```
Again the accuracy is quite high (if you run the code, you get accuracy = 0.9576271) But again, wait until we check the observed absence/presence of deadwood in the whole dataset.

*Support Vector Machine*

Finnally we'll develop a [Support Vector Machine](https://en.wikipedia.org/wiki/Support_vector_machine) model based on constructs a hyperplane to classify the observations. As in the previous examples the response variable will be deadwood presence (Variable Deadwood in the dataset).

```{r, setup, include=FALSE}
svm = svm(Deadwood ~ SDI+NDVI, data = trainData, kernel = "linear", cost = 1000, scale = FALSE)
print(svm)
table(predict(svm, validData), validData[,4])
```
In this example our values, from the confusion matrix are:
          True Negative (TN): 226
          False Negative (FN): 6
          False Positive (FP): 10
          True Positive (TP): 0

and now we can compute the sensitivity, specifity and accuracy as above

```{r, setup, include=FALSE}
#sensitivity, specifity and accuracy
sensitivity_svm <- 10/(10+2)
sensitivity_svm

specifity_svm <- 226/(226+10)
specifity_svm

accuracy_svm <- (226+0)/(226+0+6+10)
accuracy_svm
```
As previously the accuracy is quite high (if you run the code, you get accuracy = 0.9338843) Let's check now the outcomes (from the three methods) versus the observed absence/presence of deadwood in the whole dataset.

### Assessing ML models

To assess the algorithms performance we'll use the [Cohen's kappa](https://en.wikipedia.org/wiki/Cohen%27s_kappa) (1960) that we'll used to measures the agreement between algorithms outcome versus the possibility of be rigth by chance. We'll define the chance probability as the ratio between the most frequent categorie two raters who each classify in the validation dataset (232 observations, stands, with no deadwood)

```{r, setup, include=FALSE}
########## assessing the agreement between ML outcomes and results by chance
#Cohen's kappa (1960)
#count Deadwood classes in validData
validData %>% count(Deadwood)
```
To compute Cohen's kappa (K) can be compute as:

K = (accuracy - most frequent class proportion)/(1 - most frequent class proportion)

```{r, setup, include=FALSE}
K_log = (0.974359 - 0.9586777)/(1-0.9586777)
K_NB = (0.974359 - 0.9576271)/(1-0.9576271)
K_svm = (0.974359 - 0.9338843)/(1-0.9338843)
K_log
K_NB
K_svm
```
the results is the logistic model is the best (K_log=0.3794876) been Naive Bayes quite similar (0.3948727) while the worst is the Support Vector Machine (0.6121799)
Agreement is poor if K < 0.00, slight if 0.00 ≤ K ≤ 0.20, fair if 0.21 ≤ K ≤ 0.40, moderate if 0.41 ≤ κ ≤ 0.60, substantial if 0.61 ≤ K ≤ 0.80, almost perfect if κ > 0.80. In our case as higher is the Cohen's kappa more similar the outcome to choose by chance (see details at Landis and Koch, 1977: https://doi.org/10.2307/2529310 also you can find the paper [here](https://pdfs.semanticscholar.org/7e73/43a5608fff1c68c5259db0c77b9193f1546d.pdf))
