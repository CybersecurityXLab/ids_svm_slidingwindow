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
from sklearn import svm, tree
from sklearn.neighbors import KNeighborsClassifier
from sklearn.cluster import KMeans, SpectralClustering
from sklearn.naive_bayes import GaussianNB,MultinomialNB
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import f1_score,accuracy_score
import numpy as np
import time

#modularizes the naming
def nameManager(indices,names):
    orderedNames = []
    for idx in indices:
        orderedNames.append(names[idx[1]])
        
    return orderedNames

def run(name,feats,y,MLalg):
 #   start = time.time()
    #neural network
   # clf = MLPClassifier(solver='lbfgs',alpha=1e-5,hidden_layer_sizes=(1000,2),random_state = 1)
   # predicted = cross_val_predict(clf,feats,y,cv=3)
   
   #decision tree
    if MLalg == 'dt':
        clf = tree.DecisionTreeClassifier()
        predicted = cross_val_predict(clf,feats,y,cv=5)
        
    elif MLalg == 'mnb':
    #Multinomial Naive Bayes. NO RESULTS
        mnb = MultinomialNB()
        predicted = mnb.fit(feats,y).predict(feats)
        
    #Gaussian Naive Bayes
    #gnb = GaussianNB()
    #predicted = gnb.fit(feats,y).predict(feats)
    
    #elif MLalg == 'sc':
    #    clustering = SpectralClustering(n_clusters = 2, assign_labels="discretize", random_state=0).fit(feats)
    #    predicted = clustering.labels_
    
    #knn
    elif MLalg == 'knn':
        neigh = KNeighborsClassifier(n_neighbors=4)
        predicted = cross_val_predict(neigh, feats, y,cv=5)
    
    #neigh.fit(feats, y)
    #neigh.predict(feats,y)
    
    #kmeans
    elif MLalg == 'km':
        kmeans = KMeans(n_clusters = 2, random_state=0).fit(feats)
        predicted = kmeans.labels_
    
    #svm
    elif MLalg == 'svm':
        myModel = svm.SVC(gamma='auto',kernel='rbf')
        predicted = cross_val_predict(myModel,feats,y,cv=5)
  #  counterall = 0
  #  counterpos = 1
  #  for i in y:
  #      counterall = counterall + 1
  #      if i == 1:
  #          counterpos = counterpos + 1
  #          
  #  print(counterall)
  #  print(counterpos)
  #  print(counterpos/counterall)
  #  print(f1_score([0,0,0,0,0,0,1],[0,0,0,0,0,1,0]))
#    print('total run time', (time.time() - start))
   #f = open('completion_sentinel_f1_f1.txt',"a")
    #f.write('finished run at ')
#    f.write(str(time.time()))
    f1 = f1_score(y,predicted)
    print(f1)
    accuracy = accuracy_score(y,predicted)
    print(accuracy)
    
    return f1

def rfeRound(X,y,indices,orderedNames,mlAlg):
    roundScores = []
    for i,idx in enumerate(indices):
        name = orderedNames[i]#the current name
        print("Score without ",name, ":")
        tempIndices = [indices[0:i]]#creates a list of indices to use for current round
        tempIndices.append(indices[i+1:])
        tempIndices = list(chain.from_iterable(tempIndices))

        tempFeatures = np.zeros([len(y),len(X[0])])
        for j,jdx in enumerate(tempIndices):#creates the actual feature list for current run
            tempFeatures[:,j] = X[:,jdx[1]]
        
       # roundScores.append[run(name,tempFeatures,X,y)]
        f1 = run(name,tempFeatures,y,mlAlg)
        roundScores.append([f1,name,idx])
        
    
    sortedScores = sorted(roundScores, reverse=False)
    print(sortedScores)
    return sortedScores

def runMLAlg(X,y,mlAlg,startingNames,fileName):
    indices = []
    start = time.time()
    for i in range(len(X[0])):
        indices.append([i,i])#first element is index for current (smaller) list. second is index for global list
    
    print('total run time', (time.time() - start))
    
    for round in range(len(X[0])):#total rounds to run.
        print('new round')
        print('startingFeatures is',indices)
        
        orderedNames = nameManager(indices,startingNames)

        
        if len(indices)>1:
           # print(orderedNames)
            scores = rfeRound(X,y,indices,orderedNames,mlAlg)

                
            indexToRemove = scores[-1][2][0]  
            print("Remove el at index",indexToRemove, ', ', startingNames[indices[indexToRemove][1]])
            print(indices)
            del indices[indexToRemove]
            f = open(fileName,"a")
            f.write('F1 score: ')
            f.write(str(scores[-1][0]))
            f.write('  ')
            for i in range(len(indices)):
                f.write(scores[i][1])
                f.write(' ')
     #   for i in range(len(indices)):
     #       if indices[i][1] == indexToRemove:
     #           del indices[i]
            f.write('\n')
        #change the current index and leave the global index
        for counter,value in enumerate(indices):
            value[0] = counter#the first index is changed for next run. The second index remains global
            
          
    totalTime = time.time() - start
    f.write(str(totalTime))
    print(totalTime)
    f.close()

def main(attack, shuffle):
    featureFile = 'featureVals_windows_u2r_top_6.csv'
    print(attack)
    X,y = clean(featureFile)#returns data from specified file minus the -1 values and then returns zscore of each sample
    startingNames = getNames()
    
    y = oneVAll(attack,y).reshape(len(y),)
    
    if shuffle:
        shuffledArray = getShuffleArray(len(X))
        X, y = doShuffle(X,y, shuffledArray)
        
        
  #  X = X[59000:60000,:]
 #   y = y[59000:60000]
    
    #get the list of indices to show where we are
    
   # runMLAlg(X,y,'knn',startingNames,"scores_knn_test_dos.txt")
    runMLAlg(X,y,'dt',startingNames,"scores_dttestdeletefile_u2r_optimaltimewindows.txt")
   # runMLAlg(X,y,'km',startingNames,"scores_km_20000_r2l.txt")
   # runMLAlg(X,y,'svm',startingNames,"scores_svm_20000_r2l.txt")
    #runMLAlg(X,y,'mnb',startingNames,"scores_mnb_20000.txt")#dataset doesn't work. says something about x being non-negative

#do crossval

#collect scores

#rank

#eliminate

#make it non parallel first. add parallel in and try to recreate result.
    
main('u2r',True)
#ranking of classifiers for DOS. SVM is particularly bad at predicting the non DoS attacks, but other classifiers are better.
#many perform better for non Dos

#1. Vanilla Neural net with RELU activation and alpha 1e-5 and 2 1000 node hidden layers. Also takes substantially longer. Since NN already does feature selection to a certain degree, you wonder how much better it would get. This leads into using CNN and slecting features with convolution
#2. knn 91 seconds
#3. decision trees comparable but faster little less than 4 seconds, svm  67 seconds
#4. kmeans,GaussianNB