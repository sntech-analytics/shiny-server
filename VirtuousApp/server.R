library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
track <- readRDS(file='track.rds')
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

output$viewData <- renderTable(track)
           
}

