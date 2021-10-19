library(trelloR)
library(googlesheets4)

gsheet_LPPdates <- read_sheet("1rzjtZdAyclF-RFuqZB32Wo0wiQNIXAqX-NFx03rQzAo", sheet = "RAW", col_types = "ccciccccDDcccccDcDcDcci")

LPPcards <- get_board_cards("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
BID <- get_id_board("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
LPP_Labels <- get_board_labels(BID)

LPPcardlist <- get_board_lists("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
LPPcardlist <- LPPcardlist %>% select("id", "name")

#' match the names in to the main data
LPPcards <- merge(LPPcards,LPPcardlist, by.x = "idList", by.y = "id")

Updated <- LPPcards %>% filter(name.y %in% c("PUBLISHED")) %>% 
  mutate(index = word(name.x, 1))


for(i in LPPcards$id){
  add_checklist(i, "Publication date")
}


LPPcards <- get_board_cards("https://trello.com/b/2tGgK1yy/lpp-publication-shedule")
LPPcards$index <- word(LPPcards$name,1)

y <- get_board_checklists(BID)
deletelist <- y %>% filter(name == "Publiction date")

for(i in deletelist$id){
  delete_checklist(i)
}

gsheet_LPPdates3 <- gsheet_LPPdates2 %>% distinct(Index, .keep_all = T)



for(i in unique(LPPcards$index)){
  add_checkitem(LPPcards$idChecklists[LPPcards$index == i], name = gsheet_LPPdates3$`Last update date`[gsheet_LPPdates3$Index == i])
}


for(i in Updated$index){
  add_checkitem(Updated$idChecklists[Updated$index == i], name = "2020-11-06")
}

boroughcards <- LPPcards %>% select(-id, -idBoard) %>% unnest(labels) %>% filter(name == "BOROUGH LEVEL", name.y == "PUBLISHED")

boroughcards <- LPPcards %>% filter(index %in% boroughcards$index)


for(i in boroughcards$idChecklists){
  add_checkitem(i, "2020-10-12")
  
}

for(i in boroughcards$idChecklists){
  delete_checklist(i)
  
}


boroughcardID <- LPPcards %>% filter(index %in% boroughcards$index)

for(i in boroughcardID$id){
  add_checklist(i, "Publication date")
}


