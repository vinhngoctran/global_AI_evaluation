import requests
import pandas as pd
import os
def download_usgs_data(site, start_date, end_date, save_csv=False):
    """
    Download daily gage height (water level) and streamflow from USGS NWIS.

    Parameters:
    - site: str, USGS site ID (e.g., '03339000')
    - start_date: str, 'YYYY-MM-DD'
    - end_date: str, 'YYYY-MM-DD'
    - save_csv: bool, whether to save output to CSV

    Returns:
    - pd.DataFrame with date, gage height (m), and streamflow (cms)
    """
    url = "https://waterservices.usgs.gov/nwis/dv/"
    parameter_codes = {
        '00060': 'streamflow_cfs'
    }
    
   
    all_data = {}

    for code, label in parameter_codes.items():
        params = {
            "format": "json",
            "sites": site,
            "startDT": start_date,
            "endDT": end_date,
            "parameterCd": code,
            "siteStatus": "all"
        }

        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        try:
            values = data['value']['timeSeries'][0]['values'][0]['value']
            series = {
                item['dateTime'][:10]: float(item['value']) if item['value'] else None
                for item in values
            }
            all_data[label] = pd.Series(series)

        except (KeyError, IndexError):
            print(f"No data found for parameter {code} at site {site}.")

    if not all_data:
        print("No data downloaded.")
        return pd.DataFrame()

    # Combine and convert units
    df = pd.concat(all_data, axis=1)
    df.index = pd.to_datetime(df.index)
    df.sort_index(inplace=True)

    # Unit conversions


    if 'streamflow_cfs' in df.columns:
        df['streamflow_cms'] = df['streamflow_cfs'] * 0.0283168

    df = df[[ 'streamflow_cms']]

    if save_csv:
        filename = f"RESULTS_FINAL/downloadData2/{site}.csv"
        df.to_csv(filename)
        print(f"Saved to {filename}")

    return df

# Read site list from txt file without header
with open('RESULTS_FINAL/CNRFC.txt', 'r') as f:
    site_list = []
    for line in f:
        line = line.strip()
        if line:  # Only process non-empty lines
            # Handle NaN values and scientific notation
            if line.lower() == 'nan':
                continue  # Skip NaN entries
            elif 'e+' in line.lower():  # Scientific notation
                try:
                    site_id = format(float(line), '.0f')
                except ValueError:
                    continue  # Skip if conversion fails
            else:
                site_id = line
            
            # Remove decimal points if any exist
            site_id = site_id.split('.')[0]
            
            # Only add if it's a valid number
            if site_id.isdigit():
                site_list.append(f"{int(site_id):08d}")  # Zero-pad to 8 digits
            else:
                print(f"Skipping invalid site ID: {line}")

print(f"Loaded {len(site_list)} valid site IDs")

# Example usage
if __name__ == "__main__":
    for site_id in site_list:
        filename = f"RESULTS_FINAL/downloadData2/{site_id}.csv"
        
        if not os.path.exists(filename):
            try:
                start = '1980-01-01'
                end = '2023-12-31'

                df = download_usgs_data(site_id, start, end, save_csv=True)
                print(f"Downloaded data for {site_id}:")
                print(df.head())
            except Exception as e:
                print(f"Error or no data downloaded for {site_id}: {e}")