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
source('config.R');
if(file.exists('local.config.R')) source('local.config.R');

# Load libraries ----
library(rio); library(dplyr); library(tidyr); # data handling
library(printr); # printing tables inline
library(rsample); # sampling
library(tableone)
library(lubridate)
library(dplyr)

# Load data ----
if(!file.exists(inputdata)){
  system('R -f R-mimic-bigQuery.R',ignore.stdout = T,ignore.stderr = T,wait = T)
};
load(inputdata);
