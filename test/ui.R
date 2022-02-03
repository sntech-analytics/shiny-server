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


ui <- fluidPage(
  fileInput('file1', 'Excel (xlsx) or LibreOffice (ods) spreadsheet file', accept = c(".xlsx", ".ods")),
  fileInput('imagefile', 'Image file',  accept =  c('image/jpeg', 'image/jpg')),
  numericInput('file1sheet','Sheet number (in order on the spreadsheet)', 1),
  tableOutput("value"),
  actionButton("validate", "Upload the file"),    
  imageOutput("image")
)


