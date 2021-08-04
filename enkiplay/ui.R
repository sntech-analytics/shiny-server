library(ggplot2)
library(plotly)
library(shinydashboard)
library(shinyWidgets)


ui <- dashboardPage(
  dashboardHeader(title = "Enki play: Single trawl"),
  dashboardSidebar(),
  dashboardBody(plotlyOutput("plots", height = "80vh"))
)


