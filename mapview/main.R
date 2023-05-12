library(mapview)
library(RColorBrewer)
library(rgdal)

##########################################################################
# REMEMBER TO SET SESSION WORKING DIRECTORY TO THIS FILE'S PARENT FOLDER #
##########################################################################

####################################################
# Generate quick R mapview maps
# See https://r-spatial.github.io/mapview/index.html
####################################################

# 1. Load CSV data into a Dataframe `df` and get rid of records with a
# Shannon-Wiener Index (`H` column) of NA value

df <- read.csv("../data/tuhua.csv", stringsAsFactors = FALSE)
df <- df[is.na(df$H)==FALSE, ]

# 2. Load Marine Reserves GeoJSON from Marine Data Portal
# already filter using the `where` parameter
# https://services1.arcgis.com/3JjYDyG3oajxU6HO/arcgis/rest/services/DOC_Marine_Reserves/FeatureServer/0

tuhua.mr <- readOGR("https://services1.arcgis.com/3JjYDyG3oajxU6HO/arcgis/rest/services/DOC_Marine_Reserves/FeatureServer/0/query?where=Name%20%3D%20'TUHUA%20(MAYOR%20ISLAND)%20MARINE%20RESERVE'&outFields=Name,Shape__Area,Shape__Length&outSR=4326&f=json")

# 3. Define palette of minimum 3 colors although we pick as many as unique year values

min.cols <- length(unique(df$Year))
pal <- brewer.pal(
  n = max(3, min.cols),
  name="Set2")[1:min.cols]

# 4. Generate mapview instance in `m` variable
# 
# CSV data loaded into dataframe df is plotted with dot size according to `H` 
# (Shannon-Wiener Index) value and colored by Year using the `pal` colors.
# 
# GeoJSON containing Tuhua MR plotted in green
#
m <- mapview(df, layer.name = c("Shannon-Wiener Index"),
             xcol="Long", ycol="Lat", zcol="Year", cex="H", crs=4326, grid=FALSE,
             col.regions=pal, legend=TRUE) + mapview(tuhua.mr, layer.name = tuhua.mr$Name,
               color = 'green', alpha.regions = 0.2, col.regions="green")

# show map on Viewer pane (if using Rstudio)
m

# 5. Save mapshot to html file
# Open the resulting `index.html` in your local browser or publish it in a Github 
# repository if you are looking to share it with others.
# See https://pages.github.com/ for more information on how to publish
mapshot(m, url = "./index.html")

m
