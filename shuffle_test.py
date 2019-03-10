# -*- coding: utf-8 -*-
"""
Created on Sat Mar  9 18:33:03 2019

@author: Casey
test shuffle to eliminate all zeros or ones in a cross-val run
"""


import numpy as np

def doShuffle(X,y,shuffled):
    shuffledX = np.zeros(X.shape)
    shuffledy = np.zeros(y.shape)
    
    for idx,el in enumerate(shuffled):
        shuffledX[idx] = X[el]
        shuffledy[idx] = y[el]
        
    return shuffledX,shuffledy

#must be unshuffled to get PATPR in custom metric
def doUnshuffle(shuffledPredictedy,shuffled):#only needs to return predicted in correct order. X should be preserved at client
    unshuffledPredictedy = np.zeros(shuffledPredictedy.shape)
    
    for idx,el in enumerate(shuffled):
        unshuffledPredictedy[el] = shuffledPredictedy[idx]
        
    return unshuffledPredictedy
    
def getShuffleArray(length):#returns shuffled indices of given length for client to keep.
    np.random.seed(100)#just in case client calls this method twice
    shuffleArray = np.arange(length)
    np.random.shuffle(shuffleArray)
    
    return shuffleArray
'''
def main():
    feats = np.random.rand(25,4)
    print(feats)
    labels = np.array([0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1,1])
    
    print(labels)
    
    shuffled = getShuffleArray(len(labels))
    labels = np.reshape(labels,(25,1))
    
    shufX,shufy = doShuffle(feats,labels,shuffled)
    print(shufX,'\n',shufy)
    
    unshufPredY = doUnshuffle(shufy,shuffled)
    print(unshufPredY)
    for idx, el in enumerate(labels):
        if el == unshufPredY[idx]:
            print('good')
        else:
            print('bad')
            
    print(np.any(shufy))#returns false if all zeros
    
    #print(shuffled)
    
main()'''