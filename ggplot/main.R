library(geodata)
library(ggplot2)
library(rgdal)
library(sf)

##########################################################################
# REMEMBER TO SET SESSION WORKING DIRECTORY TO THIS FILE'S PARENT FOLDER #
##########################################################################

# 1. Load CSV data into a Dataframe `df` and get rid of records with a
# Shannon-Wiener Index (`H` column) of NA value

df <- read.csv("../data/tuhua.csv", stringsAsFactors = FALSE)
df <- df[is.na(df$H) == FALSE,]

# 2. Load Marine Reserves GeoJSON from Marine Data Portal
# https://services1.arcgis.com/3JjYDyG3oajxU6HO/arcgis/rest/services/DOC_Marine_Reserves/FeatureServer/0

tuhua.mr <-
  readOGR(
    "https://services1.arcgis.com/3JjYDyG3oajxU6HO/arcgis/rest/services/DOC_Marine_Reserves/FeatureServer/0/query?where=Name%20%3D%20'TUHUA%20(MAYOR%20ISLAND)%20MARINE%20RESERVE'&outFields=Name,Shape__Area,Shape__Length&outSR=4326&f=json"
  )

# 3. Get New Zealand coountry data from geodata package
# https://github.com/rspatial/geodata

nz.gadm <- gadm("NZ", level = 1, path = "../data/")
nz.df <- as.data.frame(nz.gadm)
nz.df <- st_as_sf(nz.gadm)

# Tuhua layer to same CRS as NZ GADM

mr.df <- spTransform(tuhua.mr, crs(nz.gadm))

# 4. Arrange all data in a ggplot object
# See https://ggplot2.tidyverse.org/

plt <- ggplot(nz.df) + geom_sf(fill = "grey", alpha = 0.3) +
  geom_polygon(
    data = mr.df,
    aes(x = long, y = lat, group = group),
    colour = "#00ff00",
    fill = "#00ff00",
    alpha = 0.2
  ) +
  coord_sf(
    xlim = c(176.2092899568599, 176.30032714224936),
    ylim = c(-37.245069509603134,-37.321945636347586)
  ) +
  geom_point(data = df ,
             aes(
               x = Long,
               y = Lat,
               size = H,
               colour = factor(Year)
             ),
             alpha = 0.5) +
  scale_colour_manual(values = c("#6666FF", "#FFA500")) + theme_bw() + theme(axis.title = element_blank()) +
  labs(colour = "Year", size = "Shannon-Wiener Index") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# 5. Show plot in Plots pane (if using RStudio) and save to disk
# Can also be exported from RStudio editing resolution and other details
plt
ggsave(
  "./tuhua.png",
  width = 2200,
  height = 2200,
  units = "px",
  plot = plt,
  dpi = 300,
  type = "cairo"
)
