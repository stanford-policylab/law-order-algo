#!/usr/bin/env Rscript
# Load and clean smaller version of North Carolina data

library(tidyverse)
library(lubridate)

SOURCE_RDS <- "../data/nc_full.rds"
TARGET_RDS <- "../data/nc_sample.rds"
SAMPLE_SIZE <- 1e6

# Read data ---------------------------------------------------------------
# Original data available from
# https://openpolicing.stanford.edu/data/
full_df <- read_rds(SOURCE_RDS)

cat(sprintf("Starting with %.0f rows\n", nrow(full_df)))

# Process and clean -------------------------------------------------------
keep_cols <- c(
    # Stop characteristics
    "id", "officer_id",
    "stop_date", "stop_time", 
    "police_department", "county_name", 
    "violation", "stop_outcome",

    # Driver demographics
    "driver_race", "driver_age", "driver_gender",
    
    # Search reasons
    "search_conducted",
    "search_type", "search_basis",

    # Search outcomes
    "contraband_found"
)

clean_df <- full_df %>%
  select(!!!keep_cols) %>%
  filter(
    police_department == "NC State Highway Patrol",
    year(stop_date) >= 2008,
    !is.na(county_name)
  )

# Sample and save ---------------------------------------------------------
cat(sprintf("Sampling %d rows\n", SAMPLE_SIZE))
set.seed(94305)
sample_df <- clean_df %>%
  sample_n(SAMPLE_SIZE)

# Save data
message("\nSaving clean data file to:", TARGET_RDS)
write_rds(sample_df, TARGET_RDS)