#!/usr/bin/env Rscript
# Load and clean smaller version of SQF data

library(tidyverse)


SOURCE_RDS <- "/share/data/di/sqf/stops.rds"
TARGET_RDS <- "../data/sqf_sample.rds"
SAMPLE_SIZE <- 1e5

# Read data ---------------------------------------------------------------
# Original, full data frame, available from
# https://5harad.com/data/sqf.RData
full_df <- read_rds(SOURCE_RDS)

cat(sprintf("Starting with %.0f rows\n", nrow(full_df)))

# Rename/normalize columns ------------------------------------------------
cn <- colnames(full_df)
new_cn <- gsub("\\.", "_", cn)
new_cn <- gsub("stopped_bc", "stop_reason", new_cn)
new_cn <- gsub("frisked_bc", "frisk_reason", new_cn)
new_cn <- gsub("identification", "suspect_id_type", new_cn)

names(full_df) <- new_cn

keep_cols <- c(
    # Stop characteristics
    "id", "year", "date", "time", "precinct", "location_housing",
    "suspected_crime",

    # Stop reason
    "stop_reason_object", "stop_reason_desc", "stop_reason_casing",
    "stop_reason_lookout", "stop_reason_clothing", "stop_reason_drugs",
    "stop_reason_furtive", "stop_reason_violent", "stop_reason_bulge",
    "stop_reason_other",

    # Suspect demographics
    "suspect_dob", "suspect_id_type",
    "suspect_sex", "suspect_race", "suspect_hispanic",
    "suspect_age", "suspect_height", "suspect_weight", "suspect_hair",
    "suspect_eye", "suspect_build",
    "reason_explained", "others_stopped",

    # Force columns
    "force_hands", "force_wall", "force_ground", "force_drawn", "force_pointed",
    "force_baton", "force_handcuffs", "force_pepper", "force_other",

    # Other actions
    "arrested", "summons_issued",
    "officer_uniform", "officer_verbal", "officer_shield",

    # Frisk reason
    "frisked",
    "frisk_reason_suspected_crime", "frisk_reason_weapons",
    "frisk_reason_attire", "frisk_reason_actual_crime",
    "frisk_reason_noncompliance", "frisk_reason_threats", "frisk_reason_prior",
    "frisk_reason_furtive", "frisk_reason_bulge",

    # Search reasons
    "searched",
    "searched_hardobject", "searched_outline", "searched_admission",
    "searched_other",

    # Additional circumstances/factors
    "additional_report", "additional_investigation", "additional_proximity",
    "additional_evasive", "additional_associating", "additional_direction",
    "additional_highcrime", "additional_time", "additional_sights",
    "additional_other",

    # Search outcomes
    "found_weapon",
    "found_pistol", "found_rifle", "found_assault",
    "found_knife", "found_machinegun", "found_other", "found_gun",
    "found_contraband",

    "extra_reports"
)

# Process and clean -------------------------------------------------------
clean_df <- full_df %>%
  select(!!!keep_cols) %>%
  filter(year >= 2008, year <= 2011) %>%
  mutate(
    hour = substring(time, 1, 2),
    month = substring(date, 6, 7),
    year = as.character(year),
    suspect_race = factor(
      plyr::mapvalues(
        suspect_race,
        c('black', 'black hispanic', 'white', 'white hispanic'),
        c('black', 'hispanic', 'white', 'hispanic')),
      c('white','black', 'hispanic'))
  ) %>%
  filter(!is.na(suspect_race),
         !is.na(suspect_sex),
         complete.cases(.)) %>%
  mutate_at(vars(found_weapon, frisked), funs(as.logical)) %>%
  mutate(suspected_crime = fct_lump(suspected_crime, 10, other_level = "other"),
         suspect_hair = fct_lump(suspect_hair, 8, other_level = "other"),
         suspect_eye = fct_lump(suspect_eye, 8, other_level = "other"))

# Sample and save ---------------------------------------------------------
cat(sprintf("Sampling %d rows\n", SAMPLE_SIZE))
set.seed(94305)
sample_df <- clean_df %>%
  sample_n(SAMPLE_SIZE)

# Save data
message("\nSaving clean data file to:", TARGET_RDS)
write_rds(sample_df, TARGET_RDS)
