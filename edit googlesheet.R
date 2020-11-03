library(googlesheets4)


LPPcards <- get_board_cards("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
BID <- get_id_board("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
LPP_Labels <- get_board_labels(BID)

LPPcardlist <- get_board_lists("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
LPPcardlist <- LPPcardlist %>% select("id", "name")

#' match the names in to the main data
LPPcards <- merge(LPPcards,LPPcardlist, by.x = "idList", by.y = "id")

Updated <- LPPcards %>% filter(name.y %in% c("PUBLISHED", "Ready for Trust QA", "Sonny problem list", "COMPLETE: uploaded, QA done, double checked",
                                             "Ready for Trust QA", "Data/chart updated copy to be done")) %>% select(id, name.x) %>% 
  mutate(index = word(name.x, 1))

Updated <- Updated %>% filter(!grepl("^[A-Za-z]+$",index)) #remove boroughs


gsheet_LPPdates <- read_sheet("1rzjtZdAyclF-RFuqZB32Wo0wiQNIXAqX-NFx03rQzAo", sheet = "RAW", col_types = "ccciccccDDcccccDcDcD")

gsheet_LPPdates$`Last update date`[gsheet_LPPdates$Index %in% Updated$index] <- "2020-10-12"


range_write("1rzjtZdAyclF-RFuqZB32Wo0wiQNIXAqX-NFx03rQzAo", data.frame(gsheet_LPPdates$`Last update date`), range = "T2")
                                                                 