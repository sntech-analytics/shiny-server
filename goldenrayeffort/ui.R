library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
library(suncalc)
library(shinycssloaders)
library(lubridate)
library(ggplot2)
library(plotly)
library(data.table)
library(RMariaDB)
library(config)
library(pool)
library(magrittr)


ui <- shinyUI(navbarPage("Draft boat dashboard: Golden Ray",
                       
    tabPanel("About...",
                tags$h2("About this interface", align = "center"),
                               tags$p("This page will have a blurb and some instructions"),
                               tags$br(),
                               tags$p("We could have a summary table of days fished, Pisces on-off and so on"),
                               ),
 
                       
    tabPanel("Vessel fishing track",
          sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          tags$h3("Select dates"),
          tags$p("After selecting the new dates, 'Redraw' the map" ),
          tags$br(),
          tags$br(),
             dateRangeInput(inputId = 'dateRange',
            label = 'Date range input: yyyy-mm-dd',
            start = "2021-04-01",
            end   = "2021-08-31"
          ),
         actionButton("newdates", "Redraw map")
        
         ),
          mainPanel(tags$h1("Nephrops CPUE", align = "center"),
          shinycssloaders::withSpinner(
          leafletOutput(outputId = "map", height='600px'))
                    
                               )

#Close main panel
             
            
 )
)
)

