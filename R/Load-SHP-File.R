## LOAD SHP FILES ##
# Load library
if(!require('rgdal')){
  install.packages('rgdal')
  library('rgdal')
}

# Set the Working Directory to the folder where the Provincias_ETRS89_30N.ZIP has been unzipped
#setwd("YOUR_FILE_PATH")
# Read the SHP file
Poligonos <- readOGR(dsn = 'Provincias_ETRS89_30N', 'Provincias_ETRS89_30N')

# Visualize the SHP file
par(mfrow = c(1, 2))
plot(Poligonos, main='Poligonos')
# View the Coordinate Reference System (CRS) that the SHP file uses
Poligonos@proj4string

# Change the CRS to the WGS84 system, which is used by Google
Poligonos_WGS84 <- spTransform(Poligonos, CRS('+proj=longlat +datum=WGS84'))
# More info: https://en.wikipedia.org/wiki/World_Geodetic_System
# Visualize
plot(Poligonos_WGS84,main='Poligonos_WGS84')
