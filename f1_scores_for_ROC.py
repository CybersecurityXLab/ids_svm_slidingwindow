# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 12:00:06 2019

find the F1 scores for ROC-like curve

@author: User
"""

from sklearn.metrics import f1_score


y = [0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1]
#y = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

predicted = [0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0]

print(f1_score(y,predicted))