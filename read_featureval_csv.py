# -*- coding: utf-8 -*-
"""
Created on Thu Dec 13 19:30:51 2018

@author: Casey
"""

import pandas as pd
import numpy as np

def getFeatures():
    featureVals = pd.read_csv('featureVals_8sec_justSynBool.csv',
                            sep=',',
                            header=0)
    
    labels = pd.read_csv('labels.csv',
                         sep=',',
                         header=0)#ignore first row because matlab writes an irrelevant var name to first row
        
   # featureNames = pd.read_csv('features.csv',
    #                     sep=',',
    #                     header=0)#same as above
                         
    featureValnp = np.array(featureVals,dtype="float32")
    labelsnp = np.array(labels)
    featureNamesnp = featureVals.head(0).columns.values
    #featureNamesnp=np.array(featureNames)
    
    return featureValnp, labelsnp, featureNamesnp

#print(featureValnp)
#print(np.shape(featureValnp))

#print(labels)
#print(featureNames)
    
def getNames():
    featureVals = pd.read_csv('featureVals_8sec_justSynBool.csv',
                            sep=',',
                            header=0)
    

    featureNamesnp = featureVals.head(0).columns.values

    
    return featureNamesnp
    
def chooseFeatures(XFeatures, XFile,yFile):
    inputData = pd.read_csv(XFile,
                            sep=',',
                            usecols=XFeatures,
                            header=0)
    outputData = pd.read_csv(yFile,
                             sep=',',
                             usecols=[0],
                             header=0)

    tempAllX = np.array(inputData, dtype="float")
 
    return tempAllX, np.array(outputData), inputData.head(0).columns.values
