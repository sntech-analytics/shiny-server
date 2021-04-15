library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
library(ggplot2)
library(plotly)
library(data.table)

track <- readRDS(file='track.rds')
df <- readRDS(file='CatchApp.rds')

#pal <- colorQuantile(
#  palette = "Reds",
#  domain = track$Speed.km.h.)



ui<-fluidPage(

titlePanel(title="MFV Virtuous data dashboard"),

mainPanel(
                                 tags$img(src="safetynet_logo.png",
  #                                 img(src="safetynet_logo.png",
                                  title="SafetyNet Technologies",
                                  width="230",
                                  height="70"),

   tabsetPanel(type="tab",

     tabPanel("About...",
             tags$h2("About this interface", align = "center"),
             HTML("<h4>Author: Craig Syms</h4> <h5><a href='https://sntech.co.uk'>SafetyNet Technologies</a></h5>"),
                               tags$p("This is a developmental dashboard which aims to display data collected during Pisces trials. The mapping data 
                                      are available only to the vessel concerned (in this case, MFV Virtuous), and are included primarily so we and the Skipper can 
                                      get a feel for where things might have worked or not worked, and where in the ocean important or unusual events may have occurred."),
                               tags$br(),
                               tags$p("As we get more data, we will build on the information displays and make it prettier!")
                               ),
          
   tabPanel("Vessel track",
           tags$h2("MFV Virtuous track", align = "center"),
           tags$h5("1. Hover over the icon to get Speed Over Ground (mph). As we get sample data, we will project the sample locations on the map."), 
 #          tags$h5("2. The symbols colours are scaled to Speed over ground (SOG). Red is faster."), 
                               leafletOutput(outputId = "map", height='600px')
                               ),
                               
   tabPanel("Catch summary plots",
                         tags$p("Work in progress. The top (positive part greater than zero) is the retained catch, the negative values (blue dots) are returned catch"),
                         tags$p("When we get samples with lights, these will be placed side by side with the non-lighted shots."),
                         tags$p("This is an interactive graph. You can highlight points, zoom in and zoom out on it."),
                         tags$p("We only have a handful of samples at the moment, so the boxplot elements are misleading. As we get more, the data points will fill it 
                         out and we will begin to get a better feel of how the sample numbers are capturing the patterns."),
                               plotlyOutput(outputId="sumPlot", height = "600px", width="100%")

                               ),
 
   tabPanel("Catch data",
           tableOutput(outputId="viewCatch")
            ),
            
                               
   tabPanel("Track data",
           tableOutput(outputId="viewTrack")
            )                               
      )



#Close main panel
           )
#Close fluidpage
)

