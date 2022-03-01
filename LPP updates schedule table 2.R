#Create reactable table for the LPP schedule.
# New code using data created in LPP_updates NOT the googlesheet

library(tidyverse)
library(googlesheets4)
library(reactable)
library(crosstalk)
library(shiny)
library(lubridate)
library(htmltools)

update.df <- readRDS("LPP_schedule_data_2022-03-01.RDS") #WILL NEED TO EDIT DATE HERE

#create backlop category for processing months in the past
update.df$month.formatted <- as.Date(paste0("01-",update.df$Month), format = "%d-%B-%Y")
update.df$Month[update.df$month.formatted %m+% months(1) < (Sys.Date())] <- "Backlog"


update.df <- arrange(update.df,month.formatted)
# sortorder <- c("January-2021","February-2021","March-2021","April-2021","May-2021",
#                "June-2021","July-2021","August-2021","September-2021","October-2021","November-2021","December-2021",
#                
#                "January-2022","February-2022","March-2022","April-2022","May-2022",
#                "June-2022","July-2022","August-2022","September-2022","October-2022","November-2022","December-2022",
#                
#                "January-2023","February-2023","March-2023","April-2023","May-2023",
#                "June-2023","July-2023","August-2023","September-2023","October-2023","November-2023","December-2023",
#                
#                "January-2024","February-2024","March-2024","April-2024","May-2024",
#                "June-2024","July-2024","August-2024","September-2024","October-2024","November-2024","December-2024")

# update.df <- update.df %>% arrange(match(Month, sortorder)) #SORT FIRST TO MAKE SURE URL INDEX IS CORRECT ORDER


#The table 
update.df2 <- update.df
table <- update.df %>% select(-`data link`, -month.formatted) %>% 
  
  reactable(groupBy = "Month", 
            columns = list(
              Index = colDef(aggregate = "unique"),
              `Theme`=  colDef(aggregate = "frequency"),
              url = colDef(html = T, cell = function(value, index){
                sprintf('<a href="%s" target="_blank">%s</a>',update.df2$url[index], value)
              }),
              
            `Current data` = colDef(html = T, cell = function(value, index){
              sprintf('<a href="%s" target="_blank">%s</a>',update.df2$`data link`[index], value)
            })
            ),
            
            defaultPageSize = 19,
            highlight = T,
            striped = T,
            theme = reactableTheme(
              stripedColor = "#f5fdff",
              highlightColor = "#c7e1eb",
              cellPadding = "6px 10px",
              style = list(fontFamily = "Arial", fontSize = "12px"),
              #searchInputStyle = list(width = "100%", fontWeight = "400"),
              headerStyle = list(color = "white",background = "#186fa9",
                                 "&:hover[aria-sort]" = list(background = "#8c8c8c "),
                                 "&[aria-sort='ascending'], &[aria-sort='descending']" = list(background = "#8c8c8c"),
                                 borderColor = "#8c8c8c"
              )
            ), filterable = T, sortable = F) 
table

withtitle <- htmlwidgets::prependContent(table, 
                                         h2(class = "title", style = "font-family: Arial; color: #0d2e5b",
                                            paste0("LPP Publishing Schedule - Last updated ", Sys.Date() ), 
                                            ) 
                                         )


save_html(withtitle, "index.html") 
