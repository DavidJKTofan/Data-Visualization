## LOAD SHP SHAPE FILES ##
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
packages <- c('rgdal' # Projection/Transformation operations 
)
prepare_packages(packages)

# Download, load and unzip the Shape File
# ShapeFile URL
url <- 'https://github.com/DavidJKTofan/Data-Visualization/blob/master/R/Provincias_ETRS89_30N.zip?raw=true'
# Create a temporary directory
td <- tempdir()
# Create the placeholder file
tf <- tempfile(tmpdir=td, fileext=".zip")
# Download into the placeholder file
download.file(url, tf)
# Unzip the file to the temporary directory
unzip(tf, exdir=td, overwrite=TRUE)
# fpath is the full path to the extracted file
fpath = file.path(td)
fpath <- paste(fpath, "Provincias_ETRS89_30N", sep="/") # Add Folder Name
fpath <- gsub(fpath, pattern="//", replacement="/", fixed=TRUE) # In case there is double slash /

# Load Postal / ZIP codes
Polygons <- readOGR(dsn = fpath,
                       layer = 'Provincias_ETRS89_30N')

# Prepare plot area
par(mfrow = c(1, 2))
# Visualize the SHP file
plot(Polygons, 
     main = 'Polygons')
# View the Coordinate Reference System (CRS) that the SHP file uses
Polygons@proj4string

# Change the CRS to the WGS84 system, which is used by Google
Polygons_WGS84 <- spTransform(Polygons, CRS('+proj=longlat +datum=WGS84'))
# More info: https://en.wikipedia.org/wiki/World_Geodetic_System
# Visualize
plot(Polygons_WGS84,
     main = 'Polygons_WGS84')
