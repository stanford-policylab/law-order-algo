#!/usr/bin/env Rscript
# Load and clean COMPAS data

library(tidyverse)


SOURCE_CSV <- "../data/compas_scores_raw.csv"
TARGET_RDS <- "../data/compas.rds"

# Read data ---------------------------------------------------------------
# Original, full data frame, available from
# https://raw.githubusercontent.com/propublica/compas-analysis/master/compas-scores-raw.csv
origin_df <- read_csv(SOURCE_CSV)

cat(sprintf("Starting with %.0f rows\n", nrow(origin_df)))

# Rename/normalize columns ------------------------------------------------
cn <- colnames(origin_df)
new_cn <- gsub("\\.", "_", cn)
new_cn <- tolower(new_cn)

names(origin_df) <- new_cn

map_score_type <- c(
    `Risk of Violence` = "violence",
    `Risk of Recidivism` = "recidivism",
    `Risk of Failure to Appear` = "fta"
)

# Process and clean -------------------------------------------------------
clean_df <- origin_df %>%
  filter(scaleset == "Risk and Prescreen") %>%
  mutate(score_type = map_score_type[displaytext]) %>%
  select(person_id,
         assessment_id = assessmentid,
         case_id,
         dob = dateofbirth,
         sex = sex_code_text,
         score_type, decilescore) %>%
  spread(score_type, decilescore)


# Save --------------------------------------------------------------------
# Save data
message("\nSaving clean data file to:", TARGET_RDS)
write_rds(clean_df, TARGET_RDS)
