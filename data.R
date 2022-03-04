#' ---
#' title: "MIMIC-III: Infectious Disease ICU Mortality"
#' author: 'Gabriel Catano11'
#' abstract: |
#'   | Merging and cleanup of CMS and Census data, with some preliminary
#'   | unsupervised variable selection
#' documentclass: article
#' description: 'Manuscript'
#' clean: false
#' self_contained: true
#' number_sections: false
#' keep_md: true
#' fig_caption: true
#' css: 'production.css'
#' output:
#'   html_document:
#'     toc: true
#'     toc_float: true
#' ---
#+ init, echo=FALSE, message=FALSE, warning=FALSE,results='hide'
# Init ----
debug <- 0;
knitr::opts_chunk$set(echo=debug>0, warning=debug>0, message=debug>0);

# Global project settings ----
inputdata <- c(mimic3='https://physionet.org/static/published-projects/mimiciii-demo/mimic-iii-clinical-database-demo-1.4.zip');
dataextractdir <- file.path('data','mimic-iii-clinical-database-demo-1.4');

source('config.R',local=T,echo=debug>0);
# inputdata <- c(dat0='data/SIM_SDOH_ZCTA.xlsx'          # census data by ZCTA
#                ,cx0='data/SIM_ALLCMS.csv'              # RSA-ZCTA crosswalk
#                ,rsa0='data/SIM_RSAv4 SCD RSRs.csv'     # outcomes (RSR)
#                ,dct0='data/data_dictionary.csv'        # data dictionary for the
#                                                        # dat1 dataset that _this_
#                                                        # scriport produces
#                ,dat1='SDOH_RSR_201X_prelim.csv'        # the dat1 dataset
#                ,dat2='SDOH_RSR_201X_scaled_prelim.csv' # the scaled version of
#                                                        # dat1
# );

# Load libraries ----
library(rio); library(dplyr); library(tidyr); # data handling
library(printr); # printing tables inline


# Local project settings ----
# overwrite previously set global values if needed
if(file.exists('local.config.R')){
  source('local.config.R',local=TRUE,echo = debug>0);
  if(exists('.local.inputdata')){
    inputdata <- replace(inputdata,names(.local.inputdata),.local.inputdata)};
};

# Local functions ----

# Load data ----
# If data is not already there, download it.
if(length(setdiff(c('ADMISSIONS.csv','CALLOUT.csv','CAREGIVERS.csv','CHARTEVENTS.csv','CPTEVENTS.csv','D_CPT.csv','D_ICD_DIAGNOSES.csv','D_ICD_PROCEDURES.csv','D_ITEMS.csv','D_LABITEMS.csv','DATETIMEEVENTS.csv','DIAGNOSES_ICD.csv','DRGCODES.csv','ICUSTAYS.csv','INPUTEVENTS_CV.csv','INPUTEVENTS_MV.csv','LABEVENTS.csv','MICROBIOLOGYEVENTS.csv','NOTEEVENTS.csv','OUTPUTEVENTS.csv','PATIENTS.csv','PRESCRIPTIONS.csv','PROCEDUREEVENTS_MV.csv','PROCEDURES_ICD.csv','SERVICES.csv','TRANSFERS.csv')
                  ,list.files(dataextractdir,pattern='*.csv')))>0){
  if(!file.exists('data/mimic_iii.zip')) download.file(inputdata['mimic3'],'data/mimic_iii.zip');
  unzip('data/mimic_iii.zip',exdir='data');
}

# Example of how to import individual tables into R after downloading
ADMISSIONS <- import(file.path(dataextractdir,'ADMISSIONS.csv'));
PATIENTS <- import(file.path(dataextractdir,'PATIENTS.csv'));
DIAGNOSES_ICD <- import(file.path(dataextractdir,'DIAGNOSES_ICD.csv'));
CPTEVENTS <- import(file.path(dataextractdir,'CPTEVENTS.csv'));
MICROBIOLOGYEVENTS <- import(file.path(dataextractdir,'MICROBIOLOGYEVENTS.csv'));
LABEVENTS <- import(file.path(dataextractdir,'LABEVENTS.csv'));
D_LABITEMS <- import(file.path(dataextractdir,'D_LABITEMS.csv'));

#' # Data transformation
#'
#' These tables seem to behave like a relational database-- different types of
#' data get their own tables, to be joined as needed based on columns that end
#' in the suffix `_id`. When there are many variables, e.g. different types of
#' diagnoses, the data is in tall-skinny format. I.e. instead of one column per
#' diagnosis code, there is one column for all the codes. Random forest needs
#' to have each variable in its own column and each subject in its own row. So
#' here is an example of how we can use the `pivot_wider()` to transform the
#' data from tall format to wide format.
#'
#+ diagnoses_pivot
dat0 <- select(DIAGNOSES_ICD,c('subject_id','hadm_id','icd9_code')) %>%
  mutate('obs'=1) %>%
  pivot_wider(names_from=icd9_code # this is the column that gets split into individual columns
              ,names_prefix = 'ICD9_',values_fill = 0
              ,values_from = obs # this is the column that says how many cases were observed (for diagnoses always 1)
              ) %>% arrange(subject_id,hadm_id);
head(dat0);

#' # Data exploration
#'
#'  Example of examining the frequencies of a discrete variable


table(ADMISSIONS$diagnosis) %>% sort(decreasing = T) %>% cbind %>% head(14)