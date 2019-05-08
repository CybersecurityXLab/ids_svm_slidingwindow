# -*- coding: utf-8 -*-
"""
Created on Mon May  6 13:28:07 2019

@author: User
"""

from clean_data import clean, getFeatureSubset, getFeatureStack
from read_featureval_csv import getFeatures,chooseFeatures, getNames
from shuffle_test import getShuffleArray, doShuffle, doUnshuffle
from oneVAll import oneVAll
from itertools import chain
from sklearn.model_selection import cross_val_predict
from sklearn import svm
from sklearn.metrics import f1_score
import numpy as np

#modularizes the naming
def nameManager(indices,names):
    orderedNames = []
    for idx in indices:
        orderedNames.append(names[idx])
        
    return orderedNames

def run(name,feats,y):
    myModel = svm.SVC(gamma='auto',kernel='rbf')
    predicted = cross_val_predict(myModel,feats,y,cv=5)
    f1 = f1_score(y,predicted)
    print(f1)
    pass
###WRONG
def rfeRound(X,y,indices,orderedNames):
    roundScores = []
    for i,idx in enumerate(indices):
        print()
        name = orderedNames[i]#the current name
        print("Score without ",name, ":")
        tempIndices = [indices[0:i]]#creates a list of indices to use for current round
        tempIndices.append(indices[i+1:])
        tempIndices = list(chain.from_iterable(tempIndices))

        tempFeatures = np.zeros([len(y),len(X[0])])
        for j,jdx in enumerate(tempIndices):#creates the actual feature list for current run
            tempFeatures[:,j] = X[:,jdx]
        
       # roundScores.append[run(name,tempFeatures,X,y)]
        run(name,tempFeatures,y)

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
        #print(orderedNames)

        
        if len(indices)>2:
            rfeRound(X,y,indices,orderedNames)

                


        indices = indices[:-1]  
#do crossval

#collect scores

#rank

#eliminate

#make it non parallel first. add parallel in and try to recreate result.
    
main('dos',True)