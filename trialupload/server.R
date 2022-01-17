library(shiny)
library(shinydashboard)
library(readxl)
library(readODS)
library(ggplot2)
library(DT)
library(htmltools)
library(shinycssloaders)
library(shinyWidgets)
library(data.table)


server <- function(input, output) {
    
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
#    "Observer", datain()[1,1]
        )
    })
    
output$vessel <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Vessel", datain()[1,2], icon = icon("ship")
#     "Vessel", datain()[1,2]
        )
    })
    
output$date <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Date", format(datain()[1,3], format="%d %b %Y"), icon = icon("calendar")
#    "Date", format(datain()[1,3], format="%d %b %Y")        
        )
    })
    
output$haul <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Haul", datain()[1,4], icon = icon("wifi")
#    "Haul", datain()[1,4]
        )
    })        

output$treatment <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Treatment", paste(toupper(datain()[1,5]), toupper(datain()[1,6]), datain()[1,7], datain()[1,8], datain()[1,9], sep='_'),
        icon = icon("lightbulb")
#    "Treatment", paste(toupper(datain()[1,5]), toupper(datain()[1,6]), datain()[1,7], datain()[1,8], datain()[1,9], sep='_')
        )
    }) 
    
output$notes <- renderInfoBox({
    req(input$file1)
    infoBox(
    "Notes", datain()[1,10], , icon = icon("clipboard")
        )
    })  
    
    
#output$vessel <- datain()[1,2]
#output$date <- datain()[1,3]
#output$haul <- datain()[1,4]
#output$net <- toupper(datain()[1,5])
#output$treatment <- toupper(datain()[1,6])
#output$light <- paste(toupper(datain()[1,5]), toupper(datain()[1,6]), datain()[1,7], datain()[1,8], datain()[1,9], sep='_')

#weightdat <- datain()[c('WeightVariable','Weight')]
output$weightdat <- renderTable({
                      req(input$file1)
                      weightdat <- datain()[c('WeightVariable','Weight')]
                      weightdat <- weightdat[complete.cases(weightdat),]
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
    
    
    
}   


