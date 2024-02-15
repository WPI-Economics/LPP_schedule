#Create reactable table for the LPP schedule.
# New code using data created in LPP_updates NOT the googlesheet

library(tidyverse)
library(googlesheets4)
library(reactable)
library(crosstalk)
library(shiny)
library(lubridate)
library(htmltools)

update.df <- readRDS("LPP_schedule_data_2024-02-15.RDS") #WILL NEED TO EDIT DATE HERE
update.df$`Source data release date` <- lubridate::as_date(dmy(update.df$`Indicator update date`))
update.df$`Indicator update date` <- NULL
update.df$`Data source frequency` <- str_to_title(update.df$`Data source frequency`)
#remove 2025 updates
update.df <- update.df %>% filter(
  `Source data release date` < "2024-12-31"
)
#remove blocked ad-hoc etc
update.df <- update.df %>% filter(
  is.na(`Blocked flag`)
)

update.df <- update.df %>% 
  mutate(
    "Update Month" = 
      #when out in the first week of a month prcess in that monthe otherwise move to next month
      case_when( day(`Source data release date`) < 7 ~  month(`Source data release date`),
        day(`Source data release date`) >= 7 ~ month(`Source data release date`)+1
      )
  )

update.df <- update.df %>% 
  mutate(
    "Month" = case_when(
      `Update Month` == 1 ~ "January",
      `Update Month` == 2 ~ "February",
      `Update Month` == 3 ~ "March",
      `Update Month` == 4 ~ "April",
      `Update Month` == 5 ~ "May",
      `Update Month` == 6 ~ "June",
      `Update Month` == 7 ~ "July",
      `Update Month` == 8 ~ "August",
      `Update Month` == 9 ~ "September",
      `Update Month` == 10 ~ "October",
      `Update Month` == 11 ~ "November",
      `Update Month` == 12 ~ "December",
      `Update Month` == 13 ~ "January 2025"
    )
  )



update.df <- arrange(update.df, `Update Month`) %>% select(-`Update Month`)


#The table 
update.df2 <- update.df
table <- update.df %>%
  
  reactable(groupBy = "Month", 
            columns = list(
              Code = colDef(aggregate = "unique"),
              `Theme`=  colDef(aggregate = "frequency"),

              "Chart title" = colDef(
                width = 300,
                html = T, 
                cell = function(value, index){
                  label <- update.df$`Chart title`[index]
                sprintf('<a href="%s" target="_blank">%s</a>',update.df2$url[index], label)
              }),
              
              "Data source name" = colDef(width = 300),
              url = colDef(show = F),
              
              "Blocked flag" = colDef(show = F),
              "Data source frequency" = colDef(show = F)

              
            ),
            
            
            
            defaultPageSize = 19,
            highlight = T,
            striped = T,
            theme = reactableTheme(
              stripedColor = "#f4f1ea",
              highlightColor = "#C2D0D3",
              cellPadding = "6px 10px",
              style = list(fontFamily = "Roboto-light", fontSize = "12px"),
              #searchInputStyle = list(width = "100%", fontWeight = "400"),
              headerStyle = list(color = "white", background = "#00424f", font = "Roboto-light",
                                 "&:hover[aria-sort]" = list(background = "#8c8c8c "),
                                 "&[aria-sort='ascending'], &[aria-sort='descending']" = list(background = "#8c8c8c"),
                                 borderColor = "#8c8c8c"
              )
            ), filterable = T, sortable = F) 
table

withtitle <- htmlwidgets::prependContent(table, 
                                         h2(class = "title", 
                                            style = "font-family: Roboto-light;
                                            color: #00424f",
                                            "LPP Publishing Schedule", 
                                            ) ,
                                         h2(
                                           class = "sub-title",
                                           style = "font-family: Roboto-light;
                                           font-size: 12px; 
                                           color: #00424f",
                                           paste0("Last updated ", Sys.Date() )
                                         ))


save_html(withtitle, "index.html") 
