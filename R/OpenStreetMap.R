## OPENSTREETMAP ##
# Load libraries
# Load Libraries
prepare_packages <- function(packages){
  # Check if packages are not installed
  not_installed <- packages[!(packages %in% installed.packages()[, 'Package'])]
  # If not installed, install
  if (length(not_installed)) 
    install.packages(not_installed, dependencies = TRUE)
  # Load all packages
  sapply(packages, require, character.only = TRUE)
}
packages <- c('osmdata', # OpenStreetMap
              'rgdal', # Projection/Transformation operations 
              'maptools', # Geographic Data Manipulation
              'rgeos', # Topology Operations
              'leaflet', # Interactive Charts
              'dplyr', # Data Manipulation
              'geosphere' # Trigonometry (Distances)
)
prepare_packages(packages)

# Download the info
# City Map
mapa1 <- opq(bbox = 'Madrid, Spain')
# Specific Buildings
Poligonos_inside <- add_osm_feature(mapa1, 
                                    key = 'building',  # Other options: https://wiki.openstreetmap.org/wiki/Category:Keys
                                    value = 'hospital')  # Other options: https://wiki.openstreetmap.org/wiki/Talk:Key:building

# View all key options for add_osm_feature
#available_features()
# View all value options for a specific key option
#available_tags('building')
#?add_osm_feature # Help function
# More info: https://dominicroye.github.io/en/2018/accessing-openstreetmap-data-with-r/

# Formatting to Spatial
df <- osmdata_sp(Poligonos_inside)

# Centroides of each Polygon + Representation
spChFIDs(df$osm_polygons) <- 1:nrow(df$osm_polygons@data)

# Represent the points
centroides <- gCentroid(df$osm_polygons, byid = TRUE) 

# Illustrate maps
leaflet(centroides) %>% 
  addTiles() %>% 
  addCircles()

# Create a Buffer around the buildings; less than 200 meters
buffer <- gBuffer(centroides, byid = TRUE, width = 0.002)

# Convert to Spatial Polygon DataFrame
leaflet(centroides) %>% 
  addTiles() %>% 
  addPolygons(data=buffer,col='red') %>% 
  addCircles()

# Combine the Polygons where the Buffer touches
buffer <- SpatialPolygonsDataFrame(buffer,data.frame(row.names=names(buffer),n= 1:length(buffer))) 

gt <- gIntersects(buffer, byid = TRUE, returnDense = FALSE)

ut <- unique(gt); nth <- 1:length(ut); buffer$n <- 1:nrow(buffer); buffer$nth <- NA

for(i in 1:length(ut)){
  x <- ut[[i]]; buffer$nth[x] <- i}

buffdis <- gUnaryUnion(buffer, buffer$nth)

# Convert to Spatial Polygon DataFrame
# Combine the Polygons where the Buffer touches again
leaflet(centroides) %>% 
  addTiles() %>% 
  addPolygons(data = buffdis, col = 'red') %>% 
  addCircles()

gt <- gIntersects(buffdis, byid = TRUE, returnDense = FALSE)

ut <- unique(gt); nth <- 1:length(ut)

buffdis <- SpatialPolygonsDataFrame(buffdis, data.frame(row.names = names(buffdis), n = 1:length(buffdis)))

buffdis$nth <- NA

for(i in 1:length(ut)){
  x <- ut[[i]]; buffdis$nth[x] <- i}

buffdis <- gUnaryUnion(buffdis, buffdis$nth)

leaflet(centroides, options = leafletOptions(minZoom = 10, maxZoom = 18)) %>% 
  addTiles() %>% 
  addPolygons(data = buffdis, col = 'red') %>% 
  setMaxBounds(lng1 = -3.903, lat1 = 40.216, lng2 = -3.303, lat2 = 40.816 ) %>%
  addCircles()


## CALCULATE DISTANCE ##
# Exctracting Longitude and Latitude from Leaflet centroides
# Convert to DataFrame
centroides_LongLat <- as.data.frame(centroides)
# Preview Coordinates
head(centroides_LongLat)

# Other Longitude and Latitude (locations)
data_LongLat <- data.frame(longitude = c(-3.30322, -3.30373), 
                           latitude = c(40.21689, 40.21669))  # Other Locations
# Preview Coordinates
head(data_LongLat)

# Add new columns
data_LongLat$distancia_km <- NA
data_LongLat$x <- NA
data_LongLat$y <- NA
### START FOR LOOP ###
for(i in 1:nrow(data_LongLat)) {
  # Distance
  Dist <- distm(centroides_LongLat,  # ALL buildings from OpenStreetMap
                data_LongLat[i,1:2],  # Other Locations
                fun = distCosine) / 1000  # 'Law Of Cosines' Great Circle Distance
  # Output = kilometers (km)
  Dist <- apply(Dist,  # variable
                1,  # 1 = Row / 2 = Columns
                min)  # function
  # Find closest places/locations to Other Locations
  min_number <- which.min(Dist) # which(Dist == min(Dist))
  min_number_value <- centroides_LongLat[min_number,]
  # Add values to DataFrame (unite)
  data_LongLat[i,4] <- min_number_value[1,1]
  data_LongLat[i,5] <- min_number_value[1,2]
  data_LongLat$distancia_km[i] <- min(Dist)
}
### END FOR LOOP ###
# Preview closest centroides to Other Locations and their distance to them
head(data_LongLat)

