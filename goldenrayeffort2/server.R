                           
server <- function(input, output) {
 
library(config)   
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
detach('package:config')

# As a safeguard against SQL injection, all queries will be through R base or data.table 
id <- dbGetQuery(con, 'SELECT * FROM trialID')
catch <- dbGetQuery(con, 'SELECT * FROM catchData') 
towtrack <- dbGetQuery(con, 'SELECT * FROM towTrackData') 
dfeffort <- dbGetQuery(con, 'SELECT * FROM effortData') 
catch$Species[catch$Species=='Monks of Anglers'] <- 'Monkfish/Anglers'
dfcatch <- merge(catch, id, by='SampleID')
    
greffort <- subset(dfeffort, Asset=='GoldenRay')
towtrack2 <- subset(towtrack, Asset=='GoldenRay')
towtrack2 <- merge(greffort, towtrack2)
towtrack2 <- towtrack2[c("Asset", "SampleID", "StartDate", "Date", "Latitude", "Longitude")]

dfnephrops <- subset(dfcatch, dfcatch$Species %in% c('Nephrops', 'Nephrops Tails') & dfcatch$Asset=='GoldenRay')
dfnephrops <- aggregate(RetainedWeight ~ Asset + SampleID + StartDateDT, sum, data=dfnephrops)
dfnephrops <- merge(dfnephrops, dfeffort)
dfnephrops$NephropsCPUE <- dfnephrops$RetainedWeight/dfnephrops$TowTimeHours
dfnephrops <- dfnephrops[c("Asset", "SampleID", "StartDateDT", "NephropsCPUE", "RetainedWeight", "TowTimeHours")]

combdat <- merge(towtrack2, dfnephrops, by=c("Asset", "SampleID"))
combdat <- combdat[order(combdat$Date),] 

#For suncalc
mindate <- min(dfnephrops$StartDateDT) - 15
maxdate <- max(dfnephrops$StartDateDT) + 15
medlat <- median(combdat$Latitude)
medlong <- median(combdat$Longitude)
moon <- getMoonIllumination(
        date = seq.Date(mindate, maxdate, by = 1)) 
    
pal <- colorNumeric(
  palette = "Reds",
  domain = combdat$NephropsCPUE)

    
#output$cpue<-renderPlotly({   
output$cpue<-renderPlot({  
    a <- ggplot(data=moon, aes(x=date, y=fraction)) +
       theme_classic() +
       ggtitle("Moon phase") +
       labs(x = "Date", 
            y = "Moon brightness") +
       geom_line() +
       scale_x_date(limits=c(mindate, maxdate)) +
       theme(plot.title = element_text(face='bold', hjust=0.5),
             axis.title.y  = element_text(face='bold'),
             axis.title.x  = element_blank()
        )


    b <- ggplot(data=dfnephrops, aes(x=StartDateDT, y=NephropsCPUE, group=SampleID)) +
       theme_classic() +
       ggtitle("Nephrops CPUE") +
       labs(x = "Date", 
            y = "CPUE (kg/hour)") +
       geom_bar(stat="identity", position='dodge', color='grey50') +
       scale_x_date(limits=c(mindate, maxdate)) +
       theme(legend.position = "none") +
       theme(plot.title = element_text(face='bold', hjust=0.5),
             axis.title.y  = element_text(face='bold'),
             axis.title.x  = element_blank()
        )
    ggarrange(a, b, ncol = 1)
#    fig1 <- ggplotly(a)
#    fig2 <- ggplotly(b)
#    fig <- subplot(fig1, fig2, nrows = 2)
#    fig
    })
    
    
    
                    
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


