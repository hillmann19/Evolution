library(tidyverse)
inputDir <- "/Users/hillmann/Projects/Evolution/Data/AllLogFilesSA"
fileList = list.files(inputDir)

# A helper function which finds the onset, duration, and type of stimulus given a data frame with the log for a particular trial
parseLog <- function(df){
  onset <- df %>% 
    filter(str_detect(Code,pattern = "Video")) %>% 
    pull(Time)

  duration <- 3
  
  video.type <- df %>% 
    filter(str_detect(Code,pattern = "vidname")) %>% 
    mutate(type = ifelse(str_detect(Code,"Fractal"),"Fractal","Face")) %>% 
    pull(type)
  
  choice.type <- ifelse(any(str_detect(df$Code, pattern = "Left_prompt")),"Forced","Choice") 
  
  Type <- paste(choice.type,video.type,sep = "-")
  
  events.df <- data.frame(onset = onset, duration = duration,trial_type = Type)
  return(events.df)
}

buildEventsFile <- function(filename){
  print(filename)
  # Read in a subjects log file for the social approach task (SA = social approach)
  SA.log <- read_delim(paste(inputDir,filename,sep = "/"), 
                       delim = "\t", escape_double = FALSE, 
                       trim_ws = TRUE, skip = 2) %>% 
    rename(Event.Type = `Event Type`) %>% 
    select(-Trial) %>% 
    mutate(Time = Time/10000) %>% 
    mutate(Code = ifelse(is.na(Code),"0",Code))
  
  
  # Find start of the session and only keep time points after the start
  BeginTask.row <- with(SA.log,which(Code == "first_trigger"))
  SA.log <- SA.log %>% 
    filter(row_number() >= BeginTask.row) 
  
  #Create a column which labels the trial number of the row; don't keep anything before the start of trial 1.
  cntr <- 1
  Trial <- c()
  current_trial <- "Pre-trials"
  for(row in SA.log$Code){
    if(str_detect(row,pattern = "Trial")){
      num_trial <- str_extract(row,pattern = "_.*")
      num_trial <- str_remove(num_trial,pattern = "_")
      current_trial <- paste("Trial",num_trial,sep = " ")
    } 
    Trial[cntr] <- current_trial
    cntr <- cntr + 1
  }
  
  SA.log <- SA.log %>% 
    mutate(Trial = Trial) %>% 
    filter(Trial != "Pre-trials")
  
  # Create a list of data frames where each element in the list contains the log from one trial
  SA.log.trial <- SA.log %>% 
    group_split(Trial)
  
  # Map parseLog to every element in SA.log.trial, creating a dataset with the onset, duration, and type of every trial stimulus
  SA.events <- map_dfr(SA.log.trial,parseLog) %>% 
    arrange(onset)
  
  
  return(SA.events)
}

# Fill in the outputDir and subject.id variables in order to run this script for a directory which contains the log files of every subject in the study
events.files <- map(fileList,buildEventsFile)
outputDir <- "/Users/hillmann/Projects/Evolution/Data/AllEventsFilesSA/"
subject.id <- str_replace_all(fileList,pattern = "-.*",replacement = "")
subject.id <- str_replace_all(subject.id,pattern = "([:digit:]*)(_+)([:digit:]*)(.*)",replacement = "\\1_\\3")
for(i in 1:length(events.files)){
  write_csv(events.files[[i]],file = paste0(outputDir,paste0(subject.id[i],"_SAevents.csv")))
}


