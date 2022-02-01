#' ---
#' title: "MIMIC-III: Infectious Disease ICU Mortality"
#' author: 'Gabriel Catano'
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
library(rio); library(dplyr);   # data handling
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

#' # Data exploration
# Example of how to import individual tables into R after downloading
ADMISSIONS <- import(file.path(dataextractdir,'ADMISSIONS.csv'));
PATIENTS <- import(file.path(dataextractdir,'PATIENTS.csv'));
DIAGNOSES_ICD <- import(file.path(dataextractdir,'DIAGNOSES_ICD.csv'));
# Example of examining the frequencies of a discrete variable
table(ADMISSIONS$diagnosis) %>% sort(decreasing = T) %>% cbind %>% head(14)