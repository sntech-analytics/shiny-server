library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
library(suncalc)
library(shinycssloaders)
library(lubridate)
library(ggplot2)
library(ggpubr)
library(plotly)
library(data.table)
library(RMariaDB)
library(config)
library(pool)
library(scales)
library(magrittr)

ui <- fluidPage(
    titlePanel("Draft boat dashboard: Golden Ray"),
    
    sidebarLayout(
    sidebarPanel(        
           tags$img(src="safetynet_logo.png",
           title="SafetyNet Technologies",
           width="230",
           height="70"),
           tags$h3("Nephrops catch per unit effort", align = "center"),
           tags$p("One page version"),
           tags$br(),
           tags$br(),
           tags$br(),
             dateRangeInput(inputId = 'dateRange',
            label = 'To change the map, input a date (yyyy-mm-dd)',
            start = "2021-05-01",
            end   = "2021-08-31"
          ),
         actionButton("newdates", "Redraw map")
          ),
                       
         mainPanel(
              tags$h2("Nephrops catch per unit effort", align = "center"),
                       tags$p("Does a one page dashboard make sense?"),
                       tags$br(),
        fluidRow(
          column(5,
           shinycssloaders::withSpinner(
#              plotlyOutput(outputId = "cpue"))
              plotOutput(outputId = "cpue"))
               ),
            
           column(7,
            shinycssloaders::withSpinner(
              leafletOutput(outputId = "map"))
           )
        )
          
        )
)
)

   
