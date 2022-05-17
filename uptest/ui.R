library(shiny)
library(readxl)


ui = fluidPage(
        titlePanel("Use readxl"),
        sidebarLayout(
            sidebarPanel(
                fileInput('file1', 'Choose xlsx file',
                          accept = c(".xlsx")
                          )
                ),
            mainPanel(
                tableOutput('contents'))
            )
        )
