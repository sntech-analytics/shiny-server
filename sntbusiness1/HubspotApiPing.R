library(httr)
library(hubspot)
library(keyring)
library(lubridate)
library(data.table)


source("credentials.R")

deal_props <- hs_deal_properties_tidy()

deals <- hs_deals_raw(properties = deal_props, max_iter = 1)
deal_stages <- data.frame(hs_deals_tidy(deals, view = "properties"))
dput(names((deal_stages)))

dealsub <- deal_stages[c("dealname","customer","country", "dealtype","hs_is_closed_won","hs_date_entered_contractsent",
   "hs_date_entered_closedlost", "hs_date_entered_closedwon", "amount", "direct_revenue___grant_funded_",
   "objective", "fisher__waters_","fishery__species_","fishery__method_","product", "number_of_kits_required",
   "trial_location","trial_start_date","trial_end_date", "potential_market",
   "hs_forecast_probability", "hs_deal_stage_probability_shadow"
)]

dealsub$amount <- round(as.numeric(dealsub$amount), 1)

dealsub$SaleDate <- as.Date(floor_date(dealsub$hs_date_entered_closedwon, unit="month"))
dealsub$ContractDate <- as.Date(floor_date(dealsub$hs_date_entered_contractsent, unit="month"))
dealsub$LostDate <- as.Date(floor_date(dealsub$hs_date_entered_closedlost, unit="month"))


dealsub$WinLoseStatus[dealsub$ContractDate > 0] <- "Pipeline"
dealsub$WinLoseStatus[dealsub$SaleDate > 0] <- "Won"
dealsub$WinLoseStatus[dealsub$LostDate > 0] <- "Lost"


dealsub$Date[dealsub$WinLoseStatus == "Pipeline" & !is.na(dealsub$WinLoseStatus)] <- dealsub$ContractDate[dealsub$WinLoseStatus == "Pipeline" & !is.na(dealsub$WinLoseStatus)]
dealsub$Date[dealsub$WinLoseStatus == "Won" & !is.na(dealsub$WinLoseStatus)] <- dealsub$SaleDate[dealsub$WinLoseStatus == "Won" & !is.na(dealsub$WinLoseStatus)]
dealsub$Date[dealsub$WinLoseStatus == "Lost" & !is.na(dealsub$WinLoseStatus)] <- dealsub$LostDate[dealsub$WinLoseStatus == "Lost" & !is.na(dealsub$WinLoseStatus)]

dealsub$Date <- as.Date(dealsub$Date, origin = "1970-01-01")



dealsub$trial_start_date <- as.Date(dealsub$trial_start_date)
dealsub$trial_end_date <- as.Date(dealsub$trial_end_date)

#sumstat <- aggregate(round(amount, 0) ~ SaleDate, sum, data=dealsub)
#names(sumstat) <- c('Date', 'Amount')


#dealsubwon <- dealsub[!is.na(dealsub$SaleDate), ]
#dealsubwon <- dealsubwon[c("dealname","customer","country", "dealtype", "hs_date_entered_closedwon", "SaleDate","amount","direct_revenue___grant_funded_",
#   "objective", "fisher__waters_","fishery__species_","fishery__method_","product", "number_of_kits_required",
#   "trial_location","trial_start_date","trial_end_date", "potential_market"
#)]

saveRDS(dealsub, "./dealsub.RDS")
#saveRDS(dealsubwon, "./dealsubwon.RDS")


