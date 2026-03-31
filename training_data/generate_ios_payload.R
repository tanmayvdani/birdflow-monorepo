# Generate iOS HomeDataPayload for Amur Falcon (Fixed Distribution Sampling)
# This script extracts the trained BirdFlow data for the iOS Team.

library(BirdFlowR)
library(jsonlite)
library(terra)

# 1. LOAD THE FITTED MODEL
model_path <- "training_data/amufal1_2023_27km_obs1.0_ent0.0001_dist0.01_pow0.4.hdf5"
if (!file.exists(model_path)) stop("Model file not found!")
bf <- import_birdflow(model_path)

# 2. DEFINE REAL HOTSPOTS (Example locations)
real_hotspots <- data.frame(
  hotspotId = c("Pangti-Nagaland", "Doyang-Reservoir", "Umrangso-Assam", "Lonavala-Roost"),
  lat = c(26.21, 26.20, 25.51, 18.75),
  lon = c(94.13, 94.25, 92.74, 73.40)
)

# 3. HELPER TO CONVERT X/Y TO LAT/LON
convert_to_latlon <- function(x, y, model_crs) {
  pt <- vect(matrix(c(x, y), ncol = 2), crs = model_crs)
  pt_ll <- project(pt, "EPSG:4326")
  ll_matrix <- crds(pt_ll)
  return(list(lat = as.numeric(ll_matrix[1, "y"]), lon = as.numeric(ll_matrix[1, "x"])))
}

# 4. GENERATE MEDIAN PATH (Timesteps 1-13)
timesteps <- 1:13
model_crs <- crs(bf)

trajectory_paths <- lapply(timesteps, function(ts) {
  distr <- get_distr(bf, ts)
  max_i <- which.max(distr)
  
  xy <- i_to_xy(max_i, bf)
  ll <- convert_to_latlon(xy$x, xy$y, model_crs)
  
  iso_week <- bf$dates$week[ts]
  
  list(
    week = iso_week,
    lat = ll$lat,
    lon = ll$lon,
    probability = as.integer(distr[max_i] * 100) 
  )
})

# 5. SCORE REAL HOTSPOTS for Week 45 (Timestep 6)
request_timestep <- 6
current_distr <- get_distr(bf, request_timestep)

hotspot_scores <- lapply(1:nrow(real_hotspots), function(i) {
  # Convert lat/lon to x/y first in model's projection
  pt <- vect(matrix(c(real_hotspots$lon[i], real_hotspots$lat[i]), ncol = 2), crs = "EPSG:4326")
  pt_xy <- project(pt, model_crs)
  xy_matrix <- crds(pt_xy)
  
  # Get the cell index 'i' for these coordinates
  # Using xy_to_i(x, y, bf)
  target_i <- xy_to_i(xy_matrix[1, "x"], xy_matrix[1, "y"], bf)
  
  # Sample the probability value from the distribution
  prob <- current_distr[target_i]
  
  list(
    hotspotId = real_hotspots$hotspotId[i],
    probability = as.integer(prob * 100)
  )
})

# 6. ASSEMBLE THE FINAL PAYLOAD
payload <- list(
  birdId = "AMUFAL1-UUID",
  startWeek = 40,
  endWeek = 52,
  trajectoryPaths = trajectory_paths,
  hotspotScores = hotspot_scores
)

# 7. EXPORT
write_json(payload, "AmurFalcon_iOS_Payload.json", auto_unbox = TRUE, pretty = TRUE)

message("Payload generated: AmurFalcon_iOS_Payload.json")
