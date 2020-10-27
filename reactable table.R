#Create reactable table for the LPP schedule.

library(tidyverse)
library(googlesheets4)
library(reactable)

gsheet_LPPdates <- read_sheet("1rzjtZdAyclF-RFuqZB32Wo0wiQNIXAqX-NFx03rQzAo", sheet = "RAW", col_types = "ccciccccDDccccDcD")
#"ccciccccDDccccDcD"

gsheet_LPPdates2 <- gsheet_LPPdates %>%  
  select(Theme, `Sub-theme`, `Current data`,Index,`Components split`, Slug, Frequency,'Full publication date' = `Pulication month...17`, `LPP link`, 
         `Blocker (yes/no) i.e. can't update untiol released`)

gsheet_LPPdates2 <- gsheet_LPPdates2 %>% filter(`Blocker (yes/no) i.e. can't update untiol released` == "yes") #select just data sets that HAVE to be updated before we can process


#make a index var adding in the component number
gsheet_LPPdates2$`Components split`[is.na(gsheet_LPPdates2$`Components split`)] <- 0
gsheet_LPPdates2$filterindex <- NA

gsheet_LPPdates2$filterindex[!is.na(gsheet_LPPdates2$`Components split`)] <- paste0(gsheet_LPPdates2$Index[!is.na(gsheet_LPPdates2$`Components split`)], 
                                                                                   "_", 
                                                                                   gsheet_LPPdates2$`Components split`[!is.na(gsheet_LPPdates2$`Components split`)])



gsheet_LPPdates2$`Data source` <- str_replace(gsheet_LPPdates2$`Current data`, " \\(.*\\)", "")
gsheet_LPPdates2$Slug <- str_replace(gsheet_LPPdates2$Slug, " \\(.*\\)", "")

#make some nicer date columns
gsheet_LPPdates2 <- gsheet_LPPdates2 %>% 
  mutate(Month = format(`Full publication date`, "%B-%Y"))

# #grouped by theme
# gsheet_LPPdates2 %>% select(Theme,Index ,Slug, `Data source`, `Full publication date`, Month)  %>% 
#   reactable( groupBy = "Theme", columns = list(
#     Index = colDef(aggregate = "unique"),
#     `Month`=  colDef(aggregate = "frequency")
#   ))


sortorder <- c("October-2020","November-2020","December-2020","January-2021","February-2021","March-2021","April-2021","May-2021",
               "June-2021","July-2021","August-2021","September-2021","October-2021","November-2021","December-2021")

Slug = colDef(html = T, cell = function(value, index){
  sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2$`LPP link`[index], value)
}


gsheet_LPPdates2$url <- sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2$`LPP link`[index], value))


#grouped by month

 gsheet_LPPdates2 <- gsheet_LPPdates2 %>% arrange(match(Month, sortorder)) #SORT FIRST TO MAKE SURE URL INDEX IS CORRECT ORDER
gsheet_LPPdates2 %>% 
  
  select(Theme,Index ,`Slug`, `Data source`,`Frequency`, `Full publication date`, Month)  %>%
  
 
  reactable(groupBy = "Month", columns = list(
    Index = colDef(aggregate = "unique"),
    `Theme`=  colDef(aggregate = "frequency"),
    Slug = colDef(html = T, cell = function(value, index){
      sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2$`LPP link`[index], value)
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
    ), filterable = T) 

