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
length <- dbGetQuery(con, 'SELECT * FROM fishLengthData') 
lightid <- dbGetQuery(con, 'SELECT * FROM lightID')    
    
    
greffort <- subset(dfeffort, Asset=='GoldenRay')
towtrack2 <- subset(towtrack, Asset=='GoldenRay')
towtrack2 <- merge(greffort, towtrack2)
towtrack2 <- towtrack2[c("Asset", "SampleID", "StartDate", "Date", "Latitude", "Longitude")]

grlength <- merge(length, lightid, by=c('LightKey', 'SampleID'))
grlength <- subset(grlength, substr(grlength$LightKey, 1, 9) == 'GoldenRay')

dfnephrops <- subset(dfcatch, dfcatch$Species %in% c('Nephrops', 'Nephrops Tails') & dfcatch$Asset=='GoldenRay')
dfnephrops <- aggregate(RetainedWeight ~ Asset + SampleID + StartDateDT, sum, data=dfnephrops)
dfnephrops <- merge(dfnephrops, dfeffort)
dfnephrops$NephropsCPUE <- dfnephrops$RetainedWeight/dfnephrops$TowTimeHours
dfnephrops <- dfnephrops[c("Asset", "SampleID", "StartDateDT", "NephropsCPUE", "RetainedWeight", "TowTimeHours")]

combdat <- merge(towtrack2, dfnephrops, by=c("Asset", "SampleID"))
combdat <- combdat[order(combdat$Date),] 
    
#For the Nephrops violin plots
nephropscatch <- merge(dfnephrops, lightid, by='SampleID')
    
#Tides
tideData <- readRDS(file='tideData.RDS')
DTEffort = melt(as.data.table(greffort), id.vars = c("Asset", "SampleID"),
                measure.vars = c("TrawlStartTime", "TrawlEndTime"), value="DateTime")
DTEffort$DateTime <- as_datetime(DTEffort$DateTime)
DTEffort <- merge(DTEffort, dfnephrops)
multfact <- max(DTEffort$NephropsCPUE) + 10
minx <- min(DTEffort$DateTime)
maxx <- max(DTEffort$DateTime)    
    
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

    
output$slider <- renderUI({
      minx <- min(DTEffort$DateTime)
      maxx <- max(DTEffort$DateTime)

     sliderInput("slider","Select date", min = minx, 
                 max   = maxx,
                 value = c(minx,maxx))
   })
    
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

    
output$plot1<-renderPlot({  
    ggplot() +
    theme_classic() +
     labs(x = "", 
         y = "CPUE (kg/hour)") +
    geom_line(data=DTEffort, aes(x=DateTime, y=NephropsCPUE, group=SampleID), size=2, color=pal(DTEffort$NephropsCPUE)) +
    geom_line(data=tideData, aes(x=Date, y=20*Tide + multfact)) +
    scale_x_datetime(limits = c(input$slider))
})
    
output$plot2<-renderPlotly({  
    ggplotly(ggplot() +
    theme_classic() +
    labs(x = "", 
         y = "CPUE (kg/hour)") +
    geom_line(data=DTEffort, aes(x=DateTime, y=NephropsCPUE, group=SampleID), size=2, color=pal(DTEffort$NephropsCPUE)) +
    geom_line(data=tideData, aes(x=Date, y=20*Tide + multfact)) +
    scale_x_datetime(limits = c(minx, maxx))  
             )
})     

    
output$lengthplot<-renderPlot({  
    datasub <- subset(grlength, grlength$Species %in% c(input$splength))
    ggplot(data=datasub, aes(x = Length, group=Colour)) +
   theme_classic() +
   ggtitle(input$splength) +
    geom_histogram(fill='grey', binwidth=1) +
   geom_density(aes(y=..count..)) +
   ylab("Count") +
   theme(legend.position = 'none') +
   theme(plot.title = element_text(size=20, face="bold", hjust=0.5)) +
   theme(axis.text = element_text(size=12, face="bold"),
         axis.title = element_text(size=14, face="bold")) +
   theme(strip.text.x = element_text(size=14, face="bold"),
         strip.text.y = element_text(size=12, face="bold"),
         strip.background = element_blank()) +
   facet_wrap(~Colour, ncol=1, scales="free")
})   
    
    
#output$lengthplotly<-renderPlotly({  
#    datasub <- subset(grlength, grlength$Species %in% c(input$splength))
#    ggplotly(ggplot(data=subset(grlength, grlength$Species %in% c(input$splength)), aes(x = Length, group=Colour)) +
#   theme_classic() +
#   ggtitle(input$splength) +
#    geom_histogram(fill='grey', binwidth=1) +
#   geom_density(aes(y=..count..)) +
#   ylab("Count") +
#   theme(legend.position = 'none') +
#   theme(plot.title = element_text(size=20, face="bold", hjust=0.5)) +
#   theme(axis.text = element_text(size=12, face="bold"),
#         axis.title = element_text(size=14, face="bold")) +
#   theme(strip.text.x = element_text(size=14, face="bold"),
#         strip.text.y = element_text(size=12, face="bold"),
#         strip.background = element_blank()) +
#   facet_wrap(~Colour, ncol=1, scales="free"))
#})   

output$sumPlot <- renderPlotly({    
    ggplotly(ggplot(data = nephropscatch) +
       theme_classic() +
#        scale_color_manual(values = c('black', 'blue', 'green')) +
        labs(y="Nephrops CPUE (kg/hour)", x="") +
        ggtitle("Nephrops catch") +
        geom_violin(data = nephropscatch, aes(x=Colour, y=NephropsCPUE)) +       
        geom_point(data = nephropscatch, aes(x=Colour, y=NephropsCPUE), position = position_dodge(1)) +
        theme(plot.title = element_text(face='bold', size = 18, hjust=0.5),
              axis.title.y = element_text(face='bold', size = 14),
              axis.title.x = element_blank(),
              axis.text.y = element_text(size = 12),
              axis.text.x = element_text(face='bold', size = 14)))
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
             maptest <- addCircles(maptest, lng = ~Longitude,
                           lat = ~Latitude,
                           color = ~pal(NephropsCPUE),
                           radius=50)
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
      addCircles(lng = maptow$Longitude,
                       lat = maptow$Latitude,
                       color = pal(maptow$NephropsCPUE),
                       radius=50) %>%
      addLegend(      data = maptow,
                       pal = pal,
                       values = maptow$NephropsCPUE,
                       position = "bottomleft",
                       title = "Nephrops CPUE (kg/hour)",
                     opacity = 0.9
                     )
         })
 
    
    
    
 }


