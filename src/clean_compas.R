#!/usr/bin/env Rscript
# Load and clean COMPAS data

library(tidyverse)


# Original, full COMPAS data from ProPublica
SOURCE_CSV <- "https://github.com/propublica/compas-analysis/raw/master/compas-scores-two-years.csv"
TARGET_RDS <- "../data/compas.rds"

# Read data ---------------------------------------------------------------
origin_df <- read_csv(SOURCE_CSV)

cat(sprintf("Starting with %.0f rows\n", nrow(origin_df)))

# Rename/normalize columns ------------------------------------------------
cn <- colnames(origin_df)

# Process and clean -------------------------------------------------------
clean_df <- origin_df %>%
  filter(race %in% c("Caucasian", "African-American")) %>%
  select(id, sex, dob, age, race,
         recid_score = decile_score,
         violence_score = v_decile_score,
         priors_count,
         is_recid,
         is_violent_recid) %>%
  filter(complete.cases(.))

# Save --------------------------------------------------------------------
# Save data
message("\nSaving clean data file to:", TARGET_RDS)
write_rds(clean_df, TARGET_RDS)
