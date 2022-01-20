library(shiny)
library(shinydashboard)
library(shinyalert)
library(readxl)
library(readODS)
library(ggplot2)
library(DT)
library(htmltools)
library(shinycssloaders)
library(shinyWidgets)
library(data.table)
library(lubridate)
library(ggpubr)
library(plotly)
library(RMariaDB)
library(RMySQL)
library(config)
library(pool)
library(scales)


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


saveData <- function(data, table) {

# Construct the upload query by looping over the data fields

for (i in 1:nrow(data)) {
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    table, 
    paste(names(data), collapse = ", "),
    paste(data[i,], collapse = "', '")
  )
  # Submit the update query and disconnect
  dbExecute(con, query)         
    }


}

    
loadData <- function(table) {

  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
 data <- dbGetQuery(con, query)

  data
}       
    

  datain <- reactive({
    if (!is.null(input$file1)) {        
      ext <- tools::file_ext(input$file1)
      if (toupper(ext) == 'XLSX') {
          df <- data.frame(read_excel(input$file1$datapath, 
                        sheet = input$file1sheet))
#          df$Date <- format(df$Date, format="%d %b %Y") 
        return(df)
       }
        else if (toupper(ext) == 'ODS') {
           df <- data.frame(read_ods(input$file1$datapath, 
                        sheet = input$file1sheet))
 #          df$Date <- format(df$Date, format="%d %b %Y") 
        return(df)
        }  

    } else {
      return(NULL)
    } 

  })      

#Eventually put all this into a source file
    
    
output$observer <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Observer", datain()[1,1], icon = icon("binoculars")

        )
    })
    
output$vessel <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Vessel", datain()[1,2], icon = icon("ship")

        )
    })
    
output$date <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Date", format(datain()[1,3], format="%d %b %Y"), icon = icon("calendar")
       
        )
    })
    
output$haul <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Haul", datain()[1,4], icon = icon("wifi")
        )
    })        

output$treatment <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Treatment", paste(toupper(datain()[1,5]), toupper(datain()[1,6]), datain()[1,7], datain()[1,8], datain()[1,9], sep='_'),
        icon = icon("lightbulb")
        )
    }) 
    
output$notes <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Notes", datain()[1,10], , icon = icon("clipboard")
        )
    })  
    

output$weightdat <- renderTable({
                      req(input$file1)
                      weightdat <- datain()[c('WeightVariable','Weight')]
                      weightdat <- weightdat[complete.cases(weightdat),]
                      weightdat$Percent <- weightdat$Weight*100/sum(weightdat$Weight)
                      testsum <- data.frame(unlist(t(colSums(weightdat[c('Weight', 'Percent')]))))
                      testsum$WeightVariable <- "TOTAL"
                      weightdat$Percent <- round(weightdat$Percent, 2)
                      weightdat <- rbind(weightdat, testsum)                                           
                      weightdat
                      })

output$fishdat <- renderTable({
                      req(input$file1)
                      datain()[,13:ncol(datain())]
                      },
                      digits=0) 
   
output$sumdat <- renderTable({
    req(input$file1)
    dt1 <- setDT(datain()[,13:ncol(datain())])
    dt1 <- melt(dt1)
    dt1 <- na.omit(dt1)
    names(dt1) <- c("Species", "value")
    sumstat <- dt1[, unlist(lapply(.SD,
                   function(x) list(min = min(x, na.rm=TRUE),
                                    max = max(x,  na.rm=TRUE),
                                    length=.N)),
             recursive = FALSE),
             by = Species,
             .SDcols = 'value']
    names(sumstat) <- c("Species", "MinimumSize", "MaximumSize", "NumberOfFish")          
    sumstat

                            },
                            digits=0)
                   
                   
observeEvent(input$upload, {
    timestamp <- format(Sys.time(), "%Y_%m_%d_%X") 
    metadat <- datain()[1,1:10]
    metadat$YearMonthDay <- format(metadat$Date, format="%Y-%m-%d") 
    metadat$Date <- metadat$YearMonthDay 
    metadat$timestamp <- timestamp
    metadat$ID <- apply(datain()[1, 1:9] , 1 , paste , collapse = "_")
    metadat <- metadat[c("Observer", "Vessel", "Date", "YearMonthDay", "Haul_Pair", "Net", "Light_on_off", 
                         "Colour", "Flash", "Intensity", "Notes", "ID", "timestamp")]

    dt1 <- setDT(datain()[,13:ncol(datain())])
    dt1 <- melt(dt1)
    dt1 <- na.omit(dt1)
    names(dt1) <- c("Species", "Length")
    SpeciesLength <- dt1[, .N, by = list(Species, Length)]
    SpeciesLength$ID <- metadat[1,1] 
    SpeciesLength$timestamp <- timestamp  
    SpeciesLength$ID <- metadat[1,'ID']
    SpeciesLength$timestamp <- timestamp 
    SpeciesLength$Species <- as.character(SpeciesLength$Species)

    weightdat <- datain()[c('WeightVariable','Weight')]
    weightdat <- weightdat[complete.cases(weightdat),]
    weightdat$ID <- metadat[1,'ID']
    weightdat$timestamp <- timestamp 

    saveData(SpeciesLength, "lengthData")
    saveData(metadat, "sampleID") 
    saveData(weightdat, "weightData")    
    shinyalert("Data submitted!", type = "success")
    
    })    
                   
                   
output$metadat <- renderTable({
    loadData("sampleID")
})  
                   
observeEvent(input$checkdat, {
    output$metadat <- renderTable({
    loadData("sampleID")
            })
})    

                   
}   



