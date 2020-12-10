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
################
# SERVER LOGIC #
################

shinyServer(function(input, output) {
    # species map
    output$speciesSelectCombo <- renderUI({
        selectInput("speciesCombo","Select a species:", c("American Marten" = "am"))
    })
    
    output$speciesMap <- renderLeaflet({
        pal <- colorNumeric(c("red", "green", "blue"), 0:10)
        leaflet(marten_range) %>% addTiles() %>%
            addTiles() %>%
            addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                        fillColor = ~pal(1)) 
    })
})