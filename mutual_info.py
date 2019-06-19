# -*- coding: utf-8 -*-
"""
Created on Wed Jun 19 12:18:34 2019

Compare mutual info of different things

@author: User
"""

from sklearn.metrics import adjusted_mutual_info_score
from clean_data import clean
from scipy.stats import pearsonr

def main(featuresFile,numOfFeats):

    #returns data from specified file minus the -1 values and then returns zscore of each sample
    true,pred = clean(featuresFile)    
    feat1 = true[:,0]
    feat2 = true[:,1]
    pred = pred.flatten()
    print(feat1)
    print(feat2)
    #reshape to be 1D
   # X_true = X_true.flatten()# = X_true.reshape(len(X_true),).
  #  y_true = y_true.flatten()
 #   X_pred = X_pred.flatten()#= X_pred.reshape(len(X_pred),)
 #   print(X_true)
 #   print(y_true)
 #   print(X_pred)
    print('mutual info',mutual_info_score(feat1,pred))
    print('pearson correlation', pearsonr(feat1,feat2))
    
main("mi_MeanPacketSize60_SYNBool60.csv",2)