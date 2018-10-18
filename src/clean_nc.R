#!/usr/bin/env Rscript
# Load and clean smaller version of North Carolina data

library(tidyverse)
library(lubridate)

# SOURCE_RDS <- "../data/nc_full.rds"
SOURCE_RDS <- "/share/data/opp/data/states/nc/statewide/clean/statewide.rds"
TARGET_RDS <- "../data/nc_sample.rds"
SAMPLE_SIZE <- 1e6

# Read data ---------------------------------------------------------------
full_df <- read_rds(SOURCE_RDS)$data

cat(sprintf("Starting with %.0f rows\n", nrow(full_df)))

# Process and clean -------------------------------------------------------
keep_cols <- c(
    # Stop characteristics
    "date", "time", 
    "department_name",
    "reason_for_stop",

    # Driver demographics
    "subject_race", "subject_age", "subject_sex",
    
    # Search reasons
    "search_conducted",
    "reason_for_search", "search_basis",

    # Search outcomes
    "contraband_found",
    
    # Stop outcomes
    "arrest_made", "citation_issued", "warning_issued"
)

clean_df <- 
  full_df %>%
  select(!!!keep_cols) %>%
  filter(year(date) >= 2009, year(date) <= 2015) %>%
  mutate(subject_race = as.character(
    plyr::mapvalues(
      subject_race, 
      from = c("asian/pacific islander", "other/unknown"), 
      to = c("asian", "other")
    )
  )) %>%
  filter(subject_race != "other") %>%
  rename(
    driver_race = subject_race,
    driver_gender = subject_sex,
    driver_age = subject_age,
    police_department = department_name
  )

# Use the top 100 most active police departments (not state patrol)
active_departments <-
  clean_df %>%
  filter(police_department != "NC State Highway Patrol") %>%
  count(police_department, sort = TRUE) %>%
  mutate(rank = 1:n()) %>%
  filter(rank <= 100) %>%
  pull(police_department)
clean_df <-
  clean_df %>%
  filter(police_department %in% active_departments)

# Sample and save ---------------------------------------------------------
cat(sprintf("Sampling %d rows\n", SAMPLE_SIZE))
set.seed(94305)
sample_df <- clean_df %>%
  sample_n(SAMPLE_SIZE)

# Save data
message("\nSaving clean data file to: ", TARGET_RDS)
write_rds(sample_df, TARGET_RDS)