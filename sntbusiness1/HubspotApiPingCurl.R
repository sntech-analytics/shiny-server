library(httr)
library(lubridate)
library(data.table)
library(jsonlite)

parta <- "https://api.hubapi.com/crm/v3/objects/deals?limit=100"
partc <- "&archived=false"
authent <- "&hapikey=f9516142-79e9-4058-a738-fa7c0b60bb8e"

fielda <- "&properties=dealname&properties=customer&properties=country&properties=dealtype&properties=hs_is_closed_won&properties=hs_date_entered_contractsent&properties=hs_date_entered_closedlost"
fieldb <- "&properties=hs_date_entered_closedwon&properties=amount&properties=direct_revenue___grant_funded_&properties=objective&properties=fisher__waters_&properties=fishery__species_"
fieldc <- "&properties=fishery__method_&properties=product&properties=number_of_kits_required&properties=trial_location&properties=trial_start_date&properties=trial_end_date"
fieldd <- "&properties=potential_market&properties=hs_forecast_probability&properties=&properties=hs_deal_stage_probability_shadow&properties=dealstage"


callstring <- paste0(parta, fielda, fieldb, fieldc, fieldd, partc, authent)
callstring

resp <- GET(callstring)
jsonRespText <- content(resp, as="text") 
jsonRespdf <- fromJSON(jsonRespText)
jsonRespdf


#Pagination....
#This returns the next curl query:
nextcall <- paste0(jsonRespdf$paging[[1]][[2]], authent)
resp2 <- GET(nextcall)
jsonRespText2 <- content(resp2, as="text") 
jsonRespdf2 <- fromJSON(jsonRespText2)
#THIS RETURNS NULL - NO MORE PAGES TO DOWNLOAD
check <- jsonRespdf2$paging[[1]][[2]]

keepvars <- c("dealname","customer","country", "dealtype", "dealstage", "hs_is_closed_won","hs_date_entered_contractsent",
   "hs_date_entered_closedlost", "hs_date_entered_closedwon", "amount", "direct_revenue___grant_funded_",
   "objective", "fisher__waters_","fishery__species_","fishery__method_","product", "number_of_kits_required",
   "trial_location","trial_start_date","trial_end_date", "potential_market",
   "hs_forecast_probability", "hs_deal_stage_probability_shadow")

dealsub <- rbind(data.frame(jsonRespdf[[1]][[2]][keepvars]), data.frame(jsonRespdf2[[1]][[2]][keepvars]))

dealsub$number_of_kits_required <- as.numeric(dealsub$number_of_kits_required)

dealsub$amount <- round(as.numeric(dealsub$amount), 1)

dealsub$SaleDate <- as.Date(floor_date(as.Date(dealsub$hs_date_entered_closedwon), unit="month"))
dealsub$ContractDate <- as.Date(floor_date(as.Date(dealsub$hs_date_entered_contractsent), unit="month"))
dealsub$LostDate <- as.Date(floor_date(as.Date(dealsub$hs_date_entered_closedlost), unit="month"))


dealsub$WinLoseStatus[dealsub$ContractDate > 0] <- "Pipeline"
dealsub$WinLoseStatus[dealsub$SaleDate > 0] <- "Won"
dealsub$WinLoseStatus[dealsub$LostDate > 0] <- "Lost"


dealsub$Date[dealsub$WinLoseStatus == "Pipeline" & !is.na(dealsub$WinLoseStatus)] <- dealsub$ContractDate[dealsub$WinLoseStatus == "Pipeline" & !is.na(dealsub$WinLoseStatus)]
dealsub$Date[dealsub$WinLoseStatus == "Won" & !is.na(dealsub$WinLoseStatus)] <- dealsub$SaleDate[dealsub$WinLoseStatus == "Won" & !is.na(dealsub$WinLoseStatus)]
dealsub$Date[dealsub$WinLoseStatus == "Lost" & !is.na(dealsub$WinLoseStatus)] <- dealsub$LostDate[dealsub$WinLoseStatus == "Lost" & !is.na(dealsub$WinLoseStatus)]

dealsub$Date <- as.Date(dealsub$Date, origin = "1970-01-01")



dealsub$trial_start_date <- as.Date(dealsub$trial_start_date)
dealsub$trial_end_date <- as.Date(dealsub$trial_end_date)


saveRDS(dealsub, "dealsub.RDS")
#saveRDS(dealsubwon, "./dealsubwon.RDS")


