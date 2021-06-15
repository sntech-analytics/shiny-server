library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
library(ggplot2)
library(plotly)
library(data.table)

track <- readRDS(file='track.rds')
df <- readRDS(file='CatchApp.rds')
server = function(input, output) {

# Leaflet map
output$map = renderLeaflet({
      maptest <- leaflet(track)
      maptest <- addProviderTiles(maptest, providers$Esri.OceanBasemap,
            options = providerTileOptions(minZoom=5, maxZoom=20))
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

  
# output$testplot <- renderPlot({
output$sumPlot <- renderPlotly({
      a <- ggplot(data = df) +
       theme_classic() +
        geom_hline(yintercept=0) +
        scale_color_manual(values = c('black', 'blue', 'green')) +
   #     labs(fill="Pisces status") +
        geom_violin(data = df, aes(x=Species, y=Retained.weight, fill=Bait)) +
        geom_violin(data = df, aes(x=Species, y=Returned.Weight, fill=Bait)) +
        
        geom_point(data = df, aes(x=Species, y=Retained.weight, group=Bait, color=Bait), position = position_dodge(1)) +
        geom_point(data = df, aes(x=Species, y=Returned.Weight, group=Bait, color=Bait), position = position_dodge(1)) +       
#        geom_boxplot(data = df, aes(x=Species, y=Retained.weight, fill=Bait)) +
#        geom_point(data = df, aes(x=Species, y=Retained.weight), size=1) +
#        geom_boxplot(data = df, aes(x=Species, y=Returned.Weight, fill=Bait)) +
#       geom_point(data = df, aes(x=Species, y=Returned.Weight), color='blue', size=1) +
#   labs(x ="First EO", y = "Time of Day") +
       theme(strip.text.x = element_text(size=12, face="bold"),
         strip.text.y = element_text(size=12, face="bold"),
         strip.background = element_blank()) +
      facet_wrap(~Group, scales='free')
      
      ggplotly(a)
      
   })      

output$viewTrack <- renderTable(track)

output$viewCatch <- renderTable(df)

          
}

