library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
library(ggplot2)
library(plotly)
library(data.table)
library(RMariaDB)
library(config)
library(pool)

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
detach(package:config)

# As a safeguard against SQL injection, all queries will be through R base or data.table 
id <- dbGetQuery(con, 'SELECT * FROM trialID')
catch <- dbGetQuery(con, 'SELECT * FROM catchData') 
length <- dbGetQuery(con, 'SELECT * FROM fishLengthData') 
track <- dbGetQuery(con, 'SELECT * FROM trackData') 

catch$Species[catch$Species=='Monks of Anglers'] <- 'Monkfish/Anglers'
length$Species[length$Species=='Monks of Anglers'] <- 'Monkfish/Anglers'

dflength <- merge(id, length)
dfcatch <- merge(catch, id)
dfcatch$CPUERetainedWeight <- dfcatch$RetainedWeight/dfcatch$SoakTowTime
dfcatch$CPUEReturnedWeight <- dfcatch$ReturnedWeight/dfcatch$SoakTowTime
dfcatch$RevReturnedWeight <- dfcatch$ReturnedWeight * -1
dfcatch$RevCPUEReturnedWeight <- dfcatch$CPUEReturnedWeight * -1


server = function(input, output) {

  
output$effortplot <- renderPlot({
#output$sumPlot <- renderPlotly({
      datasub <- dfcatch[(dfcatch$Asset==input$vessel & dfcatch$Species==input$species), ]
      ggplot() +
      theme_classic() +
      geom_hline(yintercept=0) +
     scale_fill_manual(values = c('grey', 'white')) +
      ylab("Retained/returned weight per hour (kg)") +
      xlab("") +
      geom_violin(data = datasub, aes(x=Species, y=CPUERetainedWeight, fill=Light)) +
      geom_point(data = datasub, aes(x=Species, y=CPUERetainedWeight, group=Light), color='black', position = position_dodge(.9)) +
      geom_violin(data = datasub, aes(x=Species, y=RevCPUEReturnedWeight, fill=Light)) +
  #   geom_point(data = datasub, aes(x=Species, y=Returned.Weight, group=Light, color=Light), position = position_dodge(.9)) +
      geom_point(data = datasub, aes(x=Species, y=RevCPUEReturnedWeight, group=Light), color='black', position = position_dodge(.9)) +
     labs(fill="Pisces status") +
#     theme(legend.position = 'none') +
     theme(axis.text.y = element_text(size=12, face="bold"),
#           axis.text.x = element_blank(),
           axis.title = element_text(size=14, face="bold")) +
     theme(strip.text.x = element_text(size=12, face="bold"),
           strip.text.y = element_text(size=12, face="bold"),
           strip.background = element_blank()) +

  facet_wrap(~Species, scales='free')
      
   })      
          
}

