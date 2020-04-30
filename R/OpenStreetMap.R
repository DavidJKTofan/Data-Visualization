## OPENSTREETMAP ##
# Load libraries
if(!require(c('osmdata', 'rgdal', 'maptools', 'rgeos', 'leaflet'))){
  install.packages(c('osmdata', 'rgdal', 'maptools', 'rgeos', 'leaflet'))
  library(c('osmdata', 'rgdal', 'maptools', 'rgeos', 'leaflet'))
}

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

leaflet(centroides) %>% 
  addTiles() %>% 
  addPolygons(data = buffdis, col = 'red') %>% 
  addCircles()

