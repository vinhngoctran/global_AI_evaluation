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

for i in range(531):
    for j in range(10):
        Filename = 'RESULTS/1.Kratzert/S_'+Basin[i]+'_'+str(j+1)+'.p'
        try:
            with open(Filename, "rb") as fp:
                results = pickle.load(fp)  
            results.keys()
        
            qobs = results[Basin[i]]['1D']['xr']['QObs(mm/d)_obs']
            qsim = results[Basin[i]]['1D']['xr']['QObs(mm/d)_sim']
            FileNameS = 'RESULTS/2.Kratzert_mat/S_'+Basin[i]+'_'+str(j+1)+'.mat'
            transform_and_save_dataarray(qobs, qsim,FileNameS)
        except:
            print(Basin[i])
        
        
        
for j in range(10):
    Filename = 'RESULTS/1.Kratzert/M_'+str(j+1)+'.p'
    with open(Filename, "rb") as fp:
        results = pickle.load(fp)  
    results.keys()  
    
    for i in range(531):
        try:
            qobs = results[Basin[i]]['1D']['xr']['QObs(mm/d)_obs']
            qsim = results[Basin[i]]['1D']['xr']['QObs(mm/d)_sim']
            FileNameS = 'RESULTS/2.Kratzert_mat/M_'+Basin[i]+'_'+str(j+1)+'.mat'
            transform_and_save_dataarray(qobs, qsim,FileNameS)
        except:
            print(Basin[i])
        
        