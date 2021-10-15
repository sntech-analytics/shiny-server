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

#The pipeline spreadsheet needs the probability included
namesubpipe1 <- c("Date", "dealname", "customer", "country", "amount", "hs_forecast_probability", "product", "number_of_kits_required", 
              "fishery__species_", "fishery__method_", "fisher__waters_", "objective")

namesubpipe2 <- c("Date", "Deal", "Customer", "Country", "Amount", "Probability", "Product", "Number required", 
              "Species", "Method", "Waters", "Outcome")



dealsubwon <- subset(dealsub, dealsub$WinLoseStatus == "Won")
dealsubpipe <- subset(dealsub, dealsub$WinLoseStatus == "Pipeline")
dealsublost <- subset(dealsub, dealsub$WinLoseStatus == "Lost")

#Market datasets
worldSubset <- readRDS(file="worldSubset.rds")
worldBubbles <- readRDS(file="worldBubbles.rds")

source("functions.R")

# Aggregate to month, and sort for cumulative sums         
sumstat <- aggregate(round(amount, 0) ~ Date + WinLoseStatus, sum, data=dealsub)
names(sumstat) <- c('Date', 'WinLoseStatus', 'Amount') 
sumstat <- sumstat[order(sumstat$Date, -sumstat$Amount),]

#Cumulative sums for each category
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
                       datatable(dealsubpipe[namesubpipe1], rownames=F,
                       colnames = namesubpipe2,
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


 output$stackSalesGGP <- renderPlot({
#   poundmonthggp(dealsubwon)
     datasub <- subset(dealsubwon, dealsubwon$Date >= as.Date(input$dateRange[1]) & dealsubwon$Date <= as.Date(input$dateRange[2]))
   a <- ggplot(data=datasub, aes_string(y="amount", x="Date", fill="dealname")) +
    theme_classic() +
#   ggtitle(title) +
     labs(fill='Deal name') +
     ylab("Amount (GBP)") +
     xlab("") +
     scale_y_continuous(labels=scales::dollar_format(prefix="£")) +
     scale_x_date(date_breaks = "month",
      labels = label_date_short()) +
      geom_bar(position="stack", stat="identity") +
      theme(plot.title = element_text(face="bold", size=16, hjust=0.5),
           axis.title = element_text(face="bold", size=12))
      a
    })
 
 
     
output$GanttLY <- renderPlotly({  

     b <- ggplot(data=rbind(dealsubwon,dealsubpipe), aes(x=trial_start_date, xend=trial_end_date, 
                         y=dealname, yend=dealname,
                         color = dealname)) +  
    theme_classic() +
#    ggtitle("Project timelines") +
    geom_segment(size=3) +
    scale_x_date(date_breaks = "month",
     labels = label_date_short()) +
    theme(legend.position = "none",
          plot.title = element_text(face="bold", size=16, hjust=0.5),
          axis.title = element_blank())
          
    ggplotly(b, height=650)
   
   })

output$marketmap <- renderPlotly({
    worldHDI <- ggplot() + 
       theme_classic() +
       theme(panel.background = element_rect(fill = 'lightblue1', colour = 'lightblue1')) +
        theme(axis.title=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank(),
        axis.line = element_blank()) +
       coord_fixed(1.3) +
       scale_x_continuous(limits = c(min(worldSubset$long), max(worldSubset$long))) +
       scale_y_continuous(limits = c(min(worldSubset$lat), max(worldSubset$lat))) +
       scale_size_continuous(range = c(3, 8)) +
       expand_limits(y=min(worldSubset$lat), x= min(worldSubset$long)) +
       geom_polygon(data = worldSubset, mapping = aes(x = long, y = lat, group = group),
                    color='grey50', fill='grey50')

                    
     if (input$optlayer == "PotentialMarket") {
         worldHDI <- worldHDI  +  geom_point(data=worldBubbles,  mapping =  aes(x = centroid.lon, y = centroid.lat,
         size=PotentialMarket, color=PotentialMarket,
         label=Country,
         label2 = PotentialMarket, label3 = PercentChance, label4 = PotentialMarketRealised)) +
#         scale_color_distiller(palette ="RdBu", direction = -1)
         scale_color_distiller(palette ="Reds", direction = 1)
       }
       
     if (input$optlayer == "PercentChance") {
         worldHDI <- worldHDI  +  geom_point(data=worldBubbles,  mapping =  aes(x = centroid.lon, y = centroid.lat,
         size=PercentChance, color=PercentChance,
         label=Country,
         label2 = PotentialMarket, label3 = PercentChance, label4 = PotentialMarketRealised)) +
         scale_color_distiller(palette ="Reds", direction = 1)
       }

     if (input$optlayer == "PotentialMarketRealised") {
         worldHDI <- worldHDI  +  geom_point(data=worldBubbles,  mapping =  aes(x = centroid.lon, y = centroid.lat,
         size=PotentialMarketRealised, color=PotentialMarketRealised,
         label=Country,
         label2 = PotentialMarket, label3 = PercentChance, label4 = PotentialMarketRealised)) +
         scale_color_distiller(palette ="Reds", direction = 1)
       }
       
     ggplotly(worldHDI, tooltip = c("label", "label2", "label3", "label4"))
  })
  
}



