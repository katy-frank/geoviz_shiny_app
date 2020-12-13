######################################
# EAS 501.19 Final Project           #
# by Kaitlyn Frank and Ethan Hiltner #
# ui.R file                          #
######################################

library(shiny)
library(tidyverse)
library(leaflet.extras)
library(rvest)
library(rgdal)
##################
# Data Processing #
##################
#species metadata
species_metadata <- read.csv("www/species_metadata.csv")
species_metadata <- data.frame(species_metadata)

# read in endangered/threatened species data
canada_lynx <- st_read("www/rangedata/canada_lynx/canada_lynx/canada_lynx.shp")
gray_wolf <- st_read("www/rangedata/gray_wolf/gray_wolf/gray_wolf.shp") 
indiana_myotis <- st_read("www/rangedata/indiana_myotis/indiana_myotis/indiana_myotis.shp") 
kirtlands_warbler <- st_read("www/rangedata/kirtlands_warbler/kirtlands_warbler/kirtlands_warbler.shp")
massasauga <- st_read("www/rangedata/massasauga/massasauga/massasauga.shp")
northern_myotis <- st_read("www/rangedata/northern_myotis/northern_myotis/northern_myotis.shp")
piping_plover <- st_read("www/rangedata/piping_plover/piping_plover/piping_plover.shp")
spotted_turtle <- st_read("www/rangedata/spotted_turtle/spotted_turtle/spotted_turtle.shp")

#aggregate them
range_data <- list(
    "canada_lynx" = canada_lynx, 
    "gray_wolf" = gray_wolf, 
    "indiana_myotis" = indiana_myotis, 
    "kirtlands_warbler" = kirtlands_warbler, 
    "massasauga" = massasauga, 
    "northern_myotis" = northern_myotis, 
    "piping_plover" = piping_plover, 
    "spotted_turtle" = spotted_turtle)

# put them in the same projection, add info
for (i in 1:length(range_data)) {
    range_data[[i]] <- st_transform(range_data[[i]], 4326)
}

################
# SERVER LOGIC #
################

shinyServer(function(input, output) {
    output$speciesMap <- renderLeaflet({
        #init colors
        pal <- colorNumeric(palette = "magma", 1:9)

        # init display
        display <- leaflet() %>% setView(lng = -86,	lat = 45, zoom = 5) %>% addTiles()
        if (length(input$speciesCombo) != 0){
            for (i in 1:length(species_metadata[,1])) {
                # set visible if selected
               if ("All" %in% input$speciesCombo){
                   species_metadata[i,]$opacity <- 0.3
               } else if(species_metadata[i,]$name %in% input$speciesCombo) {
                    species_metadata[i,]$opacity <- 0.5
                }else {
                    species_metadata[i,]$opacity <- 0
                }
                
                # add to the leaflet display
                uniqid <- species_metadata[i,]$uniqid
                display <- display %>% addPolygons(data = range_data[[uniqid]], #uniqid must match position in range_data list because of this hack so watch out if you add more species 
                                                   stroke = FALSE, 
                                                   smoothFactor = 0.3, 
                                                   fillOpacity = species_metadata[i,]$opacity,
                                                   fillColor = ~pal(species_metadata[i,]$uniqid))
            }
        }
        # return the leaflet display
        display
    })
})