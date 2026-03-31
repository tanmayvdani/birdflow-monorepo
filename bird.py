import requests
import json
import csv

def fetch_species_direct():
    # This URL was found in the file snippet you uploaded.
    # It is the internal API the website uses to populate the species grid.
    api_url = "https://species.birds.cornell.edu/bow/api/v1/taxonomy"
    
    # We pretend to be a browser so the API allows us in
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Referer": "https://science.ebird.org/",
        "Origin": "https://science.ebird.org"
    }

    print(f"Connecting to API source: {api_url}...")
    
    try:
        response = requests.get(api_url, headers=headers)
        response.raise_for_status() # Stop if the link is broken
        
        data = response.json()
        
        # The API likely returns a dictionary where keys are species codes 
        # or a list of species objects. We handle both cases.
        species_list = []
        
        # If it returns a massive dictionary (common in this API)
        if isinstance(data, dict):
            # Try to find the list inside the dictionary
            if 'data' in data:
                items = data['data']
            else:
                # Sometimes the dict itself is the list (key=code, value=data)
                items = data.values()
        elif isinstance(data, list):
            items = data
        else:
            items = []

        print(f"Parsing {len(items)} records...")

        for item in items:
            # Extract the Common Name
            # We try different keys that eBird commonly uses
            name = item.get('commonName') or item.get('primaryCommonName') or item.get('name')
            
            # Optional: Get the scientific name too
            sci_name = item.get('sciName') or item.get('scientificName')
            
            if name:
                species_list.append(f"{name} ({sci_name})")

        # Sort and Save
        species_list = sorted(list(set(species_list)))
        
        if species_list:
            print(f"\nSUCCESS: Found {len(species_list)} species!")
            print("-" * 40)
            print("First 5 examples:")
            for s in species_list[:5]:
                print(f" - {s}")
            
            # Save to file
            filename = "ebird_species.txt"
            with open(filename, "w", encoding="utf-8") as f:
                f.write("\n".join(species_list))
            print(f"\nSaved full list to '{filename}'")
        else:
            print("The API returned data, but we couldn't find the 'commonName' field. The format might be different.")
            # Debugging: print first item keys to see what they are
            if items:
                first_item = list(items)[0] if isinstance(items, list) else list(items.values())[0]
                print(f"DEBUG: Keys found in data: {first_item.keys()}")

    except Exception as e:
        print(f"Failed to fetch data: {e}")
        print("Tip: If this API is blocked, we might need to use the official eBird Taxonomy API (public) instead.")

if __name__ == "__main__":
    fetch_species_direct()
