# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 18:10:45 2019

@author: Casey
clean the retrieved data from -1s and NaNs
"""
from read_featureval_csv import getFeatures
from scipy import stats
import numpy as np
import math

def getNeg1List(lst):
    neg1List = []
    for i in range(len(lst)):
        if(lst[i] == -1):
            neg1List.append(i)
    return neg1List

def getCleanedLists(featVals,labels):
    for i in range(len(featVals),-1,-1):# this loop does this logic because otherwise it deletes wrong elements or goes out of bounds
        if featVals[:,209][i-1] == -1:
            
            featVals = np.delete(featVals,[i-1],0)
            labels = np.delete(labels,[i-1])
            
    return featVals,labels

def getCleanedListsQuick(featVals,labels,neg1List):
    newFeatVals = []
    newLabels = []
    for i in range(len(featVals)):
        if not (i in neg1List):
            newFeatVals.append(featVals[i])
            newLabels.append(labels[i])
        
    return np.array(newFeatVals),np.array(newLabels)

def clean():
    X, y, names = getFeatures()
    
    
    print(X[:,209][1])
    print(stats.zscore(X[:,209]))
    #print(names)
    

    neg1List = getNeg1List(X[:,209])
           
    neg1List = np.array(neg1List)
    print(neg1List)
    print(len(neg1List))
    
    #test example
  #  sampleList = np.array([[4,3,-1],
  #                [4,3,-1],
 #                 [4,3,3],
  #                [4,3,-1],
  #                [4,3,4]])
    
  #  neg1List = getNeg1List(sampleList[:,2])
    
#    sampleLabels = np.array(['l1','l2','l3','l4','l5'])
    
 #   print(sampleList[:,2][3])
  #  print(sampleList[3])
 #   print(len(sampleList))
    #cleanedFeatVals = getCleanedLists(np.array([-1,-1,0,0,0,-1,-1,-1,9,9,9,-1,9,9,9,-1]))
    #cleanedFeatVals,cleanedLabels = getCleanedListsQuick(sampleList,sampleLabels,neg1List)
    
    
    cleanedFeatVals,cleanedLabels = getCleanedListsQuick(X,y,neg1List)#sanity checks done to verify correctness
    print(np.shape(cleanedFeatVals), np.shape(cleanedLabels))
    print(cleanedFeatVals[136737], cleanedLabels[136737])
    print(cleanedFeatVals[136738], cleanedLabels[136738])
            
    print(cleanedFeatVals)
    print(cleanedLabels)
   
    return cleanedFeatVals,cleanedLabels
   
def main():
    clean()

main()