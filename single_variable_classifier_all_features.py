# -*- coding: utf-8 -*-
"""
Created on Thu Dec 13 19:58:20 2018

@author: Casey
"""

from sklearn import svm, grid_search
#from sklearn.model_selection import cross_val_score,cross_validate
#from sklearn.preprocessing import LabelBinarizer
from sklearn.metrics import precision_score,f1_score, accuracy_score,recall_score
from sklearn.cross_validation import KFold
from read_featureval_csv import getFeatures
import numpy as np
import time
from joblib import Parallel, delayed, dump
import multiprocessing
import math
#from sklearn import preprocessing

def checkForNan(featureVals):
    for idx,el in enumerate(featureVals):
        if math.isnan(el):
            print('attack', str(idx), 'is nan')#make it equal to the following element
            print(el)
            featureVals[idx] = featureVals[idx+1]#set equal to next one. In every case it was the first valid entry in the 1,2,or 4 sec feature for CV packet interarrival. For each case, making it same as following sample works.
    

def oneVAll(attack, table):
    print('here withh ', attack)
    tempTable = np.array(table)
  #  print('r2l'==attack)
    for idx,el in enumerate(tempTable):
        if el != attack:
         #   print(el)
            tempTable[idx] = 0
        else:
            tempTable[idx]=1
           # if attack == 'r2l':
              #  print(idx)
            
    return tempTable
        
#find best scores for gamma and c hyperparams
    #potentiall implement at a later time
def svc_param_selection(X, y):
    Cs = [0.1, 1, 10]
    gammas = [0.01, 0.1, 1]
    param_grid = {'C': Cs, 'gamma' : gammas}
    gs = grid_search.GridSearchCV(svm.SVC(kernel='rbf'), param_grid, cv=4,scoring="precision")
    gs.fit(X, y)
    gs.best_params_
    return gs.best_params_

#run in parallel
def parallelSVC(i,featureVals,labels):
    #if i is 0-69, it is u2r, 70-139 it is dos, 140-209 it is probe, 210 - 279 it is r2l, 280 - 349 is R

    if i < 70:
        labels = labels[:,0]
    elif i < 140:
        labels = labels[:,1]
    elif i < 210:
        labels = labels[:,2]
    elif i < 280:
        labels = labels[:,3]
    elif i < 350:
        labels = labels[:,4]

    #reshape into a vector
    labels = labels.reshape(len(labels),)
   
    precisionScores = []
    f1Scores = []
    accuracyScores = []
    recallScores  = []
   
    kf = KFold(len(labels),5)
   # print(kf)
    print('current feature: ',str(i))
    
    currentFeature = i
    
   # featureVals = featureVals[:,currentFeature].reshape(np.size(featureVals[:,currentFeature]),-1)
    for train_index, test_index in kf:
        print("TRAIN:", train_index, "TEST:", test_index)
        X_train, X_test = featureVals[train_index], featureVals[test_index]
        y_train, y_test = labels[train_index], labels[test_index]
        
        #find best params
       # myModel = svc_param_selection(featureVals,labels)
        
        #fit svc, later change C to larger amt such as 10. Increases accuracy for a problem that will never have "great" data. I doubt will overfit. Also make gamma larger, which decreases a single point's influence (important for time series)
        myModel = svm.SVC(gamma=np.std(featureVals),kernel='rbf')#for gamma: (1/n_feats) * stdX. In this case, n_feats is 1, so first part is ignored
       # myModel = svm.SVC(gamma=2.0,kernel='rbf',C=5.0)
        # print(y_train.shape)
        myModel.fit(X_train,y_train)
        #predict
        predicted = myModel.predict(X_test)
       # f.write(predicted.tostring())
        print('precision for feature',str(i),precision_score(y_test,predicted))
        print('f1 for feature',str(i),f1_score(y_test,predicted))
        print('accuracy for feature',str(i),accuracy_score(y_test,predicted))
        print('recall for feature',str(i),recall_score(y_test,predicted))
        precisionScores.append(precision_score(y_test,predicted))
        f1Scores.append(f1_score(y_test,predicted))
        accuracyScores.append(accuracy_score(y_test,predicted))
        recallScores.append(recall_score(y_test,predicted))
      #  print('and f1')
      #  print('f1',f1_score(y_test,predicted))
       # f1Scores.append(f1_score(y_test,predicted))
       
    filename = "./parallel_temp_files/prec_run_" + str(currentFeature) + ".txt"
    dump(precisionScores,filename)  
    filename = "./parallel_temp_files/f1_run_" + str(currentFeature) + ".txt"
    dump(f1Scores,filename)
    filename = "./parallel_temp_files/acc_run_" + str(currentFeature) + ".txt"
    dump(accuracyScores,filename)
    filename = "./parallel_temp_files/rec_run_" + str(currentFeature) + ".txt"
    dump(recallScores,filename)
    print(str(currentFeature), 'finished')
    print(precisionScores)
    print(f1Scores)
    print(accuracyScores)
    print(recallScores)

    return precisionScores

def main():

    featureVals, labels, featNames = getFeatures()
    
    #print(featureVals[:,61].reshape(np.size(featureVals[:,61],)))
   # print(featureVals[:,5].reshape(np.size(featureVals[:,19]),-1))
   # featureVector = featureVals[:,61].reshape(np.size(featureVals[:,61]),-1)
    #print(np.column_stack(featureVals[:,61]))
    print('non binarized labels', labels)
    print(labels.shape)
    #u2r
    allLabels = np.empty([np.size(featureVals[:,0]),5])
    allLabels[:,0] = oneVAll('u2r', labels).reshape(len(labels),)
    #dos
    allLabels[:,1] = oneVAll('dos', labels).reshape(len(labels),)
    #probe
    allLabels[:,2] = oneVAll('probe', labels).reshape(len(labels),)
    #r2l
    allLabels[:,3] = oneVAll('r2l', labels).reshape(len(labels),)
    #R
    allLabels[:,4] = oneVAll('R', labels).reshape(len(labels),)#here make 5 cols each each being its own label as 1
    
    print('u2rLabels',allLabels[:,0])
    print('dosLabels',allLabels[:,1])
    print('probeLabels',allLabels[:,2])
    print('r2lLabels',allLabels[:,3])
    print('RLabels',allLabels[:,4])
    
    print('yo',oneVAll('r2l', labels).reshape(len(labels),))
    
    np.apply_along_axis(checkForNan, axis=0,arr=featureVals)#sets any NaN value to the same as subsequent value
    print('If no \"nan\" is printed below, nans are removed')
    np.apply_along_axis(checkForNan, axis=0,arr=featureVals)#check to make sure they are gone

    
   # lb = preprocessing.LabelBinarizer()
   # lb.fit_transform(u2rTable)
  #  print('binarized labels', u2rTable)
    #labels = np.array(labels)
    print(featNames)
   # u2rTable = u2rTable.reshape(len(labels),)#reshape to a vector so svm doesn't complain
    
    allLabels = allLabels.astype('int')
    
    start = time.time()
    num_cores = multiprocessing.cpu_count()
    print("the number of cores is", str(num_cores))
    var = Parallel(n_jobs=num_cores-2)(delayed(parallelSVC)(i,featureVals[:,i%70].reshape(np.size(featureVals[:,i%70]),-1),allLabels) for i in range(13,17))
    
    print(var)

    
  #  f.close()
  #  print(precisionScores)
    #print(f1Scores)
    
   # print('loaded info:')
   # allScores = []
  #  allScores.append(load("./parallel_temp_files/test61.txt"))
  #  allScores.append(load(filename))
    
  #  print(allScores)
    #
   
    end = time.time()
    print('time to run',end-start)
    
    #here call code to call bash script to push to github
    
main()