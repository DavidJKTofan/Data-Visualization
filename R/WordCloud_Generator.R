# Source: https://cran.r-project.org/web/packages/ggwordcloud/vignettes/ggwordcloud.html

library(ggplot2)
library(ggwordcloud)

### INSERT DATA HERE ###
# Insert words here:
words = c('Echtzeit-Updates','Tracking und Berichtsfunktionen','Bessere Personalisierung von Kampagnen','Echtzeit-Analysen','Benutzerfreundliche Schnittstellen','Datensicherheit und -Integrität','Interaktive Dashboards','Schnelle Umsatzsteigerung','Mobile Nutzung','Verwaltung von Kontaktinformationen','24/7 Kundenbetreuung','Einfache Integration in bestehende Systeme','Bessere Servicequalität')
# Insert importance of each word before here:
score = c(8,8,8,8,5,5,5,5,3,3,3,3,3)
# Add title for the PNG file
title = "test"


# Create Data Frame
new_df = data.frame(words, points = score)

### Create Word Cloud ###
myplot <- ggplot(
  new_df,
  aes(
    label = words, 
    size = score,
    color = score, 
    family = "Montserrat", 
    fontface = "bold")) +
  geom_text_wordcloud_area(eccentricity = 0.9, rm_outside = TRUE) +
  scale_size_area(max_size = 10) +
  scale_color_gradient(low = "#F46B1B", high = "#003E7D") +
  theme_minimal()

## Save as PNG
#ggsave(myplot, filename = paste("wordcloud-", title, ".png", sep=""), device = "png", width = 40, height = 20, units = "cm", dpi = 300, bg = "transparent")

##  View
myplot
