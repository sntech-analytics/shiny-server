library(httr)
library(hubspot)
library(keyring)
library(lubridate)
library(ggplot2)
library(shiny)
library(leaflet)
library(htmltools)
library(shinycssloaders)
library(lubridate)
library(ggplot2)
library(ggpubr)
library(plotly)
library(data.table)
library(scales)



server <- function(input, output) {
library(httr)
library(hubspot)
library(keyring)


source("credentials.R")


deal_props <- hs_deal_properties_tidy()

deals <- hs_deals_raw(properties = deal_props, max_iter = 1)
deal_stages <- data.frame(hs_deals_tidy(deals, view = "properties"))
dput(names((deal_stages)))

dealsub <- deal_stages[c("dealname", 
"hs_date_entered_qualifiedtobuy", 
"hs_is_closed", "days_to_close", 
"hs_deal_stage_probability", "hs_date_exited_presentationscheduled", 
"hs_closed_amount",
"hs_is_closed_won", 
"hs_date_exited_contractsent", 
"hs_forecast_amount", "hs_projected_amount",
"hs_date_entered_closedwon", 
"amount_in_home_currency",
"amount",
"hs_date_entered_contractsent",
"hs_deal_stage_probability_shadow", "dealtype", 
"trial_location", "number_of_kits_required",
"trial_end_date", 
"trial_start_date", "hs_forecast_probability"
)]

dealsub$amount <- round(as.numeric(dealsub$amount), 1)

dealsub$SaleDate <- floor_date(dealsub$hs_date_entered_closedwon, unit="month")
sumstat <- aggregate(round(amount, 0) ~ SaleDate, sum, data=dealsub)
names(sumstat) <- c('Date', 'Amount')


dealsubwon <- dealsub[!is.na(dealsub$SaleDate), ]

output$viewPipeline <- renderTable({
                       dealsub
                       })

output$plotSales <- renderPlot({ 
    ggplot(data=sumstat, aes(y=Amount, x=Date)) +
    theme_classic() +
    ggtitle("Sales") +
#    scale_x_datetime(labels = date_format("%B"),
#                     date_breaks = "1 month") +
    scale_x_datetime(date_breaks = "month",
     labels = label_date_short()) +
    geom_bar(stat="identity")
    })
    
output$stackSales <- renderPlot({ 
    ggplot(data=dealsubwon, aes(y=amount, x=SaleDate, fill=dealname)) +
    theme_classic() +
    ggtitle("Sales") +
#    scale_x_datetime(labels = date_format("%B"),
#                     date_breaks = "1 month") +
    scale_x_datetime(date_breaks = "month",
     labels = label_date_short()) +
    geom_bar(position="stack", stat="identity")
    })
    
}



