library(shiny)

server <- function(input, output) {

library(DT)
library(lubridate)
library(ggplot2)
library(leaflet)
library(htmltools)
library(shinycssloaders)
library(ggpubr)
library(plotly)
library(data.table)
library(scales)

dealsubwon <- readRDS("dealsubwon.RDS")

output$viewPipeline <- renderDT({
                       datatable(dealsubwon, rownames=F)
                       })

output$stackSales <- renderPlot({ 
    ggplot(data=dealsubwon, aes(y=amount, x=SaleDate, fill=dealname)) +
    theme_classic() +
    ggtitle("Sales") +
     labs(fill='Deal name') +
     ylab("Amount (GBP)") +
     xlab("Sale date") +
    scale_x_date(date_breaks = "month",
     labels = label_date_short()) +
    geom_bar(position="stack", stat="identity") +
    theme(plot.title = element_text(face="bold", size=16, hjust=0.5),
          axis.title = element_text(face="bold", size=12))
    })
    
output$stackSalesLY <- renderPlotly({ 

    a <- ggplot(data=dealsubwon, aes(y=amount, x=SaleDate, fill=dealname)) +
    theme_classic() +
    ggtitle("Sales") +
     labs(fill='Deal name') +
     ylab("Amount (GBP)") +
     xlab("Sale date") +
    scale_x_date(date_breaks = "month",
     labels = label_date_short()) +
    geom_bar(position="stack", stat="identity") +
    theme(plot.title = element_text(face="bold", size=16, hjust=0.5),
          axis.title = element_text(face="bold", size=12))
    
    ggplotly(a, height=650)
    })
    
    
output$GanttLY <- renderPlotly({  

     b <- ggplot(data=dealsubwon, aes(x=trial_start_date, xend=trial_end_date, 
                         y=dealname, yend=dealname,
                         color = dealname)) +  
    theme_classic() +
    ggtitle("Project timelines") +
    geom_segment(size=6) +
    scale_x_date(date_breaks = "month",
     labels = label_date_short()) +
    theme(legend.position = "none",
          plot.title = element_text(face="bold", size=16, hjust=0.5),
          axis.title = element_blank())
          
    ggplotly(b, height=650)
   
   })
    
}



