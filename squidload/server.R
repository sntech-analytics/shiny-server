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
#library(ggpubr)
#library(plotly)
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

# Backbone to read and restructure data from the database for plotting
sampquery <- "SELECT ID,Date,Vessel,Haul,Net,LightOnOff,Colour,Flash,Intensity FROM sampleID"
wtquery <- "SELECT ID,WeightVariable,Weight FROM weightData"
lenquery <- "SELECT ID,Species,Length,N  FROM lengthData"
squidquery <- "SELECT ID,SizeClass,SquidWt  FROM squidData"
     
weightfun <- function() {
    id <- dbGetQuery(con, sampquery)
    weight <- dbGetQuery(con, wtquery)
    weight <- merge(id, weight)
    weight
    }

lengthfun <- function() {
    id <- dbGetQuery(con, sampquery)
    length <- dbGetQuery(con, lenquery)
    SpeciesLength <- merge(id, length)  
    SpeciesLength <- setDT(SpeciesLength)[, .SD[rep(.I, N)], .SDcols = !"N"]
    SpeciesLength
    }

squidfun <- function() {
    id <- dbGetQuery(con, sampquery)
    squid <- dbGetQuery(con, squidquery)
    squid <- merge(id, squid)
    squid
    }
    
##EXCEL READ IN
  datain <- reactive({
            inFile <- input$file1           
            if(is.null(inFile))
                return(NULL)
            ext <- tools::file_ext(inFile$name)
            file.rename(inFile$datapath, paste(inFile$datapath, ext, sep="."))
            df <- as.data.frame(read_excel(paste(inFile$datapath, ext, sep="."), input$file1sheet))
        return(df)

  })     

##INFO BOXES
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

output$timein <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Time in", format(datain()[1,3], format="%H:%M:%S"), icon = icon("clock")
#    "Time in", chron::times(datain()[1,3]), icon = icon("clock")
#     "Time in", structure(as.integer(as.numeric(datain()[1,3])*60*60*24), class="ITime"), icon = icon("clock")      
        )
    })

#output$timeout <- renderInfoBox({
#    req(input$file1)
#    infoBox(
# #   "Time out", format(datain()[4,3], format="%H:%M:%S"), icon = icon("clock")
##     "Time out", chron::times(datain()[4,3]), icon = icon("clock") 
#     "Time out", structure(as.integer(as.numeric(datain()[4,3])*60*60*24), class="ITime"), icon = icon("clock")      
#        )
#    })
    
output$haul <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Haul", datain()[16,1], icon = icon("wifi")
        )
    })        

output$side <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Side of vessel", datain()[19,1], icon = icon("ship")
        )
    })   
    
output$bulk <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Bulk estimate", datain()[13,4], icon = icon("dumbbell")
        )
    })  
    
#output$rf <- renderInfoBox({
#    req(input$file1)
#    infoBox(
#    "Raising factor", datain()[16,4], icon = icon("wifi")       
#        )
#    })

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
    

### IMAGE VERIFICATION INFOBOXES   
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
    

##OUTPUT DATA TABLES FOR DISPLAY AND CHECKING PRIOR TO UPLOAD    
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
                      },
                      na = "")


output$fishdat <- renderTable({
                      req(input$file1)
                      fishdat <- datain()[,8:ncol(datain())]
                      fishdat <- fishdat[rowSums(is.na(fishdat)) != ncol(fishdat), ]
                      fishdat
                      },
                      digits=0, na = "") 
   
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
                            digits=0, na = "")

output$squidcheck <- renderTable({
                      req(input$file1)
                      squidcheck <- data.frame(
                                      rbind(
                                      cbind(1, datain()[17,4]),
                                      cbind(2, datain()[20,4]),
                                      cbind(3, datain()[23,4]),
                                      cbind(4, datain()[26,4]),
                                      cbind(5, datain()[29,4])                                      
                                           )
                                           )
                      names(squidcheck) <- c('SizeClass', 'SquidWt')
                      squidcheck
                      },
                      digits=0, na = "") 

                   
###UPLOADING CODE WITH TIMESTAMP                   
observeEvent(input$upload, {
    timestamp <- format(Sys.time(), "%Y_%m_%d_%X") 
    
##Consolidate Metadata    

    metadat <- data.frame(cbind(datain()[1,1],
                     datain()[4,1],
                     datain()[7,1],
                     datain()[10,1],
                     datain()[13,1],
 #                    data.frame(as.numeric(datain()[16,4])),
                     data.frame(as.numeric(datain()[16,1])),
                     datain()[19,1],
                     format(datain()[1,2], format="%Y-%m-%d"),
                     format(datain()[1,2], format="%Y-%m-%d"),
                     format(datain()[1,3], format="%X"),
 #                    format(datain()[4,3], format="%X"),
                     datain()[1,4],
                     datain()[4,4],
                     datain()[7,4],
                     datain()[10,4],
                     
                     datain()[1,5]))

     names(metadat) <- c("Observer", "Vessel", "Gear", "Position", "Sample_type", "Haul", "Net", 
                   "Date", "YearMonthDay", "Time", "LightOnOff", "Colour", "Flash", "Intensity", "Notes")

#     names(metadat) <- c("Observer", "Vessel", "Gear", "Position", "Sample_type","RaiseFactor", "Haul", "Net", 
#                   "Date", "YearMonthDay", "TimeIn", "TimeOut", "LightOnOff", "Colour", "Flash", "Intensity", "Notes")
   
    
    cols <- c("Observer", "Vessel", "YearMonthDay", "Haul", "Net", 
                   "LightOnOff", "Colour", "Flash", "Intensity")
    metadat$ID <- apply(metadat[1, cols] , 1 , paste , collapse = "_")
    metadat$timestamp <- timestamp

##Consolidate Species length data 

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


##Consolidate weight data 

    weightdat <- datain()[ ,6:7]
    names(weightdat) <- c('WeightVariable', 'Weight')
    weightdat <- weightdat[complete.cases(weightdat),]
    weightdat$ID <- metadat[1,'ID']
    weightdat$timestamp <- timestamp 


##Consolidate bulk data 

     bulkdat <- data.frame(cbind(metadat[1,'ID'], datain()[13,4]))
     names(bulkdat) <- c('ID', 'Bulk')
     bulkdat$timestamp <- timestamp
     bulkdat <- bulkdat[c('Bulk','ID','timestamp')]     

##Consolidate squid size-weight table

    squidat <- data.frame(
               rbind(
               cbind(1, datain()[17,4]),
               cbind(2, datain()[20,4]),
               cbind(3, datain()[23,4]),
               cbind(4, datain()[26,4]),
               cbind(5, datain()[29,4])
               )
               )
     names(squidat) <- c('SizeClass', 'SquidWt')
     squidat$ID <- metadat[1,'ID']
     squidat$timestamp <- timestamp
     squidat <- squidat[c('SizeClass','SquidWt','ID','timestamp')]            


##Write the data files to their database tables
    if (nrow(SpeciesLength) > 0){
    saveData(SpeciesLength, "lengthData")
    }
    if (nrow(metadat) > 0){    
    saveData(metadat, "sampleID")
    }
    if (nrow(weightdat) > 0){  
    saveData(weightdat, "weightData")
    }
    if (nrow(bulkdat) > 0){ 
    saveData(bulkdat, "bulkData")
    }
    if (nrow(squidat) > 0){ 
    saveData(squidat, "squidData")
    }
    
#    saveData(SpeciesLength, "lengthData")
#    saveData(metadat, "sampleID") 
#    saveData(weightdat, "weightData")
#    saveData(bulkdat, "bulkData")   
  
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
         filePath <- file.path("/home/sntech/goldenraysandimage/", fileName)

#Local testing directory
 #        filePath <- file.path("/home/csyms/sandimage/", fileName)
         writeJPEG(imagein, filePath)
        shinyalert("Photo submitted!", type = "success")
#
    } else {
      return(NULL)
    }
})                   
                  
 output$photodat <- renderDT({
 #    dat <- system("ls /home/csyms/sandimage/", intern=TRUE)
    dat <- system("ls /home/sntech/goldenraysandimage/", intern=TRUE)   
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
    dat <- system("ls /home/sntech/goldenraysandimage/", intern=TRUE) 
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
 
# This is where the data read-in from the database and the graphing starts
                                   
output$spselect  <- renderUI({
     SpeciesLength <- lengthfun()
     selectInput("speciesInput", "Species",
                sort(unique(SpeciesLength$Species)))   

  })

output$spfreqplot <- renderPlot({
    SpeciesLength <- lengthfun()
    SpeciesLength$Flash <- factor(SpeciesLength$Flash, levels=c("Constant", "32Hz", "8Hz", "2Hz"))
    SpeciesLength$Colour[SpeciesLength$Colour == "Blue"] <- "XXX"
    datasub <- subset(SpeciesLength, SpeciesLength$Species == input$speciesInput)

   a <- ggplot(data=datasub, aes(x=Length)) +
   theme_classic() +
   geom_histogram(fill='grey', binwidth=1) +
   geom_density(aes(y=..count..)) +
##   scale_y_continuous(limits=c(0,17)) +
##   scale_x_continuous(limits=c(0,45)) +
   ylab("Count") +
   theme(axis.text = element_text(size=12, face="bold"),
         axis.title.x = element_blank(),
         axis.title.y = element_text(size=14, face="bold")) +
   theme(strip.text.x = element_text(size=14, face="bold"),
         strip.text.y = element_text(size=12, face="bold"),
         strip.background = element_blank()) +
#        facet_wrap(~LightOnOff*Flash)
          facet_grid(cols=vars(Flash), rows=vars(LightOnOff))
 #         facet_grid(cols=vars(LightOnOff), rows=vars(Flash))
   a

})

output$sampwtplot <- renderPlot({
      weight <- weightfun()
      weight$Flash <- factor(weight$Flash, levels=c("Constant", "32Hz", "8Hz", "2Hz"))
      a <- ggplot(data=weight, aes(y=Weight, x=WeightVariable, fill=LightOnOff)) +
           theme_classic() +
           geom_boxplot(outlier.shape = NA) +
           geom_jitter(position=position_dodge(0.75), size=3) +
#   geom_jitter(width=0.1) +
#   scale_y_continuous(limits=c(0,17)) +
#   scale_x_continuous(limits=c(0,45)) +
           ylab("Weight (kg)") +
           theme(plot.title = element_text(size=16, face="bold", hjust=0.5),
                axis.text = element_text(size=12, face="bold"),
                axis.title.x = element_blank(),
                axis.title.y = element_text(size=14, face="bold")) +
          theme(strip.text.x = element_text(size=14, face="bold"),
                strip.text.y = element_text(size=12, face="bold"),
                strip.background = element_blank()) +
      #    facet_grid(cols=vars(Flash), rows=vars(LightOnOff))
          facet_wrap(~Flash, ncol=2)
 #          facet_grid(cols=vars(LightOnOff), rows=vars(Flash))

     a
     
}) 


output$squidplot <- renderPlot({
    squid <- squidfun()
    squid$Treatment <- paste(squid$Colour, squid$Flash, sep="_") 
    squid$Flash <- factor(squid$Flash, levels=c("Constant", "32Hz", "8Hz", "2Hz"))
    squid$Colour[squid$Colour == "Blue"] <- "XXX"

   a <- ggplot(data=squid, aes(x=as.factor(SizeClass), y=SquidWt)) +
   theme_classic() +
#   geom_bar(fill='grey', stat="identity") +
    geom_boxplot(outlier.shape=NA) +
    geom_jitter(size=2, width=0.2) +
 ##   scale_y_continuous(limits=c(0,17)) +
##   scale_x_continuous(limits=c(0,45)) +
   ylab("Weight") +
   xlab("Size class") +
   theme(axis.text = element_text(size=12, face="bold"),
#         axis.title.x = element_blank(),
         axis.title.x = element_text(size=14, face="bold"),
         axis.title.y = element_text(size=14, face="bold")) +
   theme(strip.text.x = element_text(size=14, face="bold"),
         strip.text.y = element_text(size=12, face="bold"),
         strip.background = element_blank()) +
#        facet_wrap(~LightOnOff*Flash)
          facet_grid(cols=vars(Treatment), rows=vars(LightOnOff))
 #         facet_grid(cols=vars(LightOnOff), rows=vars(Flash))
   a

})

                 
                   
}   



