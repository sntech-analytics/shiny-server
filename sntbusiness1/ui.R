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
           menuItem("Sales graphs: basic", tabName = "wongraphs", icon = icon("th")),
           menuItem("Alternate sales graph (a)", tabName = "wongraphs2", icon = icon("th")),
           menuItem("Alternate sales graph (b)", tabName = "wongraphs3", icon = icon("th")),
           menuItem("Alternate sales graph (c)", tabName = "wongraphs4", icon = icon("th")),
           menuItem("Pipeline graphs (Old)", tabName = "pipegraphs", icon = icon("th")),
           menuItem("Close, but no cigar graphs (Old)", tabName = "lostgraphs", icon = icon("th")),
           menuItem("Project timelines", tabName = "timeline", icon = icon("th")),
           menuItem("Potential market map", tabName = "marketmapLY", icon = icon("globe"))
        )
    )


body <-   dashboardBody(
    fluidRow(
      tabItems(
         tabItem(tabName = "saleswon",
            h2("Successful sales", align = "center"),
            h4("This sheet has a lot of reactive features. You can search in the top right box or type a search term per column in the bottom search boxes. Numeric and date field search boxes bring up a selection slider"),
            h4("Clicking the column names will re-order the values. You can also change the order of the columns by click-hold-drag. The selected view can be saved or printed using the buttons"),
            shinycssloaders::withSpinner(
#              dataTableOutput(outputId="wonPipeline"))
              DTOutput(outputId="wonPipeline"))
            ),

         tabItem(tabName = "salespipe",
            h2("In pipeline", align = "center"),
            shinycssloaders::withSpinner(
#              dataTableOutput(outputId="inPipeline"))
              DTOutput(outputId="inPipeline"))
            ),

         tabItem(tabName = "saleslost",
            h2("Unsuccessful bids", align = "center"),
            shinycssloaders::withSpinner(
#              dataTableOutput(outputId="lostPipeline"))
              DTOutput(outputId="lostPipeline"))
            ),

         tabItem(tabName = "wongraphs",
            h2("Successful sales: Simple graph", align = "center"),
            h4("This is a basic plotly graph. Experiment with hovering and clicking elements of the graph. You can pan, select portions to zoom. You can also select/deselect deals in the legend to display"),
            h4("On the top right there are buttons to set the cursor to pan, zoom, download the graph and so on. Double click to restore the original view"),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackSalesLY", width = "70%", height="700px"))
#            shinycssloaders::withSpinner(
 #             plotlyOutput(outputId="stackSalesCumLY"))
        ),

         tabItem(tabName = "wongraphs2",
            h2("Successful sales: Alternate presentation", align = "center"),
            h4("This presentation adds a graphical slider. Grab the vertical white bars on the bottom plot to drag and zoom the date range"),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackSales2LY", width = "70%", height="700px")),
 #           shinycssloaders::withSpinner(
#              plotlyOutput(outputId="stackSalesCum2LY"))
        ),  
        
         tabItem(tabName = "wongraphs3",
            h2("Successful sales: Alternate presentation with cumulative value", align = "center"),
            h4("As with the previous tab, but with the cumulative value added onto the plot"),
            shinycssloaders::withSpinner(
              plotlyOutput(outputId="stackSalesCum2LY", width = "70%", height="700px"))
        ),      

         tabItem(tabName = "wongraphs4",
            h2("Successful sales: Yet another alternate presentation", align = "center"),
            h4("This is a bit prettier and precise, but without the same degree of interactivity"),
            tags$br(),
            dateRangeInput(inputId = 'dateRange',
             label= 'Select date range',
            start = "2019-10-01"),
            shinycssloaders::withSpinner(
              plotOutput(outputId="stackSalesGGP"))
        ),     

         tabItem(tabName = "pipegraphs",
            h2("In pipeline", align = "center"),
            h3("Why is this graph crap? With the re-definition of the pipeline, there are no reliable date fields to use on the x-axis.", align = "center"),
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
             plotlyOutput(outputId="GanttLY", width = "70%", height="700px"))
         ),
         
         tabItem(tabName = "marketmapLY",
           h2("Potential market map", align = "center"),
           column(width=3,
              selectInput("optlayer", label = "Market measures",
                 choices = c("Potential market" = "PotentialMarket",
                     "Percent chance" = "PercentChance",
                     "Predicted market" = "PotentialMarketRealised"),
                     selected = "Potential market")),
           column(width=9,                     
              shinycssloaders::withSpinner(
                 plotlyOutput(outputId="marketmap", width = "70%", height="500px")))
         )

      )
   )
)

ui <- dashboardPage(
  dashboardHeader(title = "Business dashboard"),
  sidebar,
  body
)


