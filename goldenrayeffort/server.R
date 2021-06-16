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


server <- function(input, output) {
    
db_config <- config::get("dataconnection")
con <- dbPool(
  drv = MariaDB(),
  dbname = db_config$dbname,
  host = db_config$host,
  username = db_config$username,
  password = db_config$password
)

#THIS IS IMPORTANT!!
#Config has its own merge() which conflicts with base R
#detach('package:config')

# As a safeguard against SQL injection, all queries will be through R base or data.table 
id <- dbGetQuery(con, 'SELECT * FROM trialID')
catch <- dbGetQuery(con, 'SELECT * FROM catchData') 
towtrack <- dbGetQuery(con, 'SELECT * FROM towTrackData') 
dfeffort <- dbGetQuery(con, 'SELECT * FROM effortData') 
catch$Species[catch$Species=='Monks of Anglers'] <- 'Monkfish/Anglers'

    
track2 <- subset(track, Asset=='GoldenRay')
greffort <- subset(dfeffort, Asset=='GoldenRay')
towtrack2 <- subset(towtrack, Asset=='GoldenRay')
towtrack2 <- merge(greffort, towtrack2)
towtrack2 <- towtrack2[c("Asset", "SampleID", "StartDate", "Date", "Latitude", "Longitude")]

dfnephrops <- subset(dfcatch, dfcatch$Species %in% c('Nephrops', 'Nephrops Tails') & Asset=='GoldenRay')
dfnephrops <- aggregate(RetainedWeight ~ Asset + SampleID, sum, data=dfnephrops)
dfnephrops <- merge(dfnephrops, dfeffort)
dfnephrops$NephropsCPUE <- dfnephrops$RetainedWeight/dfnephrops$TowTimeHours
dfnephrops <- dfnephrops[c("Asset", "SampleID", "NephropsCPUE", "RetainedWeight", "TowTimeHours")]

combdat <- merge(towtrack2, dfnephrops, by=c("Asset", "SampleID"))
combdat <- combdat[order(combdat$Date),] 
    
    
pal <- colorNumeric(
  palette = "Reds",
  domain = combdat$NephropsCPUE)

                    
output$map <- renderLeaflet({
#    maptow <- reactive({
#    subset(combdat, Date >= as.Date(input$dateRange[1]) & Date <= as.Date(input$dateRange[2]))
#    })
             maptest <- leaflet(combdat)
             maptest <- addProviderTiles(maptest, providers$Esri.OceanBasemap,
             options = providerTileOptions(minZoom=5, maxZoom=13))
#      maptest <- addProviderTiles(maptest, providers$OpenStreetMap.Mapnik)
      #maptest <- addMarkers(maptest, lng = ~Lng,
      #                        lat = ~Lat)
             maptest <- addCircleMarkers(maptest, lng = ~Longitude,
                           lat = ~Latitude,
                           color = ~pal(NephropsCPUE))
             maptest <-  addLegend(maptest, 
                       data = combdat,
                       pal = pal,
                       values = combdat$NephropsCPUE,
                       position = "bottomleft",
                       title = "Nephrops CPUE (kg/hour)",
                     opacity = 0.9
                     )
            maptest
           })

    
observeEvent(input$newdates, {
    maptow <- subset(combdat, Date >= as.Date(input$dateRange[1]) & Date <= as.Date(input$dateRange[2]))
    leafletProxy("map") %>%
      clearMarkers() %>%
      clearControls() %>%
      addCircleMarkers(lng = maptow$Longitude,
                       lat = maptow$Latitude,
                       color = pal(maptow$NephropsCPUE)) %>%
      addLegend(      data = maptow,
                       pal = pal,
                       values = maptow$NephropsCPUE,
                       position = "bottomleft",
                       title = "Nephrops CPUE (kg/hour)",
                     opacity = 0.9
                     )
         })
 
    
    
    
 }



