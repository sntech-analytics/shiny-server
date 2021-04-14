library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)


track <- readRDS(file='track.rds')

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
                               leafletOutput(outputId = "map", height=600)
                               ),

   tabPanel("Catch summary plots",
 #                              uiOutput("Decompdepvarname"),
 #                              tags$h3("Seasonal decomposition of the time series"),
 #                              textOutput(outputId="decomptest"),
 #                              plotOutput(outputId="DecompPlot")
                               )
                      )



#Close main panel
           )
#Close fluidpage
)


server = function(input, output) {




# Leaflet map
output$map = renderLeaflet({
      maptest <- leaflet(track)
      maptest <- addProviderTiles(maptest, providers$Esri.OceanBasemap,
            options = providerTileOptions(minZoom=5, maxZoom=18))
#      maptest <- addProviderTiles(maptest, providers$OpenStreetMap.Mapnik)
      #maptest <- addMarkers(maptest, lng = ~Lng,
      #                        lat = ~Lat)
      maptest <- addCircleMarkers(maptest, lng = ~Lng,
                           lat = ~Lat,
#                           color = ~pal(Speed.km.h.),
 #                          opacity=1,
                           label = ~htmlEscape(track$Speed.mph.))
      maptest <- addPolylines(maptest, lng = ~Lng,
                        lat = ~Lat)
      
      
 #     maptest <- addProviderTiles(maptest, providers$Esri.OceanBasemap)
      #maptest <- addProviderTiles(maptest, providers$OpenStreetMap.Mapnik)
 #     maptest <- addCircleMarkers(maptest, lng = ~Lng,
 #                       lat = ~Lat,
 #                       opacity=1,
 #                       label = ~htmlEscape(track$ID))
 #     maptest <- addPolylines(maptest, lng = ~Lng,
 #                       lat = ~Lat)
      })
      
      
      
      
}

shinyApp(ui=ui, server=server)



