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

options(shiny.maxRequestSize = 30*1024^2)

server <- function(input, output) {

session <- ssh_connect("sntech@77.68.125.129", keyfile="./id_rsa")

  output$value <- renderTable({
    if (!is.null(input$file1)) {        
      ext <- tools::file_ext(input$file1)
      if (toupper(ext) == 'XLSX') {
          return(read_excel(input$file1$datapath, 
                        sheet = input$file1sheet))
       }
        else if (toupper(ext) == 'ODS') {
           return(read_ods(input$file1$datapath, 
                        sheet = input$file1sheet))
        }    

    } else {
      return(NULL)
    }
  })

    
  base64 <- reactive({
    inFile <- input$imagefile
    if(!is.null(inFile)){
      dataURI(file = inFile$datapath, mime = c('image/jpeg','image/jpg'))
    }
  })    
    
  output$image <- renderImage({
    if (!is.null(input$imagefile)) { 
        filename <- as.character(input$imagefile$datapath)        
        return(list(
        src=filename,
        height=300,
        filetype = "image/jpeg"))
#        file.copy(as.character(input$imagefile$datapath), "NEWNAME.jpg")
        }
      }, deleteFile = FALSE)

observeEvent(input$validate, {
    if (!is.null(input$imagefile)) {
        imagein <- readJPEG(input$imagefile$datapath)
        fileName <- "shinyupload.jpeg"
        filePath <- file.path(tempdir(), fileName)
        writeJPEG(imagein, filePath)
#          filename <- as.character(input$file1$name)
          scp_upload(session, filePath, to="/home/sntech/sandimage/")     
#
    } else {
      return(NULL)
    }
})

    
  } 
    




