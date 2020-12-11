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
        pal <- colorNumeric(palette = "viridis", 0:10)
        
        if(input$speciesCombo == "am"){
            marten_factor <- 0.5
            fisher_factor <- 0
        }
        
        if(input$speciesCombo == "fisher"){
            marten_factor <- 0
            fisher_factor <- 0.5 
        }
       
        if(input$speciesCombo == "all"){
            marten_factor <- 0.5
            fisher_factor <- 0.5
        }
        
        leaflet() %>% setView(lng = -86,	lat = 45, zoom = 5) %>% addTiles() %>%
            addPolygons(data = marten_range, stroke = FALSE, smoothFactor = 0.3, fillOpacity = marten_factor,
                        fillColor = ~pal(2)) %>% 
            addPolygons(data = fisher_range, stroke = FALSE, smoothFactor = 0.3, fillOpacity = fisher_factor,
                        fillColor = ~pal(9)) 
    })
})