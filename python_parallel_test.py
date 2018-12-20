# -*- coding: utf-8 -*-
"""
Created on Wed Dec 19 09:25:43 2018

@author: Casey
"""
from joblib import Parallel, delayed
import multiprocessing

inputs = range(10) 
def processInput(i):
    return i * i

num_cores = multiprocessing.cpu_count()
print(num_cores)
results = Parallel(n_jobs=num_cores)(delayed(processInput)(i) for i in inputs)
print(results)