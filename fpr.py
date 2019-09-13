# -*- coding: utf-8 -*-
"""
Created on Fri Sep 13 16:34:54 2019

@author: User

get FPR
"""

from sklearn.metrics import confusion_matrix
import numpy as np

ytrue = np.array([0,1,0,1])
ypred = np.array([1,1,0,1])

ytrue = np.loadtxt('predictedY_nostats_u2r_CV2.csv',delimiter=',',dtype=int)
ypred = np.loadtxt('actualY_u2rCV2.csv',delimiter=',',dtype=int)
print(ytrue.size)
print(ypred.size)
#for i in ytrue:
#    print(i)

tn, fp, fn, tp = confusion_matrix(ytrue,ypred).ravel()
print(tn,fp,fn,tp)

fpr = fp / (fp + tn)
print(fpr)

