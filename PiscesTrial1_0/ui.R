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


#pal <- colorQuantile(
#  palette = "Reds",
#  domain = track$Speed.km.h.)



ui<-fluidPage(

titlePanel(title="Pisces trial interim data dashboard"),

sidebarPanel(
          tags$img(src="safetynet_logo.png",
  #       img(src="safetynet_logo.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
          
      selectInput(inputId = "vessel",
                  label = "Select vessel",
                  choices =  unique(id$Asset),
                  multiple=FALSE,
      ), 

      selectInput(inputId = "species",
                  label = "Select species to plot",
                  choices =  c('Nephrops', 'Haddock', 'Whiting', 'Cod',  'Monkfish/Anglers', 'Plaice', 'Witch'),
                  multiple=FALSE,
                  selected = c('Nephrops')
      ) 

#Close sidebar panel
           ),

mainPanel(
             tags$h2("Catch values per towing hour"),
             tags$p("These violin plots show the catch per hour in kilograms for the different Pisces treatments to date. 
                     Positive values are retained catch, negative values represent returned catch. 
                     Each individual dot is a data record, and the shape of the violin plot represents the density of the data values"),
                     tags$br(),
                     tags$p("This is a very early stage of the trial. No inferences should be drawn yet."),
                     plotOutput(outputId="effortplot")
                               )
                                       

#Close main panel
           )
#Close fluidpage
#)

