# -*- coding: utf-8 -*-
"""
Created on Wed Dec 19 09:25:43 2018

@author: Casey
"""
from joblib import Parallel, delayed
import multiprocessing
from scipy import stats
import numpy as np

inputs = range(10) 
def processInput(i):
    return i * i

num_cores = multiprocessing.cpu_count()
print(num_cores)
results = Parallel(n_jobs=num_cores)(delayed(processInput)(i) for i in inputs)
print(results)

b = np.array([[ 0.3148,  0.0478,  0.6243,  0.4608],
                  [ 0.7149,  0.0775,  0.6072,  0.9656],
                  [ 0.6341,  0.1403,  0.9759,  0.4064],
                  [ 0.5918,  0.6948,  0.904 ,  0.3721],
                  [ 0.0921,  0.2481,  0.1188,  0.1366]])
    
c = np.array([[1,2,3],
              [1,2,3],
              [2,3,4]])
    
print(stats.zscore(c, axis = 0))