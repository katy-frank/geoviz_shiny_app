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

# read in land use data
developed <- raster("www/developed.tif")
developed <- projectRasterForLeaflet(developed, method = "ngb")

agriculture <- raster("www/agriculture.tif")
agriculture <- projectRasterForLeaflet(agriculture, method = "ngb")

disturbed <- raster("www/disturbed.tif")
disturbed <- projectRasterForLeaflet(disturbed, method = "ngb")

mi_border <- st_read("www/miborder/clip_mi.shp")

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
    output$speciesImage <- renderUI({
        html <- HTML(paste0("<br>")) # if no animal selected don't show any image
        
        if (length(input$speciesCombo) != 0){
            if(!("All" %in% input$speciesCombo)){
                selected <- species_metadata[which(species_metadata$name %in% input$speciesCombo),]
             
                html <- HTML(paste0(
                    "<a href='",
                    selected$wikilink,
                    "' target='_blank'><img style = 'display: block; margin-left: auto; margin-right: auto;' src='",
                    selected$imagefile,
                    ".jpg' width = '186'></a>",
                    "<br>",
                    includeMarkdown(paste0("www/speciesmarkdowns/",selected$markdown))
                ))  
            }
        }
        html
    })
    
    output$speciesMarkdown <- renderUI({
        if (length(input$speciesCombo) != 0){
            if(!("All" %in% input$speciesCombo)){
                selected <- species_metadata[which(species_metadata$name %in% input$speciesCombo),]
                includeMarkdown(paste0("www/speciesmarkdowns/",selected$markdown))
            }
        }
    })
    
    output$speciesMap <- renderLeaflet({
        #init colors
        pal <- colorNumeric(palette = "magma", 1:9)
        
        # init display
        display <- leaflet() %>% setView(lng = -86,	lat = 43, zoom = 5) %>%
            addTiles() %>% 
            addPolygons(data = mi_border, 
                        color = "#FF0000", weight = 1,opacity=1,
                        fillOpacity = 0)
        
        if (length(input$speciesCombo) != 0){
            for (i in 1:length(species_metadata[,1])) {
                # set visible if selected
               if ("All" %in% input$speciesCombo){
                   species_metadata[i,]$opacity <- 0.3
               } else if(species_metadata[i,]$name %in% input$speciesCombo) {
                    species_metadata[i,]$opacity <- 0.6
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
        
        # add in the land use rasters if selected
        if (length(input$checkGroup) != 0){
            if (1 %in% input$checkGroup) {
                display <- display %>% addRasterImage(agriculture, colors = c("transparent", "#FABC08"),opacity = 1,project=FALSE)
            }
            if (2 %in% input$checkGroup){
                display <- display %>% addRasterImage(developed, colors = c("transparent", "#838181"),opacity = 1,project=FALSE)
            }
            if (3 %in% input$checkGroup){
                display <- display %>% addRasterImage(disturbed, colors = c("transparent", "#FF0000"),opacity = 1, project=FALSE) 
            }
        }
        
        # return the leaflet display
        display <- display %>% addLegend(colors = c(pal(1), pal(2), pal(3), pal(4), pal(5), pal(6), pal(7), pal(8)),
                                         labels = species_metadata$name,
                                         position = "bottomleft",
                                         title="Species Range")
        
        display <- display %>% addLegend(colors = c("#FABC08","#838181","#FF0000"),
                      labels = c("Agriculture", "Developed", "Disturbed"),
                      position = "bottomright",
                      title = "Land Use Category")
        display
    })
})
