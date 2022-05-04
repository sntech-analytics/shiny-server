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


bullet <- "\U2022"
observerID <- c("", "Tom", "Bruce", "Craig", "Kyle")
vesselID <- c("", "Virtuous", "GoldenRay", "LeeRose","EilidhAnne")
options(shiny.maxRequestSize = 30*1024^2)

sidebar <- dashboardSidebar(
             tags$img(src="safetynet_logoWB.png",
             title="SafetyNet Technologies",
             width="230",
             height="70"),
           sidebarMenu(
             menuItem("Instructions", tabName = "instructions", icon = icon("info-circle")),
#Icon doesn't exist anymore
#             menuItem("Data upload", tabName = "upload", icon = icon("dashboard")),
             menuItem("Data upload", tabName = "upload", icon = icon("info-circle"")),
             menuItem("Data uploaded to date", tabName = "uploaded", icon = icon("chart-bar")),
             menuItem("Photo upload", tabName = "photo", icon = icon("camera")),
             menuItem("Photos uploaded to date", tabName = "photoload", icon = icon("camera")),
             menuItem("Size-frequency graphs", tabName = "sizefreqs", icon = icon("chart-bar")),
             menuItem("Sample weights", tabName = "sampwts", icon = icon("chart-bar"))
             
        )
    )

# THE CSS STYLESHEET DOESN'T WORK, BUT INLINE DOES
body <- dashboardBody(
#    useShinyalert(),
#               tags$head(
#                   tags$link(rel = "stylesheet", type = "text/css", href = "www/custom.css")
#             ),
 
includeCSS("www/custom.css"),

#  tags$head(tags$style(HTML('.info-box {min-height: 45px;} .info-box-icon {height: 45px; line-height: 45px; font-size: 200%;}
#   .info-box-content {padding-top: 0px; padding-bottom: 0px;}
 #  .main-sidebar { font-size: 16px;}
  # '))),

           tabItems(

             tabItem(tabName = "instructions",
                     fluidRow(
                      h2("Trials data upload interface", align = "center"),
                      tags$ul(
                          tags$h4(paste0(bullet, "  ", 
                                       "The Data Upload page shows what I had in mind. The sampler has a single Excel or ODS file 
 for each trip. The sheets have a validation on them, and they can't move columns around. The first 12 columns are
allocated 
to fixed elements of the data. The Species lengths can be added as required, but the species names will come from 
a validated dropdown list.")),
                          tags$h4(paste0(bullet, "  ",
                                       "When the sampler is happy they have the correct sheet highlighted, they can scan for any 
errors (I can add further checks), then they click to upload the data.")),
                          tags$h4(paste0(bullet, "  ",
                                       "The data enterer cannot overwrite or delete anything in the database. If they 
screw up, I will fix it.")),
                          tags$h4(paste0(bullet, "  ",
                                       "When I link the Upload button to the database, the data are appended to a sandbox
 database on the server")),
                          tags$h4(paste0(bullet, "  ",
                                       "The current data upload status can be viewed on the 'Uploaded to date' tab, after I 
link it all up"))
                    )
                     )
                    
                 ),
#End tabitem

         tabItem(tabName = "upload",
            fluidRow(
                box(title="Select data file", width=4, status="primary",
                   fileInput('file1', 'Excel (xlsx) or LibreOffice (ods) spreadsheet file',
                             accept = c(".xlsx", ".ods"))
                    ),

                box(title="Select data sheet", width=4, status="primary",
                numericInput('file1sheet','Sheet number (in order on the spreadsheet)', 1)
                ),

                box(title="Check data sheet, then submit to database", width=4, status="primary",
                   actionButton("upload", "Upload sheet to database")
                 ),

                   box(width=12, infoBoxOutput("observer"),
                   infoBoxOutput("vessel"),
                   infoBoxOutput("date"),
                   infoBoxOutput("time"),
                   infoBoxOutput("haul"),
                   infoBoxOutput("side"),
                   infoBoxOutput("bulk"),
                   infoBoxOutput("treatment"),
                   infoBoxOutput("notes")
                      )                                         
                    ),
                 
 #              fluidRow(
 #                box(width=3),
 #                box(title="Sample weight", status="primary", tableOutput("weightdat"), width=3),
  #               box(title="Fish summary", status="primary", tableOutput("sumdat"), width=6)
  #                 ),

 #              fluidRow(                 
 #                box(title="Fish lengths", status="primary", tableOutput("fishdat"), width=12)
 #                     )   
                      
  # NEW TABBOX STRUCTURE
              fluidRow(                    
                 tabBox(title = "Data checks", width=12,
                    side="right",
                    # The id lets us use input$tabset1 on the server to find the current tab
                    id = "datatabset", height = "400px",
                       tabPanel(title="Sample weight", div(tableOutput("weightdat"), class="datacheck")),
                       tabPanel(title="Fish summary", div(tableOutput("sumdat"), class="datacheck")),
                       tabPanel(title="Fish lengths", div(tableOutput("fishdat"), class="datacheck"))
                       
                    )  
                 )                                    
            ),
        
         tabItem(tabName = "uploaded",
                fluidRow(
           h2("Table of data uploaded to the sandbox database", align = "center"),
           actionButton("checkdat", "Refresh to check data entry status"),
#           tableOutput("metadat")
            DTOutput("metadat") 
                    
         )
        ),

# Need to add a whole pile of options here          
         tabItem(tabName = "photo",
                fluidRow(
                   h2("Image upload: jpeg only", align = "center"),
                    box(title="Select image file and sample identifiers", width=3, status="primary",
                       fileInput("imageup", "Upload image", accept =  c('image/jpeg','image/jpg')),
                       selectInput("imvessel", "Vessel", choices = vesselID, selectize = TRUE),
                       dateInput("imdate", "Date"),
                       numericInput('imhaul', 'Haul number', 1),
                       selectInput("imside", "Side of vessel", choices = c("", "Port", "Starboard", "All"),
                                   selectize = TRUE),
                       selectInput("imlight", "Light on or off", choices = c("", "Off", "On"),
                                   selectize = TRUE), 
                       selectInput("imloc", "Photo location (only 1 of each)", 
                                   choices = c("", "Hopper", "Sample", "Net"), selectize = TRUE)
                       ),

                    box(title="Image preview", width=4, status="primary",
                       imageOutput("preview")
                        ),

                    box(title="Identifier check", width=5, status="primary",
 #                      imageOutput("preview"),
                         infoBoxOutput("imagevessel"),
                         infoBoxOutput("imagedate"),
                         infoBoxOutput("imagehaul"),
                         infoBoxOutput("imageside"),
                         infoBoxOutput("imagelight"),
                         infoBoxOutput("imageloc"),
                         actionButton("imageupload", "If all details are correct, upload image")
                        )
                    
         )
        ),
        
         tabItem(tabName = "photoload",
                fluidRow(
           h2("Table of photos uploaded to the server", align = "center"),
           actionButton("checkphoto", "Refresh to check photo upload to server"),
#           tableOutput("metadat")
            DTOutput("photodat") 
                    
         )
        ),
  #End tabitem       
 
          tabItem(tabName = "sizefreqs",
                fluidRow(
  #         h3("Species frequency plots", align = "center"),
           uiOutput("spselect"),
 #          actionButton("updateplot", "Update data set"),
           box(title="Species size frequencies", width=12, status="primary", height=800,
               shinycssloaders::withSpinner(
               plotOutput("spfreqplot", height="700px"))
               )
               )
               ),
 
           tabItem(tabName = "sampwts",
               fluidRow(
                 box(title="Sample weights", width=12, status="primary", height=800,
               shinycssloaders::withSpinner(
               plotOutput("sampwtplot", height="700px"))
             ) 
          #End box
           )
           #End Fluidrow                     
        )
       #End tabitem 
              
      )             
    )    






ui <- dashboardPage(
  dashboardHeader(title = "Golden Ray data upload", titleWidth=300),
  sidebar,
  body
)




