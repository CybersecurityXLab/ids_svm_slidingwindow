# -*- coding: utf-8 -*-
"""
Created on Thu Dec 13 19:58:20 2018

@author: Casey
"""

from sklearn import linear_model,svm
from sklearn.model_selection import cross_val_score,cross_validate
from read_featureval_csv import getFeatures
import numpy as np
import time

featureVals, labels, featNames = getFeatures()

#print(featureVals[:,61].reshape(np.size(featureVals[:,61],)))
print(featureVals[:,5].reshape(np.size(featureVals[:,19]),-1))
featureVector = featureVals[:,61].reshape(np.size(featureVals[:,61]),-1)
#print(np.column_stack(featureVals[:,61]))
print(labels)
print(featNames)
labels = labels.reshape(len(labels),)#reshape so svm doesn't complain

start = time.time()
myModel = svm.SVC(gamma='auto',kernel='rbf', decision_function_shape='ovo')#use decision_function_shape arg when using multiclass
#print(cross_val_score(myModel, featureVals[:, 36:69 ], labels, cv=5))

scor = ['accuracy']

#old cross val function must be used for multiple scsores
cvResults = cross_validate(myModel,featureVector,labels,scoring=scor,cv=5)
print(cvResults)

#print(cross_val_score(myModel, featureVector, labels, scoring=scor, cv=5))

end = time.time()
print('time to run',end-start)