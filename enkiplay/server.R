library(ggplot2)
library(plotly)
library(scales)
library(shinydashboard)
library(shinyWidgets)

server <- function(input, output) {

df <- readRDS("enki.RDS")


output$plots <- renderPlotly({
grapha <- ggplot() +
   theme_classic() +
#   ggtitle("Depth (m)") +
   ylab("Depth (m)") +
   geom_line(data=df, aes(x=DateTime, y=depthrev)) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")
      
graphb <- ggplot() +
   theme_classic() +
#   ggtitle("Salinity (ppt)") +
   ylab("Salinity (ppt)") +
   geom_line(data=df, aes(x=DateTime, y=salinity)) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")
      
graphc <- ggplot() +
   theme_classic() +
#   ggtitle("Temperature (°C)") +
   ylab("Temperature (°C)") +
   geom_line(data=df, aes(x=DateTime, y=temp)) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")
      
      
graphd <- ggplot() +
   theme_classic() +
#   ggtitle("Light (log(lux))") +
   ylab("Light (log(lux))") +
   geom_line(data=df, aes(x=DateTime, y=log10(lux))) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")

    subplot(ggplotly(grapha), ggplotly(graphb), ggplotly(graphc), ggplotly(graphd), nrows = 4,
            titleY = TRUE, shareX = TRUE)
  })

}


