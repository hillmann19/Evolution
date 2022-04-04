# Load in necessary data and scripts
library(tidyverse)
library(ggpubr)
sips_long <- read_csv("~/Projects/Evolution/Data/evolpsy/sips_long.csv")
sips_diag <- read_csv("~/Projects/Evolution/Data/evolpsy/study_enroll_imaging.csv")
birth_date <- read_csv("~/Projects/Evolution/Data/evolpsy/dobirth.csv")
CNB_mega <- read_csv("~/Projects/CNB_Longitudinal/Data/cnb_merged_20220201.csv")
GO1_diag <- read_csv("~/Projects/ER40/Data/n9498_diagnosis_dxpmr7_20170509.csv")

sips_diag %>% 
  left_join(GO1_diag,by = c("BBLID" = "bblid")) %>% 
  separate(STUDY_GROUP,into = c("Diagnosis","Environment")) %>% 
  relocate(Diagnosis,goassessDxpmr7) %>% 
  filter(Diagnosis != goassessDxpmr7)


sips_diag_full <- sips_diag %>% 
  distinct(.keep_all = T) %>% 
  separate(col = STUDY_GROUP,into = c("Diagnosis","Environment")) %>% 
  left_join(birth_date) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "JAN",replacement = "01"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "FEB",replacement = "02"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "MAR",replacement = "03"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "APR",replacement = "04"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "MAY",replacement = "05"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "JUN",replacement = "06"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "JUL",replacement = "07"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "AUG",replacement = "08"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "SEP",replacement = "09"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "OCT",replacement = "10"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "NOV",replacement = "11"))) %>% 
  mutate(across(.cols = c(DOENROLL,DOSCAN,DOBIRTH),.fns = ~ str_replace_all(.x,pattern = "DEC",replacement = "12")))

sips_long <- sips_long %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "JAN",replacement = "01")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "FEB",replacement = "02")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "MAR",replacement = "03")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "APR",replacement = "04")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "MAY",replacement = "05")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "JUN",replacement = "06")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "JUL",replacement = "07")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "AUG",replacement = "08")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "SEP",replacement = "09")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "OCT",replacement = "10")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "NOV",replacement = "11")) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "DEC",replacement = "12"))

sips_long_z <- sips_long %>% 
  mutate(across(.cols = p1:g4,~ ifelse(.x == 9,NA,.x))) %>% 
  mutate(across(.cols = p1:g4,~ as.numeric(scale(.x)))) %>% 
  rowwise() %>% 
  mutate(p_avg = mean(c(p1,p2,p3,p4,p5),na.rm = T)) %>% 
  mutate(n_avg = mean(c(n1,n2,n3,n4,n5,n6),na.rm = T)) %>% 
  mutate(d_avg = mean(c(d1,d2,d3,d4),na.rm = T)) %>% 
  mutate(g_avg = mean(c(g1,g2,g3,g4),na.rm = T)) %>% 
  ungroup() %>% 
  left_join(sips_diag_full[,c("BBLID","DOBIRTH","Diagnosis")],by = c('bblid' = "BBLID")) %>% 
  left_join(GO1_diag) %>% 
  mutate(Year_birth = str_replace_all(DOBIRTH,pattern = "[[:digit:]][[:digit:]]-[[:digit:]][[:digit:]]-","")) %>% 
  mutate(Year_birth = ifelse(as.numeric(Year_birth) > 22,paste0("19",Year_birth),paste0("20",Year_birth))) %>% 
  mutate(DOBIRTH = str_replace_all(DOBIRTH,pattern = "-[[:digit:]][[:digit:]]$",paste0("-",Year_birth))) %>% 
  mutate(DOBIRTH = as.Date(DOBIRTH,format = "%d-%m-%Y")) %>%
  mutate(Year_sips = paste0("20",str_replace_all(dosips,pattern = "[[:digit:]][[:digit:]]-[[:digit:]][[:digit:]]-",""))) %>% 
  mutate(dosips = str_replace_all(dosips,pattern = "[[:digit:]][[:digit:]]$",replacement = Year_sips)) %>% 
  mutate(dosips = as.Date(dosips,format = "%d-%m-%Y")) %>% 
  mutate(age_at_sips_days = dosips - DOBIRTH) %>% 
  mutate(age_at_sips_days = as.numeric(str_remove_all(age_at_sips_days,pattern = " days"))) %>% 
  mutate(age_at_sips_years = age_at_sips_days/365.25) 

sips_long_z %>% 
  filter(Diagnosis != goassessDxpmr7) %>% 
  View()

theme_set(theme_minimal())
theme_update(text = element_text(size = 14))

p_plot <- sips_long_z %>% 
  ggplot(aes(x = age_at_sips_years,y = p_avg,color = goassessDxpmr7)) + geom_point(size = .5) + geom_smooth() + geom_line(aes(group = bblid),alpha = .3) + labs(x = "Age",y = "Positive Symptoms (Z-scored)",color = "Diagnosis") + scale_color_brewer(palette = "Dark2")

n_plot <- sips_long_z %>% 
  ggplot(aes(x = age_at_sips_years,y = n_avg,color = goassessDxpmr7)) + geom_point(size = .5) + geom_smooth() + geom_line(aes(group = bblid),alpha = .3) + labs(x = "Age",y = "Negative Symptoms (Z-scored)",color = "Diagnosis") + scale_color_brewer(palette = "Dark2")

d_plot <- sips_long_z %>% 
  ggplot(aes(x = age_at_sips_years,y = d_avg,color = goassessDxpmr7)) + geom_point(size = .5) + geom_smooth() + geom_line(aes(group = bblid),alpha = .3) + labs(x = "Age",y = "Disorganized Symptoms (Z-scored)",color = "Diagnosis") + scale_color_brewer(palette = "Dark2")

g_plot <- sips_long_z %>% 
  ggplot(aes(x = age_at_sips_years,y = g_avg,color = goassessDxpmr7)) + geom_point(size = .5) + geom_smooth() + geom_line(aes(group = bblid),alpha = .3) + labs(x = "Age",y = "General Symptoms (Z-scored)",color = "Diagnosis") + scale_color_brewer(palette = "Dark2")

all_sym_plots <- annotate_figure(ggarrange(p_plot,n_plot,d_plot,g_plot,common.legend = T,legend = "bottom"),fig.lab = "Clinical Symptoms by Diagnosis",fig.lab.size = 20,fig.lab.face = "bold")

gaf_plot <- sips_long_z %>% 
  filter(gaf_c > 0) %>% 
  ggplot(aes(x = age_at_sips_years,y = gaf_c,color = goassessDxpmr7)) + geom_point(size = .5) + geom_smooth() + geom_line(aes(group = bblid),alpha = .3) + labs(x = "Age",y = "Current Functioning",title = "Global Assessment of Functioning by Diagnosis",color = "Diagnosis") + scale_color_brewer(palette = "Dark2")

pdf(file = "/Users/hillmann/Projects/Evolution/Plots:Results/Evolution_Progress_Report_Clinical_Plots.pdf",width = 14,height = 8)
all_sym_plots
gaf_plot
dev.off()

# Now bring in the CNB data 

Evol_bblids <- unique(sips_long$bblid)

CNB_evol <- CNB_mega %>% 
  filter(test_sessions.bblid.clean %in% Evol_bblids) %>% 
  select(test_sessions.bblid.clean,test_sessions_v.age,test_sessions_v.gender,matches("_cr$"),matches("_rtcr$"),tap_tot,pcet_acc2,cpt_tprt,cpt_ptp,lnb_mcr,lnb_mrtc,pmat_pc,medf_pc,adt_pc,plot_pc) %>% 
  select(!(matches("_w_rtcr$"))) %>% 
  left_join(sips_diag_full[,c("BBLID","Diagnosis")],by = c('test_sessions.bblid.clean' = "BBLID")) %>% 
  rename(PS = Diagnosis)

# Use codebook to build data frame which maps test acronyms to test names
Test_map <- data.frame('Prefix' = c("er40","pvrt","volt","cpf","cpw","gng","mpraxis","pcet","pmat","medf","adt","plot","tap","cpt","lnb"),
                       "Test_name" = c("Penn Emotion Recognition Test","Penn Verbal Reasoning Test","Visual Object Learning Test","Penn Face Memory Test",'Penn Word Memory Test',"Go-No-Go Test","Motor Praxis Test","Penn Conditional Exclusion Test","Penn Matrix Analysis Test","Measured Emotion Differentiation Test","Age Differentiation Test","Penn Line Orientation Test","Penn Computerized Finger Tapping Test",
                                       "Penn Continuous Performance Test","Letter-N-Back Test"))

# Use codebook to map measurements to longer names
Metric_map <- data.frame("Suffix" = c("_cr","_rtcr","_tot","_acc2","_tprt","_ptp","_mcr","_mrtc","_pc"),
                         "Label" = c("Correct Responses","Median Reaction Time \n Correct Responses (ms)","Total Taps","Accuracy",
                                     "Median Response Time \n True Positives (ms)","True Positive","Total True Positive Responses","Median Response Time \n Correct Responses","Correct Responses (%)"))


# Create Longitudinal Plots for each test 

response_cols <- CNB_evol %>% 
  select(er40_cr:plot_pc) %>% 
  colnames()
CNB_evol_plots <- list()
Plot_sep_sex <- list()
Plot_sep_PS <- list()
Plot_sep_sex_PS <- list()
cntr <- 1
theme_set(theme_minimal())
theme_update(text = element_text(size = 18),legend.position = "bottom")

for(test in response_cols){
  test_quo <- quo(!!sym(test))
  test_split <- str_split(test,pattern = "_")[[1]]
  test_prefix <- test_split[1]
  test_suffix <- paste0("_",test_split[length(test_split)])
  
  Plot_title <- Test_map %>% 
    filter(Prefix == test_prefix) %>% 
    pull(Test_name)
  
  ylabel <- Metric_map %>% 
    filter(Suffix == test_suffix) %>% 
    pull(Label)
  
  # Cap values at 6sd above the norm
  CNB_evol[[test]] <- ifelse(CNB_evol[[test]] > mean(CNB_evol[[test]],na.rm = T) + 6*sd(CNB_evol[[test]],na.rm = T),mean(CNB_evol[[test]],na.rm = T) + 6*sd(CNB_evol[[test]],na.rm = T),CNB_evol[[test]])
  
  # Find N for each test
  
  Sex_N_timepoints <- CNB_evol %>% 
    filter(!is.na(!!test_quo),!is.na(test_sessions_v.gender)) %>% 
    nrow()
  
  Sex_N_subj <-  CNB_evol %>% 
    filter(!is.na(!!test_quo),!is.na(test_sessions_v.gender)) %>% 
    with(length(unique(test_sessions.bblid.clean)))
  
  PS_N_timepoints <- CNB_evol %>% 
    filter(!is.na(!!test_quo),!is.na(PS)) %>% 
    nrow()
  
  PS_N_subj <-  CNB_evol %>% 
    filter(!is.na(!!test_quo),!is.na(PS)) %>% 
    with(length(unique(test_sessions.bblid.clean)))
  
  Sex_PS_N_timepoints <- CNB_evol %>% 
    filter(!is.na(!!test_quo),!is.na(PS),!is.na(test_sessions_v.gender)) %>% 
    nrow()
  
  Sex_PS_N_subj <-  CNB_evol %>% 
    filter(!is.na(!!test_quo),!is.na(PS),!is.na(test_sessions_v.gender)) %>% 
    with(length(unique(test_sessions.bblid.clean)))
  
  
  # Create three plots for sex, PS, and sex by PS effects
  
  df_for_plot <- CNB_evol %>% 
    rename(Sex = test_sessions_v.gender) %>% 
    rename(Age = test_sessions_v.age) %>% 
    rename(bblid = test_sessions.bblid.clean) %>% 
    mutate(Sex = case_when(Sex == "M" ~ "Male",Sex == "F" ~ "Female",TRUE ~ NA_character_)) %>% 
    mutate(PS = factor(PS,levels = c("TD","OP","PS"))) %>% 
    filter(!is.na(Sex),!is.na(PS)) %>% 
    mutate(Sex_PS = paste(Sex,PS)) %>% 
    mutate(Sex_PS = factor(Sex_PS,levels = c("Male TD","Male OP","Male PS",'Female TD',"Female OP","Female PS")))
  
  Plot_sep_sex[[cntr]] <- df_for_plot %>% 
    ggplot(aes(x = Age,y = !!test_quo,color = Sex,group = bblid)) + geom_smooth(aes(x = Age,y = !!test_quo,color = Sex,group = Sex)) + geom_point(size = .25) + geom_line(alpha = .25) + labs(x = "Age",y = ylabel,title = Plot_title,caption = paste0("N = ",Sex_N_subj,", Timepoints = ",Sex_N_timepoints)) + scale_color_manual(values = c("#d7191c","#2b83ba")) 
  
  Plot_sep_PS[[cntr]] <- df_for_plot %>% 
    ggplot(aes(x = Age,y = !!test_quo,color = PS,group = bblid)) + geom_smooth(aes(x = Age,y = !!test_quo,color = PS,group = PS)) + geom_point(size = .25) + geom_line(alpha = .25) + labs(x = "Age",y = ylabel,title = Plot_title,caption = paste0("N = ",PS_N_subj,", Timepoints = ",PS_N_timepoints),color = "") + scale_color_brewer(palette = "Dark2") 
  
  Plot_sep_sex_PS[[cntr]] <- df_for_plot %>% 
    ggplot(aes(x = Age,y = !!test_quo,color = Sex_PS,group = bblid)) + geom_smooth(aes(x = Age,y = !!test_quo,color = Sex_PS,group = Sex_PS),se = F,alpha = 2) + geom_point(size = .25) + geom_line(alpha = .25) + labs(x = "Age",y = ylabel,title = Plot_title,caption = paste0("N = ",Sex_PS_N_subj,", Timepoints = ",Sex_PS_N_timepoints),color = "") + 
    theme(legend.position = "bottom") + scale_color_manual(values = c("#6baed6","#2171b5","#08306b","#fc9272","#cb181d","#67000d")) + guides(color = guide_legend(nrow = 1))
  
  
  CNB_evol_plots[[cntr]] <- annotate_figure(ggarrange(Plot_sep_sex[[cntr]],Plot_sep_PS[[cntr]],Plot_sep_sex_PS[[cntr]],labels = c("A","B","C")))
  
  cntr <- cntr + 1
} 

pdf(file = "/Users/hillmann/Projects/Evolution/Plots:Results/Evolution_Progress_Report_CNB_PSPlots.pdf",width = 14,height = 8)
ggarrange(Plot_sep_PS[[2]] + labs(caption = ""),Plot_sep_PS[[4]] + labs(caption = ""),Plot_sep_PS[[25]] + labs(caption = ""),Plot_sep_PS[[28]] + labs(caption = ""),common.legend = T,legend = "bottom")
Plot_sep_PS[[1]]
Plot_sep_PS[[2]]
Plot_sep_PS[[3]]
Plot_sep_PS[[4]]
Plot_sep_PS[[5]]
Plot_sep_PS[[6]]
Plot_sep_PS[[7]]
Plot_sep_PS[[8]]
Plot_sep_PS[[9]]
Plot_sep_PS[[10]]
Plot_sep_PS[[11]]
Plot_sep_PS[[12]]
Plot_sep_PS[[13]]
Plot_sep_PS[[14]]
Plot_sep_PS[[15]]
Plot_sep_PS[[16]]
Plot_sep_PS[[17]]
Plot_sep_PS[[18]]
Plot_sep_PS[[19]]
Plot_sep_PS[[20]]
Plot_sep_PS[[21]]
Plot_sep_PS[[22]]
Plot_sep_PS[[23]]
Plot_sep_PS[[24]]
Plot_sep_PS[[25]]
Plot_sep_PS[[26]]
Plot_sep_PS[[27]]
Plot_sep_PS[[28]]
dev.off()
