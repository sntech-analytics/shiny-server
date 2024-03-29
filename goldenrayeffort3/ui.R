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

ui <- shinyUI(navbarPage("Draft boat dashboard: Golden Ray",
                       
    tabPanel("One type of interactive tide display",
          sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          tags$h3("Select dates"),
          tags$p("Changing the slider values will 'zoom' the x-axis range" ),
          tags$p("The colour scheme in the top graph is the same as the map, but we lose the low values." ),
          tags$br(),
          tags$br(),
          uiOutput("slider"),
          tags$br(),
          tags$br(),
         ),
             
          mainPanel(tags$h1("Nephrops CPUE", align = "center"),
          shinycssloaders::withSpinner(
          plotOutput(outputId = "plot1", height='600px'))                
          )
          ),

    tabPanel("Another type of interactive tide display",
          sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          tags$h3("This plot is an interactive graph"),
          tags$p("Select the area of the graph to zoom up on the date range" ),
          tags$p("There are a set of controls on the top right of the graph, which enable you to reset axes."),
          tags$br(),
          tags$br(),
         ),
             
          mainPanel(tags$h1("Nephrops CPUE", align = "center"),
          shinycssloaders::withSpinner(
          plotlyOutput(outputId = "plot2", height='600px'))                    
          )
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
            start = "2021-05-01",
            end   = "2021-07-31"
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
                      
 
