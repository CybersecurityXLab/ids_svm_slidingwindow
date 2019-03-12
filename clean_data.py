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
from sklearn.preprocessing import MinMaxScaler

def getNeg1List(lst):
    neg1List = []
    for i in range(len(lst)):
        if(lst[i] == -1):
            neg1List.append(i)
    return neg1List

def getCleanedLists(featVals,labels):#deprecate
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

def getFeatureSubset(index,features):#returns subset minus specified feature
    return np.delete(features, index, axis=1)

def getFeatureStack(indices,features):#returns all features requested in the indices list
    retFeats = np.array([])
    for i in range(len(indices)):
        retFeats = np.hstack((retFeats, features[:,indices[i]]))#flattens it. It must be reshaped
        
    retFeats = np.reshape(retFeats, (len(features),len(indices)), 'F')#read in order to increment row first
    
    return retFeats
    

def clean():#should return two arrays, a feature array, and a label array, that the caller stores locally
    X, y, names = getFeatures()

#    X = [0]
    
 #   print(X[:,0])
 #   print(stats.zscore(X[:,0]))
 #   print(stats.zscore(X))
 #   return
 #   print()
 #   print(X[:,len(X[0])-1][1])
    
 #   print((X[:,len(X[0])-1]))
 #   print(stats.zscore(X[:,len(X[0])-1]))
 #   print(stats.zscore(X))
 #   return
 #   print("these are zscores")
 #   print(np.shape(stats.zscore(X[:,len(X[0])-1])))
 #   return
    #print(names)
    
    neg1List = getNeg1List(X[:,len(X[0])-1])
           
    neg1List = np.array(neg1List)
  #  print(neg1List)
  #  print(len(neg1List))
    
    #test example
    sampleList = np.array([[4,3,-1],
                  [4,3,-1],
                  [4,3,3],
                  [4,3,-1],
                  [4,3,4]])
    

    
  #  neg1List = getNeg1List(sampleList[:,2])
    
#    sampleLabels = np.array(['l1','l2','l3','l4','l5'])
    
 #   print(sampleList[:,2][3])
  #  print(sampleList[3])
 #   print(len(sampleList))
    #cleanedFeatVals = getCleanedLists(np.array([-1,-1,0,0,0,-1,-1,-1,9,9,9,-1,9,9,9,-1]))
    #cleanedFeatVals,cleanedLabels = getCleanedListsQuick(sampleList,sampleLabels,neg1List)
    
    
    cleanedFeatVals,cleanedLabels = getCleanedListsQuick(X,y,neg1List)#sanity checks done to verify correctness
  #  print(np.shape(cleanedFeatVals), np.shape(cleanedLabels))
  #  print(cleanedFeatVals[136737], cleanedLabels[136737])
  #  print(cleanedFeatVals[136738], cleanedLabels[136738])
            
  #  print(cleanedFeatVals)
  #  print(cleanedLabels)
    
    
   # print(getFeatureStack([2],cleanedFeatVals))
   # cleanedFeatVals = getFeatureStack([2,4,16,11],cleanedFeatVals)#delete after test
   
   #sanity check to make sure zscore is applied column-wise
 #  print('zscore',stats.zscore(cleanedFeatVals[:,0]))
 #   now = stats.zscore(cleanedFeatVals)
 #   print(now)

   # return getFeatureStack([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26],stats.zscore(cleanedFeatVals)),cleanedLabels
   # return getFeatureStack([0,1,2,3],stats.zscore(cleanedFeatVals)),cleanedLabels 
    #return getFeatureStack([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26],stats.zscore(cleanedFeatVals))[:20000,:],cleanedLabels[:20000,:] 
  #  return getFeatureStack([0,4,7,9,19,20,21,22,23,24,25,26],stats.zscore(cleanedFeatVals))[:40000,:],cleanedLabels[:40000,:] 
 #   return stats.zscore(cleanedFeatVals)[:10000,:],cleanedLabels[:10000,:]
    return stats.zscore(cleanedFeatVals),cleanedLabels

    
def main():
    clean()

main()
