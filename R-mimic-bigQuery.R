# BigQuery - MIMIC-IV - RUN AS JOB (defaults)

library(dplyr)
library(bigrquery) # bigQ
library(lubridate)

# provides GOOGLE_EMAIL,PROJECTID, and SQLQUERY00
source('config.R');
if(file.exists('local.config.R')) source('local.config.R');

message(as.character(Sys.time()),"Conectando a BigQuery service \n")

options(gargle_oauth_email = GOOGLE_EMAIL)

# fecha actual ----
hoy <- lubridate::today()

bq_auth(); # This may prompt you for which pre-authorized credentials to use
tb <- bq_project_query(PROJECTID, SQLQUERY00);

# Ejecutar query & crear dataframe ----
message(as.character(Sys.time()),"Ejecutando query... \n")

dat1 <- bq_table_download(tb) # ej. max_results = 1000
save(dat1,file=inputdata);
