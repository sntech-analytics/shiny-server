#ui
library(shiny)
library(officer)

title <- 'Progress Report: SafetyNet-Tesco Project: GB108400'

dateinit <- as.character(format(Sys.Date(), format="%d %B %Y"))

introbase <- 'The sample program has proceeded according to schedule. We currently have only one boat operating
 (Eilidh Anne), which is carrying out its usual fishing operations according to the sample schedule. The specific 
 light regimes and numbers of hauls are displayed in the following graphs and table.'
summarybase <- 'There was only one notable glitch in the sampling schedule, due to a gear hookup and 
 subsequent off-day for net repair. Aside from that, the schedule is proceeding well.'

ui <- fluidPage(
    titlePanel("Tesco reporting tool"),
    textAreaInput("title", "Title", 'Progress Report: SafetyNet-Tesco Project: GB108400', width = "500px"),
#    textAreaInput("subtitle", "Subtitle", introbase, width = "500px"),
    textAreaInput("date", "Report date", dateinit, width = "200px"),
    textAreaInput("intro", "Introduction", introbase, width = "1000px"),
    textAreaInput("summary", "Summary", summarybase, width = "1000px"),
    downloadLink('downloadData', 'Download')
)

