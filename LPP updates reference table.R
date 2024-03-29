#Create reactable table for the LPP schedule.

library(tidyverse)
library(googlesheets4)
library(reactable)
library(crosstalk)
library(shiny)
library(lubridate)

#######################################################################################
######################### MAKES THE TABLE #############################################
#######################################################################################

gsheet_LPPdates <- read_sheet("1rzjtZdAyclF-RFuqZB32Wo0wiQNIXAqX-NFx03rQzAo", sheet = "RAW", col_types = "ccciccccDccccDcDDccic")
#"ccciccccDDccccDcD"

gsheet_LPPdates2 <- gsheet_LPPdates %>%  
  select(Theme, 
         `Sub-theme`, 
         `Current data`,
         `Last update date`,
         `data link`,Index,
         `Components split`, 
         Slug, 
         `Data release frequency`,
         `Data publication date`, 
         `Pulication month`,
         `LPP link`, 
         `Blocker (yes/no) i.e. can't update untiol released`,
         `LPP Publication frequency`, `Remove flag`)

gsheet_LPPdates2 <- gsheet_LPPdates2 %>% filter(`Blocker (yes/no) i.e. can't update untiol released` == "yes") #select just data sets that HAVE to be updated before we can process
gsheet_LPPdates2 <- gsheet_LPPdates2 %>% filter(is.na(`Remove flag`))

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
  mutate(Month = format(`Pulication month`, "%B-%Y"))

#SELECT ONLY INDICATORS WHERE DATA PUBLICATION DATE IS AFTER MOST RECENT PUBLICATION DATE
gsheet_LPPdates2 <- gsheet_LPPdates2 %>% filter(`Last update date` <= `Pulication month`)
#REMOVE INDICATORS UPDATED THE PREVIOUS MONTH
gsheet_LPPdates2 <- gsheet_LPPdates2 %>% filter(month(`Last update date`) != month(Sys.Date())-1)


# #grouped by theme
# gsheet_LPPdates2 %>% select(Theme,Index ,Slug, `Data source`, `Full publication date`, Month)  %>% 
#   reactable( groupBy = "Theme", columns = list(
#     Index = colDef(aggregate = "unique"),
#     `Month`=  colDef(aggregate = "frequency")
#   ))


sortorder <- c("October-2020","November-2020","December-2020","January-2021","February-2021","March-2021","April-2021","May-2021",
               "June-2021","July-2021","August-2021","September-2021","October-2021","November-2021","December-2021",
               "January-2022","February-2022","March-2022","April-2022","May-2022",
               "June-2022","July-2022","August-2022","September-2022","October-2022","November-2022","December-2022")

# Slug = colDef(html = T, cell = function(value, index){
#   sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2$`LPP link`[index], value)
# }
# 
# 
# gsheet_LPPdates2$url <- sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2$`LPP link`[index], value))


#grouped by month

 gsheet_LPPdates2 <- gsheet_LPPdates2 %>% arrange(match(Month, sortorder)) #SORT FIRST TO MAKE SURE URL INDEX IS CORRECT ORDER

 #remove past months
 gsheet_LPPdates2x <- gsheet_LPPdates2 %>% filter(
   as.Date(
     paste0("01-",gsheet_LPPdates2$Month),"%d-%B-%Y") > Sys.Date()-92
 )
 
 
 table <- gsheet_LPPdates2x %>% 
  
  select(Theme,
         Index ,
         `Slug`,
         `Last update date`,
         `Data source`,
          `Data publication date`, 
         `Month`,
         `Data release frequency`, 
         `LPP Publication frequency`
                  )  %>%
   
  reactable(groupBy = "Month", 
            columns = list(
    Index = colDef(aggregate = "unique"),
    `Theme`=  colDef(aggregate = "frequency"),
    Slug = colDef(html = T, cell = function(value, index){
      sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2x$`LPP link`[index], value)
    }),

    `Data source` = colDef(html = T, cell = function(value, index){
      sprintf('<a href="%s" target="_blank">%s</a>',gsheet_LPPdates2x$`data link`[index], value)
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



# #######################################################################################
# ######################### MAKES THE GANT #############################################
# #######################################################################################
# 
# library(timevis)
# 
# gsheet_LPPdates2$end_date <- gsheet_LPPdates2$`Full publication date`+7
# 
# gsheet_LPPdates2$group <- NA
# gsheet_LPPdates2$group[gsheet_LPPdates2$Theme == "Shared opportunity"] <- 1
# gsheet_LPPdates2$group[gsheet_LPPdates2$Theme == "People"] <- 2
# gsheet_LPPdates2$group[gsheet_LPPdates2$Theme == "Living standards"] <- 3
# gsheet_LPPdates2$group[gsheet_LPPdates2$Theme == "Work"] <- 4
# gsheet_LPPdates2$group[gsheet_LPPdates2$Theme == "Housing"] <- 5
# 
# groups <- data.frame(id = unique(gsheet_LPPdates2$group) ,content = unique(gsheet_LPPdates2$Theme))
# 
# 
# na.omit(gsheet_LPPdates2) %>% select(content = Index,
#                                      start = `Full publication date`, 
#                                      end = end_date,
#                                      group = group) %>% 
#   timevis(groups = groups)

library(highcharter)

df <- gsheet_LPPdates2 %>% filter(!is.na(Month)) %>% group_by(Month, Theme) %>% summarise(count = n())
df <- arrange(df,match(Month,sortorder),Theme)
idx <- data.frame(Month = unique(df$Month))
idx$monthorder <- rownames(idx)
df <- merge(df, idx, by = "Month")
df <- arrange(df,match(Month,sortorder),Theme)
df$monthorder <- as.numeric(df$monthorder)

#remove past months
df <- df %>% filter(
  as.Date(
    paste0("01-",df$Month),"%d-%B-%Y") > Sys.Date()-92
    )
                    

  

plot <- hchart(df, "column", hcaes(monthorder, count, group = Theme)) %>%
  
  hc_plotOptions(column = list(stacking = "normal")) %>%
  
  hc_title(text = paste0("Indicator updates schedule. <br>Last updated: ",Sys.Date()), align = "left", 
           style = list(fontSize ="24px",color = "#0d2e5b", 
                        fontFamily = "Arial", fontWeight = "400" )) %>% 
  
  hc_xAxis(title = list(text = ""), categories = c(rep("blank",8),unique(df$Month))) %>%
#c(rep("blank",8),unique(df$Month))
  
  hc_colors(c("#8fb7e4", "#bc323b","#186fa9", "#d07f20","#0d2e5b", "#e2b323" ))
plot 

combo <- htmltools::tagList(plot, table)
htmltools::browsable(combo)
htmltools::save_html(combo, "index.html") 


