# Load data and packages 
library(tidyverse)
er40_events_raw <- read_csv("~/Projects/Evolution/Data/Extra/idemo_task_design_3TR.csv")

er40_events <- er40_events_raw %>% 
  filter(`time onset (seconds)` >= 18,condition != "xhair") %>% 
  mutate(condition = str_replace_all(condition,pattern = "[[:digit:]]",replacement = "")) %>% 
  mutate(duration = 3) %>% 
  select(-`TR (num)`)

write_tsv(er40_events,file = "~/Projects/Evolution/Data/Extra/idemo_events.tsv")
