# -*- coding: utf-8 -*-
"""
Created on Fri Jan  4 11:07:22 2019

@author: Casey
"""

from sklearn.metrics import precision_score


print('precision for feature',precision_score([0,1,1,0,1,1],[0,1,1,0,0,1]))
print('precision for feature',precision_score([0,1,1,0,1,1],[0,0,0,0,0,0]))
print('precision for feature',precision_score([0,1,1,0,1,1],[0,1,0,1,0,1]))