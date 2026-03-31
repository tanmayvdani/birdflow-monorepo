library(ebirdst)
library(dplyr)

# 1. Load the full eBird Status & Trends metadata
data("ebirdst_runs")

message("Total species in database: ", nrow(ebirdst_runs))

# 2. Filter for "Good Enough" Candidates
# Criteria:
# - Must NOT be a resident (is_resident == FALSE)
# - (Optional) You could filter by breeding_quality if that column existed, 
#   but usually is_resident is the main check for BirdFlow.
migrants <- ebirdst_runs %>%
  filter(is_resident == FALSE) %>%
  select(species_code, common_name, scientific_name) %>%
  arrange(common_name)

message("Total MIGRATORY species available: ", nrow(migrants))

# 3. Export to CSV (The "Menu")
# This creates a file you can open in Excel to pick your bird.
write.csv(migrants, "available_migrants_list.csv", row.names = FALSE)

# 4. Show a "Sampler Platter" of categories likely relevant to India
# We filter by name just to show you quick options in the console
cat("\n--- QUICK PICKS (Found in the list) ---\n")

# A. Ducks & Geese (Classic migrants)
ducks <- migrants %>% 
  filter(grepl("Duck|Goose|Teal|Pintail|Garganey", common_name)) %>%
  head(5)
print(ducks)

# B. Raptors (Falcons, Harriers, Eagles)
raptors <- migrants %>% 
  filter(grepl("Harrier|Falcon|Eagle|Kestrel", common_name)) %>%
  head(5)
print(raptors)

# C. Waders/Shorebirds (Sandpipers, Plovers)
waders <- migrants %>% 
  filter(grepl("Sandpiper|Plover|Curlew|Godwit", common_name)) %>%
  head(5)
print(waders)

# D. Warblers & Flycatchers (Passerines)
passerines <- migrants %>% 
  filter(grepl("Warbler|Flycatcher|Bunting", common_name)) %>%
  head(5)
print(passerines)

cat("\nDone. Full list saved to 'available_migrants_list.csv'.\n")