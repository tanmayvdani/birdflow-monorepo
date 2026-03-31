# process_birdflow.R

library(BirdFlowR)

# Path to the BirdFlowPy training script (relative to this file's location)
PYTHON_SCRIPT <- file.path("BirdFlowPy", "update_hdf.py")
OUTPUT_DIR    <- "training_data"

# 1. Load the species list
bird_data <- read.csv("available_migrants_list.csv", stringsAsFactors = FALSE)
all_species_codes <- bird_data[["species_code"]]

# 2. State Management: Setup the Pause/Resume tracker
log_file <- "completed_birds.txt"

if (file.exists(log_file)) {
  completed_species <- readLines(log_file)
  message(paste("Found log file. Resuming... already completed", length(completed_species), "birds."))
} else {
  completed_species <- character(0)
  message("No previous log found. Starting fresh.")
}

# 3. Execute the processing loop
for (species_code in all_species_codes) {

  # Check if we should skip (Resume logic)
  if (species_code %in% completed_species) {
    message(paste("Skipping", species_code, "- already processed."))
    next
  }

  message(paste("Processing", species_code, "..."))

  # Robust error handling so one failure doesn't crash the batch
  tryCatch({

    # Step 1: Preprocess eBird Status & Trends data into a template HDF5.
    # Downloads rasters for this species and writes
    # <species>_<year>_<res>km.hdf5 into OUTPUT_DIR, ready for model fitting.
    bf <- preprocess_species(
      species  = species_code,
      out_dir  = OUTPUT_DIR,
      overwrite = TRUE
    )

    # Derive the preprocessed filename using the same naming convention
    # that update_hdf.py expects: <species>_<year>_<res>km.hdf5
    ebirdst_year <- bf$metadata$ebird_version_year
    res_km       <- round(res(bf)[1] / 1000)

    hdf_src <- file.path(OUTPUT_DIR,
                         paste0(species_code, "_", ebirdst_year, "_", res_km, "km.hdf5"))

    if (!file.exists(hdf_src)) {
      stop("Expected preprocessed HDF5 not found: ", hdf_src)
    }

    # Step 2: Fit the BirdFlow model via the BirdFlowPy trainer.
    # update_hdf.py reads the template HDF5, trains transition matrices via
    # JAX/Haiku, and writes the fitted model alongside the source as:
    # <species>_<year>_<res>km_obs<obs>_ent<ent>_dist<dist>_pow<pow>.hdf5
    exit_code <- system2(
      "python",
      args = c(
        PYTHON_SCRIPT,
        OUTPUT_DIR,    # root directory
        species_code,  # species code
        res_km,        # resolution (integer km)
        "--obs_weight=1.0",
        "--dist_weight=0.01",
        "--ent_weight=0.0001",
        "--dist_pow=0.4",
        paste0("--ebirdst_year=", ebirdst_year)
      )
    )

    if (exit_code != 0) {
      stop("update_hdf.py exited with code ", exit_code)
    }

    # Log success immediately so state is saved after every species
    write(species_code, file = log_file, append = TRUE)
    message(paste("Successfully completed and logged:", species_code))

  }, error = function(e) {
    # If a species fails (e.g., download timeout), log the error but keep going
    message(paste("Error processing", species_code, ":", e$message))
  })
}

message("All species processed.")
