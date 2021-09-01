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
library(magrittr)

dealsub <- readRDS("dealsub.RDS")

namesub1 <- c("Date", "dealname", "customer", "country", "amount", "product", "number_of_kits_required", 
              "fishery__species_", "fishery__method_", "fisher__waters_", "objective")

namesub2 <- c("Date", "Deal", "Customer", "Country", "Amount", "Product", "Number required", 
              "Species", "Method", "Waters", "Outcome")

dealsubwon <- subset(dealsub, dealsub$WinLoseStatus == "Won")
dealsubpipe <- subset(dealsub, dealsub$WinLoseStatus == "Pipeline")
dealsublost <- subset(dealsub, dealsub$WinLoseStatus == "Lost")

source("functions.R")

# Aggregate to month, and sort for cumulative sums         
sumstat <- aggregate(round(amount, 0) ~ Date + WinLoseStatus, sum, data=dealsub)
names(sumstat) <- c('Date', 'WinLoseStatus', 'Amount') 
sumstat <- sumstat[order(sumstat$Date, -sumstat$Amount),]

#Cumulative sums for each catagory
sumstatwon <- subset(sumstat, sumstat$WinLoseStatus == "Won")
sumstatwon$Cumamount <- cumsum(sumstatwon$Amount)

sumstatpipe <- subset(sumstat, sumstat$WinLoseStatus == "Pipeline")
sumstatpipe$Cumamount <- cumsum(sumstatpipe$Amount)

sumstatlost <- subset(sumstat, sumstat$WinLoseStatus == "Lost")
sumstatlost$Cumamount <- cumsum(sumstatlost$Amount)

# Output the spreadsheets
# FIXEDHEADER CAN'T BE USED AT THE SAME TIME AS SCROLLING
# THE DOM ENTRY IS A REALLY TRICKY BASTARD. IF SOMETHING DISAPPEARS, CHECK DOM
output$wonPipeline <- renderDT({
                       datatable(dealsubwon[namesub1], rownames=F,
                       colnames = namesub2,
                       filter = 'bottom',
                       extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                       options = list(scrollX = TRUE,
                                     colReorder = TRUE,
                                     autoWidth = TRUE,
                                     pageLength = 10,
                                     lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                     fixedHeader = TRUE,
                                      dom = 'lfrtipB',
#                                      dom = 'lBfrtip',                                     
                                      buttons = c('copy', 'csv', 'excel', 'print')))
                       })

output$inPipeline <- renderDT({
                       datatable(dealsubpipe[namesub1], rownames=F,
                       colnames = namesub2,
                       filter = 'bottom',
                       extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                       options = list(scrollX = TRUE,
                                     colReorder = TRUE,
                                     autoWidth = TRUE,
                                     pageLength = 10,
                                     lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                     fixedHeader = TRUE,
                                      dom = 'lfrtipB',
#                                      dom = 'lBfrtip',                                     
                                      buttons = c('copy', 'csv', 'excel', 'print')))
                       })

output$lostPipeline <- renderDT({
                       datatable(dealsublost[namesub1], rownames=F,
                       colnames = namesub2,
                       filter = 'bottom',
                       extensions = list('ColReorder' = NULL, 'Buttons' = NULL),
                       options = list(scrollX = TRUE,
                                     colReorder = TRUE,
                                     autoWidth = TRUE,
                                     pageLength = 10,
                                     lengthMenu = list(c(10, 25, -1), c("10", "25", "All")),
                                     fixedHeader = TRUE,
                                      dom = 'lfrtipB',
#                                      dom = 'lBfrtip',                                     
                                      buttons = c('copy', 'csv', 'excel', 'print')))
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
    cumpoundmonth(dealsubpipe, sumstatpipe, "Date", "Pipeline", 650)
    })
 
output$stackLostCumLY <- renderPlotly({ 
    cumpoundmonth(dealsublost, sumstatlost, "Date", "Lost", 650)
    })
 
 #ALTERNATE GRAPHS
 output$stackSales2LY <- renderPlotly({ 
    poundmonthLY(dealsubwon)
    })
 
 output$stackSalesCum2LY <- renderPlotly({ 
    poundmonthcumLY(dealsubwon, sumstatwon)
    })
 
     
output$GanttLY <- renderPlotly({  

     b <- ggplot(data=rbind(dealsubwon,dealsubpipe), aes(x=trial_start_date, xend=trial_end_date, 
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



