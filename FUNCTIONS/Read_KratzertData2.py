import pickle
from pathlib import Path
from numpy import loadtxt
import matplotlib.pyplot as plt
import torch
import xarray as xr
import pandas as pd
import numpy as np
from scipy.io import savemat

def transform_and_save_dataarray(qobs, qsim,FileNameS):
    qobs = qobs.values
    qsim = qsim.values
    # Create a dictionary to hold both DataFrame and array
    mdict = {
        'qsim': qsim,  # Convert DataFrame to dict for MATLAB compatibility
        'qobs': qobs
    }
    savemat(FileNameS, mdict)
    return

Basin = loadtxt('Data/single-basin-vs-regional-model/basin_lists/531_basin_list.txt', dtype='str')
Filename = 'Data/RegionalPaper/Kratzert/runs/run_2006_0031_seed111/lstm_seed111.p'
with open(Filename, "rb") as fp:
    results = pickle.load(fp)  
results.keys()  

all_qobs = []
all_qsim = []
for i in range(531):
    qobs = results[Basin[i]]['qobs']
    qsim = results[Basin[i]]['qsim']
    
    # Appending the data
    all_qobs.append(qobs)
    all_qsim.append(qsim)

# Convert lists to numpy arrays for easier manipulation
all_qobs = np.array(all_qobs)
all_qsim = np.array(all_qsim)  
Time =   results[Basin[i]].index
datetime_array = np.array([t.strftime('%Y/%m/%d') for t in Time])     
mdict = {
    'all_qobs': all_qobs,
    'all_qsim': all_qsim,
    'Time': datetime_array,
    'BasinID': Basin
}

# Save the data to a .mat file
savemat('RESULTS_FINAL\R8_Regional_US.mat', mdict)        

        
        