library(shiny)
library(shinydashboard)
library(shinyalert)
library(ggplot2)
library(DT)
library(htmltools)
library(shinycssloaders)
library(shinyWidgets)
library(data.table)
library(lubridate)
library(scales)
library(ssh)
library(jpeg)
library(base64enc)
library(leaflet)
library(raster)
library(rnaturalearth)
library(sf)

ui <- navbarPage("Catch and prediction",
  tabPanel("Plot",
    sidebarLayout(
      sidebarPanel(
        selectInput("Species", "Species",
                    c("Sailfish" = "Sailfish",
                      "Bigeye tuna" = "BigeyeTuna")
                   ),
        selectInput("Gear", "Gear",
                    c("Longline" = "Longline",
                      "Gillnet" = "Gillnet")
                    ),
          sliderInput("animation", "Looping Animation:",
                  min = 1, max = 53,
                  value = 1, step = 1,
                  animate = animationOptions(interval = 3000, loop = TRUE)
                     ),
      ),
        
      mainPanel(
        shinycssloaders::withSpinner(
        leafletOutput("map", height="100vh")
        )
      )
    )
  )
)




