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

ui <- shinyUI(navbarPage("Draft boat dashboard: Golden Ray",
                       
    tabPanel("One type of interactive tide display",
          sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          tags$h3("Catch and tides"),        
          tags$p("This is an experimental data display. The coloured bars are the individual hauls, with the 
                  length representing the duration of the haul, and the colour representing Nephrops CPUE." ),
          tags$p("The tides are represented in the wavy line in the top of the graphs. These are NOT the actual 
                  tides! They are a placeholder until I obtain and manually enter the tide series. The final 
                  presentation will have a selection of tide stations to choose from, depending on where 
                  the hauls were taken." ),
          tags$p("In this graph, you can zoom up closer by using the slider to select the date-time range. In the display 
                  on the next page, I use a different interactive graph approach."),  
          tags$p("When I get the 'real' tide data, I will plot CPUE with tide phase. This may or may not work well, 
                  because each haul covers half a tide cycle in itself."),   
          tags$br(),
          tags$br(),
          tags$h4("Change the slider values to 'zoom' the x-axis range" ),
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
          tags$h3("Catch and tides (second version)"),        
          tags$p("This is a variation on the graph on the previous page examining tide and catch." ),
          tags$p("As with the previous graph, the (placeholder) tide is represented in the wavy line at 
the top of the graphs." ),
          tags$p("In this graph, you zoom up closer by clicking and selecting sections of the graph. There are a 
series of tools at the top of the graph to let you pan, and generally move around the graph."),  
          tags$p("Hover over the point to get a bit more detail about its value." ),
          tags$p("Double click to return to the original view."),   
          tags$br(),
          tags$br(),
         ),
             
          mainPanel(tags$h1("Nephrops CPUE", align = "center"),
          shinycssloaders::withSpinner(
          plotlyOutput(outputId = "plot2", height='600px'))                    
          )
          ),
                         
    tabPanel("Fish and Nephrops catch with and without lights",
          sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          tags$h3("Finfish species"),
          tags$p("We are still in the early stages of examining light effects. There is a lot of variation 
                 in time and space, and we do not have many combinations of colour, flash and so on yet."),
          tags$p("The size frequency distributions are raw counts, not standardised to CPUE. The shape of the
                 patterns will be comparable though. Only Haddock and Whiting were abundant enough for size comparisons."),
          tags$p("One important thing to note is that encountering large groups of young Haddock and Whiting
                  was patchy. For most hauls there were very few individuals. It is probably a matter of luck
                  whether the lights were on or off and whether a school of young fish was
                  encountered on the haul."),
          tags$br(),
          tags$br(),
          selectInput("splength", "Species:",
            c("Haddock" = "Haddock",
              "Whiting" = "Whiting"),
             selected='Haddock'),
          tags$br(),
          tags$br(),
          tags$h3("Nephrops"),
          tags$p("The Nephrops values are expressed in kg/hour. The tow durations are derived from the Followmee app. 
                  From the track it is possible to see when the net goes in and comes out. Each point is a haul,
                  and if you hover over the point you can read the value."),
         tags$p("The presentation is a 'violin' plot. It tries to show where the main density of points lie. 
                As with the fish lengths above, it is too early to determine if there is any effect of lights.
                There were a few very good catches that just happened to be with lights off")
            ),
             
          mainPanel(tags$h1("Fish length frequencies with and without light", align = "center"),
          shinycssloaders::withSpinner(
          plotOutput(outputId = "lengthplot", height='600px')),
          plotlyOutput(outputId="sumPlot", height = "600px", width="100%")
          )
          ),

#    tabPanel("Interactive fish length plot",
#          sidebarPanel(
#          tags$img(src="safetynet_logo.png",
#  #       img(src="safetynet_logo.png",
#          title="SafetyNet Technologies",
#          width="230",
#          height="70"),
#          tags$h3("Select species"),
#          tags$p("This is the plotly() interactive version of previous page."),

#          tags$br(),
#          tags$br(),
#          selectInput("splength", "Species:",
#            c("Haddock" = "Haddock",
#              "Whiting" = "Whiting"),
#             selected='Haddock'),
#          tags$br(),
#          tags$br(),
#         ),
             
#          mainPanel(tags$h1("Fish length frequencies with and without light", align = "center"),
#          shinycssloaders::withSpinner(
#          plotlyOutput(outputId = "lengthplotly", height='600px'))                
#          )
#          ),
   
 
                       
    tabPanel("Vessel fishing track",
          sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          tags$h3("Tow tracks and Nephrops CPUE"),
          tags$p("This map presents all of the haul tracks. These are derived from the Followmee App, with the net in/out 
          times determined manually from the track/speed. Symbols are coded to the Nephrops CPUE for that haul. Each symbol 
          is a position fix from Followmee, so you can see there are occasional gaps where the iPad has lost GPS signal." ),
          tags$p("To zoom up on the map, use the the +/- buttons or (if using a mouse) the wheel. You can click/hold 
          and pan around the map. To zoom in on a date range, use the slider."),                  
          tags$br(),
          tags$br(),
          tags$p("This display is under development. I will be adding more interaction and information to provide more information 
          to help interpret differences in CPUE in space and time."),
          tags$br(),
          tags$br(),
            dateRangeInput(inputId = 'dateRange',
            label = 'Date range input: yyyy-mm-dd',
            start = "2021-05-01",
            end   = "2021-07-31"
          ),
         actionButton("newdates", "Redraw map"),
         tags$h4("After selecting the new dates, click the button to 'Redraw' the map.")
        
         ),
          mainPanel(tags$h1("Nephrops CPUE", align = "center"),
          shinycssloaders::withSpinner(
          leafletOutput(outputId = "map", height='600px'))
                    
                               )

#Close main panel
             
            
 )
)
)
                      
 
