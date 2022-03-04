library(tableone)
library(lubridate)
library(dplyr)

if(!file.exists('data.R.rdata')) system('R -f data.R',ignore.stdout = T,ignore.stderr = T,wait = T);
load('data.R.rdata');

data_dem_admi <- ADMISSIONS %>%
  group_by(subject_id) %>%
  summarize(insurance = first(insurance),
            admittime = max(admittime),
            language = first(language),
            religion = first(religion),
            marital_status = first(marital_status),
            ethnicity = first(ethnicity))



demography <- merge(x=PATIENTS , y=data_dem_admi, by = "subject_id") %>%
  mutate(age=(dob %--% admittime) %/% years(1),
         age=if_else(age==300, 90, age)) %>%
  select(-c(dob, admittime,dod, dod_hosp, dod_ssn))



CreateTableOne(data = demography)
