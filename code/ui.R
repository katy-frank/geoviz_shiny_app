######################################
# EAS 501.19 Final Project           #
# by Kaitlyn Frank and Ethan Hiltner #
# ui.R file                          #
######################################

library(leaflet)
library(shinydashboard)
library(shinycssloaders)
library(dplyr)
library(sf)
library(leaflet.extras)
library(ggplot2)

###########
# LOAD UI #
###########

shinyUI(fluidPage(
    # load page layout
    dashboardPage(
        skin = "blue",
        dashboardHeader(title="Endangered Wildlife of Michigan", titleWidth = 300),
        dashboardSidebar(width = 300,
            sidebarMenu(
                menuItem("Home", tabName = "home", icon = icon("home")),
                menuItem("Species Map", tabName = "map", icon = icon("map marked alt")),
                menuItem("Sources", tabName = "sources", icon = icon("tasks"))
            )
        ),
        
        dashboardBody(
            tabItems(
                tabItem(tabName = "home",
                    # home section
                    includeMarkdown("www/home.md")
                ),
                tabItem(tabName = "map",
                    # species map section
                    includeMarkdown("www/speciesmap.md"),
                    fluidRow(
                        column(1), # for spacing
                        column(5, selectInput("speciesCombo",
                                              "Select species to view:", 
                                              c("All", 
                                                "Canada Lynx",
                                                "Gray Wolf",
                                                "Indiana Myotis",
                                                "Kirtland's Warbler",
                                                "Eastern Massasauga Rattlesnake",
                                                "Northern Myotis",
                                                "Piping Plover",
                                                "Spotted Turtle"),
                                              multiple = FALSE,
                                              selected="All"
                        ))
                    ),
                    fluidRow(
                        column(12,leafletOutput("speciesMap", width = "100%", height = 500) %>% withSpinner(color = "blue"))
                    ),
                    fluidRow(
                        column(12, uiOutput("speciesImage", width = "100%", height = 500) %>% withSpinner(color = "blue"))
                    )
                ),
                tabItem(tabName = "sources",
                        #data sources
                        includeMarkdown("www/sources.md")
                )
            )
        )
    )
))