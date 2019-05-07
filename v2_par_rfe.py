# -*- coding: utf-8 -*-
"""
Created on Mon May  6 13:28:07 2019

@author: User
"""

from clean_data import clean, getFeatureSubset, getFeatureStack
from read_featureval_csv import getFeatures,chooseFeatures, getNames
from shuffle_test import getShuffleArray, doShuffle, doUnshuffle
from oneVAll import oneVAll

#modularizes the naming
def nameManager(indices,names):
    orderedNames = []
    for idx in indices:
        orderedNames.append(names[idx])
        
    return orderedNames

def rfe(X,y,name):
    pass

def main(attack, shuffle):
#get data
    X,y = clean()
    startingNames = getNames()
    
    
    y = oneVAll(attack,y).reshape(len(y),)
    
    if shuffle:
        shuffledArray = getShuffleArray(len(X))
        X, y = doShuffle(X,y, shuffledArray)
        
        
    X = X[40000:60000,:]
    y = y[40000:60000]
    
    #get the list of indices to show where we are
    startingFeatures = X
    indices = []
    for i in range(len(X[0])):
        indices.append(i)
    
    for round in range(len(X[0])):#total rounds to run.
        featureScores = []
        print('startingFeatures is',indices)
        
        orderedNames = nameManager(indices,startingNames)
        print(orderedNames)

        
        if len(indices)>2:
            for i,idx in enumerate(indices):
                name = orderedNames[i]#the current name
                
                
               # startingFeatureIndeces,idx,y,X,names
                rfe(X,y,name,idx)


        indices = indices[:-1]  
#do crossval

#collect scores

#rank

#eliminate

#make it non parallel first. add parallel in and try to recreate result.
    
main('dos',True)