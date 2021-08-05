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

dealsub <- readRDS("dealsub.RDS")
dealsubwon <- subset(dealsub, dealsub$WinLoseStatus == "Won")
dealsubpipe <- subset(dealsub, dealsub$WinLoseStatus == "Pipeline")
dealsublost <- subset(dealsub, dealsub$WinLoseStatus == "Lost")

source("functions.R")

# Aggregate to month, and sort for cumulative sums         
sumstat <- aggregate(round(amount, 0) ~ Date + WinLoseStatus, sum, data=dealsub)
names(sumstat) <- c('Date', 'WinLoseStatus', 'Amount') 
sumstat <- sumstat[order(sumstat$Date),]

#Cumulative sums for each catagory
sumstatwon <- subset(sumstat, sumstat$WinLoseStatus == "Won")
sumstatwon$Cumamount <- cumsum(sumstatwon$Amount)

sumstatpipe <- subset(sumstat, sumstat$WinLoseStatus == "Pipeline")
sumstatpipe$Cumamount <- cumsum(sumstatpipe$Amount)

sumstatlost <- subset(sumstat, sumstat$WinLoseStatus == "Lost")
sumstatlost$Cumamount <- cumsum(sumstatlost$Amount)

# Output the spreadsheets
output$wonPipeline <- renderDT({
                       datatable(dealsubwon, rownames=F, options = list(scrollX = TRUE))
                       })

output$inPipeline <- renderDT({
                       datatable(dealsubpipe, rownames=F, options = list(scrollX = TRUE))
                       })

output$lostPipeline <- renderDT({
                       datatable(dealsublost, rownames=F, options = list(scrollX = TRUE))
                       })


# Simple stacked plots    
output$stackSalesLY <- renderPlotly({ 
    poundmonth(dealsubwon, "Date", "Sales", 650)
    })
    
output$stackPipeLY <- renderPlotly({ 
    poundmonth(dealsubpipe, "Date", "Sales", 650)
    })
    
output$stackLostLY <- renderPlotly({ 
    poundmonth(dealsublost, "Date", "Sales", 650)
    })     

# Overlay the cumulative values
output$stackSalesCumLY <- renderPlotly({ 
    cumpoundmonth(dealsubwon, sumstatwon, "Date", "Sales", 650)
    })
 
output$stackPipeCumLY <- renderPlotly({ 
    cumpoundmonth(dealsubpipe, sumstatpipe, "Date", "Pipleline", 650)
    })
 
output$stackLostCumLY <- renderPlotly({ 
    cumpoundmonth(dealsublost, sumstatlost, "Date", "Lost", 650)
    })
 
     
output$GanttLY <- renderPlotly({  

     b <- ggplot(data=dealsubwon, aes(x=trial_start_date, xend=trial_end_date, 
                         y=dealname, yend=dealname,
                         color = dealname)) +  
    theme_classic() +
#    ggtitle("Project timelines") +
    geom_segment(size=6) +
    scale_x_date(date_breaks = "month",
     labels = label_date_short()) +
    theme(legend.position = "none",
          plot.title = element_text(face="bold", size=16, hjust=0.5),
          axis.title = element_blank())
          
    ggplotly(b, height=650)
   
   })
    
}



