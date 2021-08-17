library(ggplot2)
library(plotly)
library(scales)
library(shinydashboard)
library(shinyWidgets)
library(wql)
library(shiny)
library(shinycssloaders)

server <- function(input, output) {

df <- readRDS("enki.RDS")

df$salinityCorr <- ec2pss(df$salinity, df$temp, p = 0)
df$salinityCorr2 <- ec2pss(df$salinity, df$temp, p = df$pressure*0.1)

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
   ylab("Salinity: To be calibrated") +
#   geom_line(data=df, aes(x=DateTime, y=salinity)) +
#   geom_line(data=df, aes(x=DateTime, y=salinityCorr)) +
   geom_line(data=df, aes(x=DateTime, y=salinityCorr2)) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")
      
graphc <- ggplot() +
   theme_classic() +
   ylab("Temperature (°C)") +
   geom_line(data=df, aes(x=DateTime, y=temp)) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")
      
      
graphd <- ggplot() +
   theme_classic() +
   ylab("Light (log(lux))") +
   geom_line(data=df, aes(x=DateTime, y=log10(lux))) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")

graphe <- ggplot() +
   theme_classic() +
   ylab("Conductance") +
   geom_line(data=df, aes(x=DateTime, y=conduct)) +
   scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                     date_breaks = "1 hours")
      

    subplot(ggplotly(grapha), ggplotly(graphe), ggplotly(graphb), ggplotly(graphc), ggplotly(graphd), nrows = 5,
            titleY = TRUE, shareX = TRUE)
  })


output$sumplotdepth <- renderPlotly({
grapha <- ggplot() +
   theme_classic() +
   ylab("Temperature") +
   xlab("Depth") +
   geom_point(data=df, aes(y=temp, x=depthrev), color='black', size=2) +
   geom_point(data=df[1:20,], aes(y=temp, x=depthrev), color='red', size=2) +
   geom_point(data=df[1535:1570,], aes(y=temp, x=depthrev), color='blue', size=2) 
   geom_point(data=df, aes(y=temp, x=depthrev))
 
 graphb <- ggplot() +
   theme_classic() +
   ylab("Conductance") +
   xlab("Depth") +
   geom_point(data=df, aes(y=conduct, x=depthrev), color='black', size=2) +
   geom_point(data=df[1:20,], aes(y=conduct, x=depthrev), color='red', size=2) +
   geom_point(data=df[1535:1570,], aes(y=conduct, x=depthrev), color='blue', size=2) 
   geom_point(data=df, aes(y=conduct, x=depthrev))
      
graphc <- ggplot() +
   theme_classic() +
   ylab("Salinity: To be calibrated") +
   xlab("Depth") +
   geom_point(data=df, aes(y=salinityCorr2, x=depthrev), color='black', size=2) +
   geom_point(data=df[1:20,], aes(y=salinityCorr2, x=depthrev), color='red', size=2) +
   geom_point(data=df[1535:1570,], aes(y=salinityCorr2, x=depthrev), color='blue', size=2) 
   geom_point(data=df, aes(y=salinityCorr2, x=depthrev))
 
    subplot(ggplotly(grapha), ggplotly(graphb), ggplotly(graphc), nrows = 3,
            titleY = TRUE, shareX = TRUE)
  })

output$sumplottemp <- renderPlotly({
grapha <- ggplot() +
   theme_classic() +
   ylab("Conductance") +
   xlab("Temperature") +
   geom_point(data=df, aes(y=conduct, x=temp), color='black', size=2) +
   geom_point(data=df[1:20,], aes(y=conduct, x=temp), color='red', size=2) +
   geom_point(data=df[1535:1570,], aes(y=conduct, x=temp), color='blue', size=2) 
 
 graphb <- ggplot() +
   theme_classic() +
   ylab("Naive salinity measure") +
   xlab("Temperature") +
   geom_point(data=df, aes(y=salinity, x=temp), color='black', size=2) +
   geom_point(data=df[1:20,], aes(y=salinity, x=temp), color='red', size=2) +
   geom_point(data=df[1535:1570,], aes(y=salinity, x=temp), color='blue', size=2) 
      
graphc <- ggplot() +
   theme_classic() +
   ylab("Temperature-corrected salinity") +
   xlab("Temperature") +
   geom_point(data=df, aes(y=salinityCorr2, x=temp), color='black', size=2) +
   geom_point(data=df[1:20,], aes(y=salinityCorr2, x=temp), color='red', size=2) +
   geom_point(data=df[1535:1570,], aes(y=salinityCorr2, x=temp), color='blue', size=2) 
 
    subplot(ggplotly(grapha), ggplotly(graphb), ggplotly(graphc), nrows = 3,
            titleY = TRUE, shareX = TRUE)
  })


}


