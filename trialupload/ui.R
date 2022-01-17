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

sidebar <- dashboardSidebar(
             tags$img(src="safetynet_logoWB.png",
             title="SafetyNet Technologies",
             width="230",
             height="70"),
           sidebarMenu(
             menuItem("Instructions", tabName = "instructions", icon = icon("info-circle")),
             menuItem("Data upload", tabName = "upload", icon = icon("dashboard")),
             menuItem("Uploaded to date", tabName = "uploaded", icon = icon("chart-bar"))
        )
    )


body <-   dashboardBody(
      tabItems(
         tabItem(tabName = "instructions",
                 fluidRow(
                    h2("Trials data upload interface", align = "center"),
                    h4("I will write a proper set of instructions to lead folks through it", align = "center"),
                    tags$ul(
                        tags$li("The Data Upload page shows what I had in mind. The sampler has a single Excel or ODS file 
 for each trip. The sheets have a validation on them, and they can't move columns around. The first 12 columns are
allocated 
to fixed elements of the data. The Species lengths can be added as required, but the species names will come from 
a validated dropdown list."),
                        tags$li("When the sampler is happy they have the correct sheet highlighted, they can scan for any 
errors (I can add further checks), then they click to upload the data."),
                        tags$li("The data enterer cannot overwrite or delete anything in the database. If they 
screw up, I will fix it."),
                        tags$li("When I link the Upload button to the database, the data are appended to a sandbox
 database on the server"),
                        tags$li("The current data upload status can be viewed on the 'Uploaded to date' tab, after I 
link it all up")
                    )
                     )
                 ),

         tabItem(tabName = "upload",
            fluidRow(
     #               h2("Select the Excel or OpenOffice/LibreOffice ODS file and sheet in the file", align = "center"),
#                column(width=3,                     
#                    h2("After selecting the sheet, eyeball the data and check the details are correct", align = "center"),
#                box(title="Select data file", width=12, status="primary",
#                   fileInput('file1', 'Excel (xlsx) or LibreOffice (ods) spreadsheet file', 
#                             accept = c(".xlsx", ".ods")),
#                   numericInput('file1sheet','Sheet number (in order on the spreadsheet)', 1),
#                   actionButton("upload", "Upload sheet to database")
#                    ),

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
#                   h4("Check the data details. If they are correct, upload the data. If not, correct the source file", align = "center"),

                   box(width=12, infoBoxOutput("observer"),
                   infoBoxOutput("vessel"),
                   infoBoxOutput("date"),
                   infoBoxOutput("haul"),
                   infoBoxOutput("treatment"),
                   infoBoxOutput("notes")
                      ),                
                
                
#                   box(infoBoxOutput("observer")),
#                   box(infoBoxOutput("vessel")),
#                   box(infoBoxOutput("date")),
#                   box(infoBoxOutput("haul")),
#                   box(infoBoxOutput("treatment")),
                
                
                    ),
                 
               fluidRow(
                 box(width=3),
                 box(title="Sample weight", status="primary", tableOutput("weightdat"), width=3),
                 box(title="Fish summary", status="primary", tableOutput("sumdat"), width=6)
                   ),

               fluidRow(                 
                 box(title="Fish lengths", status="primary", tableOutput("fishdat"), width=12)
                      )                
                 
#                 )
            ),
        
         tabItem(tabName = "uploaded",
                fluidRow(
           h2("Table of data uploaded to the sandbox database", align = "center")
         )
        )
      )
   )
#)


ui <- dashboardPage(
  dashboardHeader(title = "SNT trials data upload", titleWidth=300),
  sidebar,
  body
)


