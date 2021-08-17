library(ggplot2)
library(plotly)
library(scales)
library(shinydashboard)
library(shinyWidgets)
library(shiny)
library(shinycssloaders)

#ui <- dashboardPage(
#  dashboardHeader(title = "Enki play: Single trawl"),
#  dashboardSidebar(),
#  dashboardBody(plotlyOutput("plots", height = "80vh"))
#)



sidebar <-   dashboardSidebar(
          tags$img(src="safetynet_logoWB.png",
          title="SafetyNet Technologies",
          width="230",
          height="70"),
        sidebarMenu(
           menuItem("Enki traces", tabName = "traces", icon = icon("th")),          
           menuItem("Exploratory graphs", tabName = "expgraphs", icon = icon("th"))
        ),
        tags$div(
           tags$ul(
            tags$li("The conductance should not be higher near the surface. The freshwater layer is on the top. So this must be a temperature artefact"),
            tags$li("There is an issue with the conductance to salinity conversion. The Enki value is not corrected for temperature or 
            pressure"),
            tags$li("The naive salinity calculation is in the ballpark, but dependent on temperature. The new-improved calculation is off by about 10ppt."),
            tags$li("There are equilibration issues as Enki descends (red symbols). We cannot reliably detect the thermocline (at about 20m) on descent. Maybe we can think about the smoothing 
             rate a bit for the running average")
              )
           )            
  )



body <-   dashboardBody(
    fluidRow(
      tabItems(
         tabItem(tabName = "traces",
            h2("Data traces from a single haul", align = "center"),
            h4("Click, hold, drag to select. Double click to revert", align = "center"),
            shinycssloaders::withSpinner(
              plotlyOutput("plots", height = "80vh"))
            ),

         tabItem(tabName = "expgraphs",
            h2("Some exploratory bivariate relationships", align = "center"),
            h4("Red = Enki descending; Blue = Enki ascending", align = "center"),
            shinycssloaders::withSpinner(
              box(plotlyOutput("sumplotdepth", height = "80vh"), width=6, height=800)),
            shinycssloaders::withSpinner(
              box(plotlyOutput("sumplottemp", height = "80vh"), width=6, height=800))              
            )
         )
      )
   )




ui <- dashboardPage(
  dashboardHeader(title = "Enki exploration"),
  sidebar,
  body
)

