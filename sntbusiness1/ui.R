library(shiny)    # for shiny apps
library(leaflet)  # renderLeaflet function
library(htmltools)
library(shinycssloaders)
library(lubridate)
library(ggplot2)
library(ggpubr)
library(plotly)
library(data.table)
library(scales)
library(DT)
library(shinydashboard)



sidebar <-   dashboardSidebar(
        sidebarMenu(
           menuItem("Spreadsheet", tabName = "saleswon", icon = icon("dashboard")),
           menuItem("Graphs", tabName = "graphs", icon = icon("th")),
           menuItem("Timeline", tabName = "timeline", icon = icon("th"))
        )
    )


body <-   dashboardBody(
      tabItems(
         tabItem(tabName = "saleswon",
            h2("Spreadsheet content")
            ),

         tabItem(tabName = "graphs",
            h2("Graph content")
        ),
    
         tabItem(tabName = "timeline",
           h2("Timeline content")
         )
     )
 )

ui <- dashboardPage(
  dashboardHeader(title = "SafetyNet Tech Developmental business dashboard"),
  sidebar,
  body
)


server <- function(input, output) {
}

shinyApp(ui=ui, server=server)



ui <- dashboardPage(
  dashboardHeader(title = "SafetyNet Tech Developmental business dashboard"),
  dashboardSidebar(
        sidebarMenu(
           menuItem("Spreadsheet", tabName = "saleswon", icon = icon("dashboard")),
           menuItem("Graphs", tabName = "graphs", icon = icon("th")),
           menuItem("Timeline", tabName = "timeline", icon = icon("th"))
        )
     ),

  dashboardBody(
      tabItems(

      # First tab content
         tabItem(tabName = "saleswon",
            fluidRow(
             shinycssloaders::withSpinner(
             dataTableOutput(outputId="viewPipeline"))
            )
          ),

      # Second tab content
        tabItem(tabName = "graphs",
           fluidRow(
            shinycssloaders::withSpinner(
            plotlyOutput(outputId="stackSalesCumLY"))
           )
        ),
    
        tabItem(tabName = "timeline",
           fluidRow(
           shinycssloaders::withSpinner(
           plotlyOutput(outputId="stackSalesCumLY"))
         )
       )
   )
)


  
  
  )
 )



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ui <- shinyUI(navbarPage("SafetyNet Tech Developmental business dashboard",
                                             
    tabPanel("Pipeline overview",
 #         sidebarPanel(
  #        tags$img(src="safetynet_logo.png",
 #         title="SafetyNet Technologies",
 #         width="230",
 #         height="70"),
 #            tags$h2("Pipeline overview", align = "center"),
 #            tags$p("This is a developmental business dashboard. Ultimately we will be drawing on multiple data sources using multiple 
 #            API's, and currently there are some manually entered fields in the existing dashboard file that will need to be dealt with 
 #            in some way"),
 #            tags$br(),
 #            tags$p("Expect this to be a bit buggy in places. As soon as someone manually overrides a data field entry, this 
 #            makes things tricky"), 
 #            tags$p("Everything in this dashboard is generated from reading Hubspot directly."),
 #            tags$p("As this matures, we can add displays and style it using CSS to make it prettier!")
 #                   ),
          
          mainPanel(
            tags$img(src="safetynet_logo.png",
            title="SafetyNet Technologies",
            width="230",
            height="70"),
          tags$h1("Pipeline overview", align = "center"),
          
          shinycssloaders::withSpinner(
          dataTableOutput(outputId="viewPipeline"))                
          )
          ),
          
    tabPanel("Sales",
#          sidebarPanel(
 #         tags$img(src="safetynet_logo.png",
  #        title="SafetyNet Technologies",
#          width="230",
#          height="70"),
#             tags$h2("Graphical displays and cute stuff", align = "center"),
#             tags$p("This page provides graphical and summary displays of sales information."),
#             tags$br(),
#             tags$p("Here we can also add features to subset and zoom in on elements of the data, as required. But currently this is 
#             just a static page, based on the latest Hubspot information")
#                     ),
                              
          mainPanel(
            tags$img(src="safetynet_logo.png",
            title="SafetyNet Technologies",
            width="230",
            height="70"),
#          shinycssloaders::withSpinner(
#          tableOutput(outputId="viewSales")),  

#          shinycssloaders::withSpinner(
#          plotOutput(outputId="stackSales")), 

          shinycssloaders::withSpinner(
          plotlyOutput(outputId="stackSalesLY"))                              
          )
          ),
 
     tabPanel("Sales, with cumulative values",
#          sidebarPanel(
 #         tags$img(src="safetynet_logo.png",
  #        title="SafetyNet Technologies",
#          width="230",
#          height="70"),
#             tags$h2("Graphical displays and cute stuff", align = "center"),
#             tags$p("This page provides graphical and summary displays of sales information."),
#             tags$br(),
#             tags$p("Here we can also add features to subset and zoom in on elements of the data, as required. But currently this is 
#             just a static page, based on the latest Hubspot information")
#                     ),
                              
          mainPanel(
            tags$img(src="safetynet_logo.png",
            title="SafetyNet Technologies",
            width="230",
            height="70"),
#          shinycssloaders::withSpinner(
#          tableOutput(outputId="viewSales")),  

#          shinycssloaders::withSpinner(
#          plotOutput(outputId="stackSales")), 

          shinycssloaders::withSpinner(
          plotlyOutput(outputId="stackSalesCumLY"))                              
          )
          ),
 
 
          
    tabPanel("Timelines",
#          sidebarPanel(
 #         tags$img(src="safetynet_logo.png",
  #        title="SafetyNet Technologies",
#          width="230",
#          height="70"),
#             tags$h2("Graphical displays and cute stuff", align = "center"),
#             tags$p("This page provides graphical and summary displays of sales information."),
#             tags$br(),
#             tags$p("Here we can also add features to subset and zoom in on elements of the data, as required. But currently this is 
#             just a static page, based on the latest Hubspot information")
#                     ),
                              
          mainPanel(
            tags$img(src="safetynet_logo.png",
            title="SafetyNet Technologies",
            width="230",
            height="70"),


          shinycssloaders::withSpinner(
          plotlyOutput(outputId="GanttLY"))                                   
          )
          )         
                    

#Close navbarPage
             
            
 )
)

 


