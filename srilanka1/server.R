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

server <- function(input, output) {

    load("preds.RDS")
    load("bigsail.RDS")



    predactive <- reactive({
        df <- subset(bigsail, Species == input$Species & Gear == input$Gear & week==input$animation)
        r <- rasterFromXYZ(cbind(df$lon, df$lat, df$weekmed))
        crs(r) <- CRS('+init=EPSG:4326')
        r
    })
    
    points <- reactive({
        df <- subset(preds, Species == input$Species & Gear == input$Gear & week==input$animation)
        df <- st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
        df
    })
 
    cont <- reactive({
        df <- subset(bigsail, Species == input$Species & Gear == input$Gear & week==input$animation)
        quant <- quantile(df$weekmed, probs = c(0.75, 0.95))
        r <- rasterFromXYZ(cbind(df$lon, df$lat, df$weekmed))
        r <- rasterToContour(r, levels=c(quant))
        crs(r) <- CRS('+init=EPSG:4326')
     #   df <- st_as_sf(r, coords = c("lon", "lat"), crs = 4326)
        r
    })
    
   
    output$map <- renderLeaflet({
        preddf <- predactive()
        pointdf <- points()
        cont <- cont()
        basemap <- leaflet()
 #       basemap <- addProviderTiles(basemap, providers$Esri.OceanBasemap,
 #                           options = providerTileOptions(minZoom=4, maxZoom=13),
 #                           setView(5.5, 77, zoom = 4))
   #     basemap <- addTiles(basemap)
  #         basemap <- addProviderTiles(basemap, providers$USGS.USImagery)
#        basemap <- addProviderTiles(basemap, providers$Esri.OceanBasemap,
         basemap <- addProviderTiles(basemap, providers$Esri.WorldImagery,
  #       basemap <- addProviderTiles(basemap, providers$Esri.WorldPhysical,
 #        basemap <- addProviderTiles(basemap, providers$Esri.NatGeoWorldMap,
                  options = providerTileOptions(minZoom=1, maxZoom=18, noWrap = FALSE))
#                  options = providerTileOptions(maxNativeZoom=19, maxZoom=100, noWrap = TRUE))                  
                  
                  
        basemap <- addRasterImage(basemap, preddf, colors = rev(heat.colors(15)), opacity = .5)
        basemap <- addCircles(basemap, data=pointdf,
                      radius = ~(weekmedwt**10),
                      color = 'black',
                      fillColor = "black",
                      fillOpacity = 0.6,
                      popup = ~as.character(round(weekmedwt**10, 0)))
                      
        basemap <- addPolylines(basemap, data=cont,
                                color="black",
                                weight=2)
        basemap

    })
    
    }




