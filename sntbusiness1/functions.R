poundmonth <- function(dataset, x, title, height){
    a <- ggplot(data=dataset, aes_string(y="amount", x=x, fill="dealname")) +
    theme_classic() +
#    ggtitle(title) +
     labs(fill='Deal name') +
     ylab("Amount (GBP)") +
     xlab("") +
     scale_y_continuous(labels=scales::dollar_format(prefix="£")) +
     scale_x_date(date_breaks = "month",
      labels = label_date_short()) +
      geom_bar(position="stack", stat="identity") +
      theme(plot.title = element_text(face="bold", size=16, hjust=0.5),
           axis.title = element_text(face="bold", size=12))
    
 #   ggplotly(a, height=height)
}  
 
poundmonthLY <- function(dataset){
    a <- plot_ly() 
    a <- add_trace(a, data=dataset, x = ~Date, y = ~amount, type = 'bar', name = ~dealname, color = ~dealname, colors = "Dark2")

    a <- layout(a, yaxis = list(title = 'Amount (GBP)',
                                   showgrid = F,
                                   tickprefix="£"),
                                   barmode = 'stack')              
    a <- rangeslider(a)
    a   
}

poundmonthcumLY <- function(dataset, datacum){   
     a <- plot_ly() 
     a <- add_trace(a, data=dataset, x = ~Date, y = ~amount, type = 'bar', name = ~dealname, color = ~dealname, colors = "Dark2")

     a <- layout(a, yaxis = list(title = 'Amount (GBP)',
                                   showgrid = F,
                                   tickprefix="£"),
                                   barmode = 'stack')
     a <- add_trace(a, data=datacum, x = ~Date, y = ~Cumamount, #
                           type = 'scatter',  mode = 'lines', name='Cumulative')               
     a <- rangeslider(a)
     a 
 }
    
 #poundmonth(dealsubwon, "Date", "Sales", 650)
 
 cumpoundmonth <- function(dataset, sumdataset, x, title, height){
    a <-  ggplot(data=dataset, aes_string(y="amount", x=x, fill="dealname")) +
    theme_classic() +
#    ggtitle("Sales") +
     labs(fill='Deal name') +
     ylab("Amount (GBP)") +
     xlab("") +
     scale_y_continuous(labels=scales::dollar_format(prefix="£")) +
     scale_x_date(date_breaks = "month",
      labels = label_date_short()) +
      geom_bar(position="stack", stat="identity") +
      geom_line(data=sumdataset, aes_string(x=x, y="Cumamount"), inherit.aes = FALSE) +
      theme(plot.title = element_text(face="bold", size=16, hjust=0.5),
           axis.title = element_text(face="bold", size=12))
    
 #   ggplotly(a, height=height)
    }
 
 
 
 
 
