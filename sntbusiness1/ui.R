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
          tags$img(src="safetynet_logoWB.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
        sidebarMenu(
           menuItem("Sales won", tabName = "saleswon", icon = icon("dashboard")),
           menuItem("Sales in pipeline", tabName = "salespipe", icon = icon("dashboard")),
           menuItem("Unsuccessful bids", tabName = "saleslost", icon = icon("dashboard")),
           menuItem("Sales graphs", tabName = "wongraphs", icon = icon("th")),
           menuItem("Pipeline graphs", tabName = "pipegraphs", icon = icon("th")),
           menuItem("Close, but no cigar graphs", tabName = "lostgraphs", icon = icon("th")),
           menuItem("Project timelines", tabName = "timeline", icon = icon("th"))
        )
    )


body <-   dashboardBody(
    fluidRow(
      tabItems(
         tabItem(tabName = "saleswon",
            h2("Successful sales", align = "center"),
            shinycssloaders::withSpinner(
              dataTableOutput(outputId="wonPipeline"))
            ),

         tabItem(tabName = "salespipe",
            h2("In pipeline", align = "center"),
            shinycssloaders::withSpinner(
              dataTableOutput(outputId="inPipeline"))
            ),

         tabItem(tabName = "saleslost",
            h2("Unsuccessful bids", align = "center"),
            shinycssloaders::withSpinner(
              dataTableOutput(outputId="lostPipeline"))
            ),

         tabItem(tabName = "wongraphs",
            h2("Successful sales", align = "center"),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackSalesLY")),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackSalesCumLY"))
        ),

         tabItem(tabName = "pipegraphs",
            h2("In pipeline", align = "center"),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackPipeLY")),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackPipeCumLY"))
        ),

         tabItem(tabName = "lostgraphs",
            h2("Unsuccessful bids", align = "center"),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackLostLY")),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackLostCumLY"))
        ),
            
         tabItem(tabName = "timeline",
           h2("Project timelines (won and pipeline)", align = "center"),
           shinycssloaders::withSpinner(
             plotlyOutput(outputId="GanttLY"))
         )
      )
   )
)

ui <- dashboardPage(
  dashboardHeader(title = "Business dashboard"),
  sidebar,
  body
)


