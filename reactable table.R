#Create reactable table for the LPP schedule.

library(tidyverse)
library(googlesheets4)
library(reactable)

gsheet_LPPdates <- read_sheet("1rzjtZdAyclF-RFuqZB32Wo0wiQNIXAqX-NFx03rQzAo", sheet = "RAW", col_types = "ccciccccccccccccc")
#"ccciccccDDccccDcD"

gsheet_LPPdates2 <- gsheet_LPPdates %>%  select(Theme, `Sub-theme`, Index, Slug, Frequency, `Pulication month...17`, `LPP link`)
