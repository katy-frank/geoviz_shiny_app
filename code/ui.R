######################################
# EAS 501.19 Final Project           #
# by Kaitlyn Frank and Ethan Hiltner #
# ui.R file                          #
######################################

library(leaflet)
library(shinydashboard)
library(shinycssloaders)

###########
# LOAD UI #
###########

shinyUI(fluidPage(
    
    # load custom stylesheet
    includeCSS("www/style.css"),
    
    # remove shiny "red" warning messages on GUI - fragment borrowed from: https://github.com/abenedetti/bioNPS/
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    # load page layout
    dashboardPage(
        
        skin = "blue",
        
        dashboardHeader(title="Final Project TBD", titleWidth = 300),
        
        dashboardSidebar(width = 300,
            sidebarMenu(
                menuItem("Home", tabName = "home", icon = icon("home")),
                menuItem("Species Map", tabName = "map", icon = icon("map marked alt"))
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
                            column(3, uiOutput("speciesSelectCombo")),
                        ),
                        fluidRow(
                            column(9,leafletOutput("speciesMap") %>% withSpinner(color = "blue"))
                        )
                )
            )
        )
    )
))