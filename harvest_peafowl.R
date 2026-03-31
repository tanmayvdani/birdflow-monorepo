# Data Harvest Script for Amur Falcon (Falco amurensis)
# This script prepares BirdFlow data for the migration window through India.

library(ebirdst)
library(BirdFlowR)
library(terra)

# --- 1. CONFIGURATION ---
species_code <- "amufal1" 
output_directory <- "./training_data"
if (!dir.exists(output_directory)) dir.create(output_directory)

# --- 2. eBird API KEY SETUP ---
# set_ebirdst_access_key("s8fo07vohdq1")

# --- 3. DEFINE STUDY AREA (Indian Subcontinent) ---
# Lon [65, 100], Lat [5, 40]
india_extent <- ext(65, 100, 5, 40)
india_poly <- as.polygons(india_extent, crs = "EPSG:4326")

# --- 4. DATA DOWNLOAD ---
message("Ensuring eBird Status data is downloaded for: ", species_code)
ebirdst_download_status(species_code, download_ranges = TRUE)

# --- 5. PREPROCESSING ---
message("Preprocessing Amur Falcon data (Autumn Migration: Weeks 40-52)...")

# We truncate to weeks 40-52 because the species is absent from India 
# during the rest of the year. BirdFlow requires presence in all modeled weeks.

bf_prepped <- preprocess_species(
  species = species_code,
  res = 27,
  clip = india_poly,
  hdf5 = TRUE,
  out_dir = output_directory,
  overwrite = TRUE,
  skip_quality_checks = TRUE,
  start = 40, # October
  end = 52    # December
)

message("Preprocessing complete. HDF5 generated in: ", output_directory)
