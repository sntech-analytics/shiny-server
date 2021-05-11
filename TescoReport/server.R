#server
library(ggplot2)
library(ggpubr)
library(data.table)
library(lubridate)
library(car)
library(MASS)
library(officer)
library(ggplot2)
library(scales)

library(RMariaDB)
library(config)
library(pool)


db_config <- config::get("dataconnection")
con <- dbPool(
  drv = MariaDB(),
  dbname = db_config$dbname,
  host = db_config$host,
  username = db_config$username,
  password = db_config$password
)

#THIS IS IMPORTANT!!
#Config has its own merge() which conflicts with base R
detach(package:config)

trialID <- dbGetQuery(con, "SELECT * FROM piscestrial.trialID WHERE Project='Tesco'")
trialID$Vessel <- trialID$Asset
trialID <- subset(trialID, Light != 'NA')
trialID$Day <- floor_date(trialID$StartDateDT, "day")
trialID$accum <- 1
trialID <- trialID[order(trialID$Day),]
DT <- data.table(trialID)
countset <- DT[, .N, by = list(Position, Colour, Light,Flash,Day)]
countDF <- as.data.frame(countset[, csum := cumsum(N), by = list(Position, Colour, Light,Flash)])
ggcum <- ggplot(data = countDF,
  aes(x=Day	, y=csum, fill=Flash)) +
  theme_classic() +
#  geom_point() +
  geom_bar(stat='identity') +
  geom_line() +
  ggtitle("Cumulative number of Pisces deployments") +
  ylab("Cumulative number of hauls") +
  xlab("") +
   theme(plot.title = element_text(size=14, face="bold", hjust=0.5)) +
   theme(axis.text = element_text(size=12, face="bold"),
         axis.title = element_text(size=14, face="bold")) +
   theme(strip.text.x = element_text(size=12, face="bold"),
         strip.text.y = element_text(size=12, face="bold"),
         strip.background = element_blank()) +
  facet_wrap(~Colour + Flash, nrow=2)

wkcountDF <- as.data.frame(as.data.table(trialID)[, .N, by = list(Vessel,Position, Colour, Light,Flash)])

server <- function(input, output) {
    output$downloadData <- downloadHandler(
        filename = function() {
            paste('data-', Sys.Date(), '.docx', sep='')
        },
        
                
        content = function(doccontent) {
            x <- read_docx('BasicTemplate.docx') 
            x <- body_add(x, input$title, style = "Subtitle")
#            x <- body_add(x, subtitle, style = "Subtitle")
            x <- body_add(x, input$date, style = "Body Text")
            x <- body_add(x, 'Overview', style = "Heading")            
            x <- body_add(x, input$intro, style = "Body Text")
            x <- body_add(x, "", style = "Body Text")
            x <- body_add_gg(x, ggcum, width = 5, height = 4, res = 300, style = "Body Text")
            x <- body_add(x, 'Crosstabulation', style="Table Heading")
            x <- body_add_table(x, wkcountDF)
#            x <- body_add(x, tablehead, style = "Table Heading")
#            x <- body_add_table(x, df2)
            x <- body_add(x, 'Additional comments', style = "Heading")   
            x <- body_add(x, input$summary, style = "Body Text")
            print(x, target = doccontent)
        }
    )

}

