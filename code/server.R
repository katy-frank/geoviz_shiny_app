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

marten_range <- st_read("www/AmericanMarten_Range/mAMMAx_CONUS_Range_2001v1/mAMMAx_CONUS_Range_2001v1.shp")
marten_range <- st_transform(marten_range, 4326)

fisher_range <- st_read("www/Fisher_Range/mFISHx_CONUS_Range_2001v1/mFISHx_CONUS_Range_2001v1.shp")
fisher_range <- st_transform(fisher_range, 4326)

################
# SERVER LOGIC #
################

shinyServer(function(input, output) {
    output$speciesMap <- renderLeaflet({
        
        if(input$speciesCombo == "am"){
            data_source <- marten_range
            color_id <- 2
        }
        if(input$speciesCombo == "fisher"){
            data_source <- fisher_range
            color_id <- 4
        }
        
        pal <- colorNumeric(palette = "viridis", 0:10)
        
        leaflet(data_source) %>% setView(lng = -86,	lat = 45, zoom =6) %>% addTiles() %>%
            addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                        fillColor = ~pal(color_id)) 
    })
})