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
library(ssh)
library(jpeg)
library(base64enc)



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
    "Vessel", datain()[4,1], icon = icon("ship")

        )
    })
    
output$date <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Date", format(datain()[1,2], format="%d %b %Y"), icon = icon("calendar")
       
        )
    })

    
output$haul <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Haul", datain()[19,1], icon = icon("wifi")
        )
    })        

output$treatment <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Treatment", paste(toupper(datain()[19,1]), toupper(datain()[1,4]), datain()[4,4], datain()[7,4], datain()[10,4], sep='_'),
        icon = icon("lightbulb")
        )
    }) 
    
output$notes <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Notes", datain()[1,5], , icon = icon("clipboard")
        )
    })  
    

### Now the image verification infoBoxes    
output$imagevessel <- renderInfoBox({
    infoBox(
    "Vessel", input$imvessel, icon = icon("ship")
        )
    })
    
output$imagedate <- renderInfoBox({
    infoBox(
    "Date", input$imdate, icon = icon("calendar")       
        )
    })
    
output$imagehaul <- renderInfoBox({
    infoBox(
    "Haul", input$imhaul, icon = icon("wifi")
        )
    })    
    
output$imageside <- renderInfoBox({
    infoBox(
    "Side", input$imside, icon = icon("ship")
        )
    })  

output$imagelight <- renderInfoBox({
    infoBox(
    "Light", input$imlight, icon = icon("lightbulb")
        )
    }) 
        
output$imageloc <- renderInfoBox({
    infoBox(
    "Location", input$imloc, icon = icon("camera")
        )
    }) 
    
    
output$weightdat <- renderTable({
                      req(input$file1)
                      weightdat <- datain()[,6:7]
                      names(weightdat) <- c('Category', 'Weight')
                      weightdat <- weightdat[complete.cases(weightdat),]
                      weightdat$Percent <- weightdat$Weight*100/sum(weightdat$Weight)
                      testsum <- data.frame(unlist(t(colSums(weightdat[c('Weight', 'Percent')]))))
                      testsum$Category <- "TOTAL"
                      weightdat$Percent <- round(weightdat$Percent, 2)
                      weightdat <- rbind(weightdat, testsum)                                           
                      weightdat
                      })

output$fishdat <- renderTable({
                      req(input$file1)
                      fishdat <- datain()[,8:ncol(datain())]
                      fishdat <- fishdat[rowSums(is.na(fishdat)) != ncol(fishdat), ]
                      fishdat
                      },
                      digits=0) 
   
output$sumdat <- renderTable({
    req(input$file1)
    dt1 <- setDT(datain()[,8:ncol(datain())])
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
    metadat <- data.frame(cbind(datain()[1,1],
                     datain()[4,1],
                     datain()[7,1],
                     datain()[10,1],
                     datain()[13,1],
                     data.frame(as.numeric(datain()[16,1])),
                     datain()[19,1],
                     format(datain()[1,2], format="%Y-%m-%d"),
                     format(datain()[1,2], format="%Y-%m-%d"),
                     format(datain()[1,3], format="%X"),
                     datain()[1,4],
                     datain()[4,4],
                     datain()[7,4],
                     datain()[10,4],
                     datain()[1,5]))

     names(metadat) <- c("Observer", "Vessel", "Gear", "Position", "Sample_type", "Haul", "Net", 
                   "Date", "YearMonthDay", "Time", "LightOnOff", "Colour", "Flash", "Intensity", "Notes")
   
    
    cols <- c("Observer", "Vessel", "YearMonthDay", "Haul", "Net", 
                   "LightOnOff", "Colour", "Flash", "Intensity")
    metadat$ID <- apply(metadat[1, cols] , 1 , paste , collapse = "_")
    metadat$timestamp <- timestamp

    dt1 <- setDT(datain()[,8:ncol(datain())])
    dt1 <- melt(dt1)
    dt1 <- na.omit(dt1)
    names(dt1) <- c("Species", "Length")
    SpeciesLength <- dt1[, .N, by = list(Species, Length)]
    SpeciesLength$ID <- metadat[1,1] 
    SpeciesLength$timestamp <- timestamp  
    SpeciesLength$ID <- metadat[1,'ID']
    SpeciesLength$timestamp <- timestamp 
    SpeciesLength$Species <- as.character(SpeciesLength$Species)

    weightdat <- datain()[ ,6:7]
    names(weightdat) <- c('WeightVariable', 'Weight')
    weightdat <- weightdat[complete.cases(weightdat),]
    weightdat$ID <- metadat[1,'ID']
    weightdat$timestamp <- timestamp 

    saveData(SpeciesLength, "lengthData")
    saveData(metadat, "sampleID") 
    saveData(weightdat, "weightData")    
    shinyalert("Data submitted!", type = "success")
    
    })    
                   
                   
#output$metadat <- renderTable({
#    dat <- loadData("sampleID")
#    cols <- c("Observer", "Vessel", "YearMonthDay", "Haul", "Net", "LightOnOff", "Colour", "Flash",
#              "Intensity", "Notes", "timestamp")
#    dat <- dat[cols]
#    dat
#})  
 
# observeEvent(input$checkdat, {
#    output$metadat <- renderTable({
#    dat <- loadData("sampleID")
#    cols <- c("Observer", "Vessel", "YearMonthDay", "Haul", "Net", "LightOnOff", "Colour", "Flash",
#              "Intensity", "Notes", "timestamp")
#    dat <- dat[cols]
#    dat
#            })
#})   
 
output$metadat <- renderDT({
    dat <- loadData("sampleID")
    cols <- c("Observer", "Vessel", "YearMonthDay", "Haul", "Net", "LightOnOff", "Colour", "Flash",
              "Intensity", "Notes", "timestamp")
    dat <- datatable(dat[cols],
                     filter = 'bottom',
                     extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                     options = list(scrollX = TRUE,
                                   colReorder = TRUE,
                                   autoWidth = TRUE,
                                   pageLength = 10,
                                   lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                   fixedHeader = TRUE,
                                   dom = 'lfrtip'
#                                      dom = 'lfrtipB'
#                                      dom = 'lBfrtip',                                     
                                 ))
     dat
})  
  
observeEvent(input$checkdat, {
output$metadat <- renderDT({
    dat <- loadData("sampleID")
    cols <- c("Observer", "Vessel", "YearMonthDay", "Haul", "Net", "LightOnOff", "Colour", "Flash",
              "Intensity", "Notes", "timestamp")
    dat <- datatable(dat[cols],
                     filter = 'bottom',
                     extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                     options = list(scrollX = TRUE,
                                   colReorder = TRUE,
                                   autoWidth = TRUE,
                                   pageLength = 10,
                                   lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                   fixedHeader = TRUE,
                                   dom = 'lfrtip'
#                                      dom = 'lfrtipB'
#                                      dom = 'lBfrtip',                                     
                                 ))
          dat
       })
})   
 

                     
  output$preview <- renderImage({
      req(input$imageup)
    if (!is.null(input$imageup)) { 
        filename <- as.character(input$imageup$datapath)        
        return(list(
        src=filename,
        height=300,
        filetype = "image/jpeg"))
        }
      }, deleteFile = FALSE)



observeEvent(input$imageupload, {
    if (!is.null(input$imageup)) {
        timestamp <- format(Sys.time(), "%Y_%m_%d_%X") 
        imagein <- readJPEG(input$imageup$datapath)
        fileName <- paste0(paste(input$imdate, input$imvessel, "Haul", input$imhaul, input$imside, 
                           input$imlight, input$imloc, timestamp, sep="_"), ".JPG")
         filePath <- file.path("/home/sntech/sandimage/", fileName)

#Local testing directory
#         filePath <- file.path("/home/csyms/sandimage/", fileName)
         writeJPEG(imagein, filePath)
        shinyalert("Photo submitted!", type = "success")
#
    } else {
      return(NULL)
    }
})                   
                  
 output$photodat <- renderDT({
#    dat <- system("ls /home/csyms/sandimage/", intern=TRUE)
     dat <- system("ls /home/sntech/sandimage/", intern=TRUE)   
    ident <-  substring(dat, 1, nchar(dat)-4)          
    sub <- substring(dat, 1, nchar(dat)-24) 
    date <- substring(sub, 1, 10)
    sample <- substring(sub, 12, nchar(sub))
    table <- data.frame(cbind(date, sample, ident))
    names(table) <- c("SampleDate", "Sample", "FileID")
    dat <- datatable(table,
                     filter = 'bottom',
                     extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                     options = list(scrollX = TRUE,
                                   colReorder = TRUE,
                                   autoWidth = TRUE,
                                   pageLength = 10,
                                   lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                   fixedHeader = TRUE,
                                   dom = 'lfrtip'
#                                      dom = 'lfrtipB'
#                                      dom = 'lBfrtip',                                     
                                 ))
     dat
})
                   

observeEvent(input$checkphoto, {                   
 output$photodat <- renderDT({
 #   dat <- system("ls /home/csyms/sandimage/", intern=TRUE)
    dat <- system("ls /home/sntech/sandimage/", intern=TRUE) 
    ident <-  substring(dat, 1, nchar(dat)-4)          
    sub <- substring(dat, 1, nchar(dat)-24) 
    date <- substring(sub, 1, 10)
    sample <- substring(sub, 12, nchar(sub))
    table <- data.frame(cbind(date, sample, ident))
    names(table) <- c("SampleDate", "Sample", "FileID")
    dat <- datatable(table,
                     filter = 'bottom',
                     extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                     options = list(scrollX = TRUE,
                                   colReorder = TRUE,
                                   autoWidth = TRUE,
                                   pageLength = 10,
                                   lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                   fixedHeader = TRUE,
                                   dom = 'lfrtip'
#                                      dom = 'lfrtipB'
#                                      dom = 'lBfrtip',                                     
                                 ))
     dat
})
})
                                   
                   
                   
}   



