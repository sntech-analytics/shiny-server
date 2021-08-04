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
    fluidRow(
      tabItems(
         tabItem(tabName = "saleswon",
            shinycssloaders::withSpinner(
              dataTableOutput(outputId="viewPipeline"))
            ),

         tabItem(tabName = "graphs",
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackSalesCumLY"))
        ),
    
         tabItem(tabName = "timeline",
           shinycssloaders::withSpinner(
             plotlyOutput(outputId="GanttLY"))
         )
      )
   )
)

ui <- dashboardPage(
  dashboardHeader(title = "SafetyNet Tech Developmental business dashboard"),
  sidebar,
  body
)


