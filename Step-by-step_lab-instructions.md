# Dead wood detection by ML
## Workflow
### 1. Preparatory actions
### 2. Obtaining ground data
### 3. Importing remote sensing data from Earth Explorer
### 4. Extract base information to compute remote sensing metrics
### 5. Managing the dataset
---------------------


### Preparatory actions
Define a working directory for your work (I used to have a folder in the root directory and create inside a folder for each project. In this case my working directory will be C:\datosR\BIP-NatureConsAI

### Obtaining ground data
We'll use data from the National Forest Inventory of Spain, 3rd edition. You can get detailed information at this paper by [Alberdi et al, 2021](https://pfb.cnpf.embrapa.br/pfb/index.php/pfb/article/view/1337/580) In the following two images (from Alberdi et al, 2021) you can outlook the NFI field methodology

![imagen](https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/assets/18259904/11e4f865-5213-4e4e-8035-ebc7e217e779)

![imagen](https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/assets/18259904/2dad8170-2572-4cbe-8a04-07d44f229e37)

The raw NFI data are freely available at this [link](https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/cartografia_informacion_disp.aspx) We'll use the data from the Palencia province NFI3 (you can find the preprocessed data at the data folder in this repository and the R code to obtain such data set in this [SMART Global Ecosystems repository](https://github.com/SMART-Global-Ecosystems/BIP_2022-23).
By coding you invest time in understanding the data structure and the processes to get the desired input but also saving time in future iteration where the dataset should be used for similar analysis.

### Importing remote sensing data from Earth Explorer
First we should select the adequate satellite for our project. As the NFI3 field data in Palencia where obtained in 2003, we'll use Landsat05 resources.

![imagen](https://github.com/Felipe-Bravo/BIP-NatureConservation_AI/assets/18259904/4024f7b3-9ea7-4dae-8534-721b03290c11)
The 40 year history of landsat satellite missions. Source: [USGS - USGS Landsat Timeline](https://www.earthdatascience.org/courses/use-data-open-source-python/multispectral-remote-sensing/landsat-in-Python/) More details at [this link](https://www.earthdatascience.org/courses/use-data-open-source-python/multispectral-remote-sensing/landsat-in-Python/) 

The actions you must do are the following:
1. Go to https://earthexplorer.usgs.gov and login in the web (if necessary create a new user) Once loged search for your area of interest (in our case Norhern Spain) 
2. Then set up the following: in the search criteria set up choose circle, and select one place centered in your area of interest (ie, Center latitude: 42.65597990029712, Center longitud: -4.577442456870926 and radius: 50 km) and then apply (a circle will bound our work area) also you have to set up the the time of interest (in our case 2003 because was the year of the IFN3 field work in Palencia); normally we choose from May to September because are the less cloudy months.
3. In the Data sets choose Landsat ->Landsat Collection 2 Level 2 -> Landsat 4-5 TM C2 L2 and select Results (in the blue button, lower right part of the scheen) Choose (in the results area that will appear in your screen) the less cloudy image (maybe you need more than one image to cover the full circle defined above but select the same day for all the images needed) You can overlap the images by choosing 'Show Browse Overlay') Once the image(s) fits in your requirements you can download (press the 'Product options' and press the upper button to download the 'Landsat Collection 2 Level-2 Product Bundle') You must repeat this for each image (previously selected to overlap our area of interest)
4. Now you must unzip the downloaded files (place before the zip files in your working directory) in your dedicated directory for each set of images (a different name for each image)

If you don't have the requested files, you can download it from [here](https://uvaes-my.sharepoint.com/:f:/g/personal/felipe_bravo_uva_es/EoXqa5_mnn9Ok5ul_oMtaBgBkEFP8IqSptwxCbtN0ZiNJw?e=bsWrkt) The password will be provided in the in person sessions.

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
new_data <- subset(data, select = -c(field_1, INVENTORY_ID, province,
                                     notebook, class, subclass,
                                     band31, band31_2, band41, band41_2))
names(new_data)
```
