# -*- coding: utf-8 -*-
"""
Created on Thu Dec 13 19:30:51 2018

@author: Casey
"""

import pandas as pd
import numpy as np

def getFeatures():
    featureVals = pd.read_csv('featureVals.csv',
                            sep=',',
                            header=None)
    
    labels = pd.read_csv('labels.csv',
                         sep=',',
                         header=0)#ignore first col because matlab writes an irrelevant var name to first col
        
    featureNames = pd.read_csv('features.csv',
                         sep=',',
                         header=0)#same as above
                         
    featureValnp = np.array(featureVals,dtype="float32")
    labelsnp = np.array(labels)
    featureNamesnp=np.array(featureNames)
    
    return featureValnp, labelsnp, featureNamesnp

#print(featureValnp)
#print(np.shape(featureValnp))

#print(labels)
#print(featureNames)