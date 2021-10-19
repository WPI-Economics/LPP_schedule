#Create reactable table for the LPP schedule.
# New code using data created in LPP_updates NOT the googlesheet

library(tidyverse)
library(googlesheets4)
library(reactable)
library(crosstalk)
library(shiny)
library(lubridate)

update.df <- readRDS("LPP_schedule_data_2021-10-19.RDS") #WILL NEED TO EDIT DATE HERE

update.df <- arrange(update.df,`New data publication date`)


#The table 

table <- update.df %>% 
  
  reactable(groupBy = "Month", 
            columns = list(
              Index = colDef(aggregate = "unique"),
              `Theme`=  colDef(aggregate = "frequency"),
              url = colDef(html = T, cell = function(value, index){
                sprintf('<a href="%s" target="_blank">%s</a>',update.df$url[index], value)
              }),
              
            `data link` = colDef(html = T, cell = function(value, index){
              sprintf('<a href="%s" target="_blank">%s</a>',update.df$`data link`[index], value)
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


htmltools::save_html(table, "index.html") 
