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
from sklearn.model_selection import cross_val_predict, cross_val_score
from sklearn import svm, tree
from sklearn.neighbors import KNeighborsClassifier
from sklearn.cluster import KMeans, SpectralClustering
from sklearn.naive_bayes import GaussianNB,MultinomialNB
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import f1_score,accuracy_score
import numpy as np
import time
import math

#modularizes the naming
def nameManager(indices,names):
    orderedNames = []
    for idx in indices:
        orderedNames.append(names[idx[1]])
        
    return orderedNames

def runTest(X_train, X_test, y_train, y_test,mlAlg):
    start = time.time()
    
    if mlAlg == 'dt':
        decision_tree = tree.DecisionTreeClassifier()
        decision_tree = decision_tree.fit(X_train,y_train)
        predicted = decision_tree.predict(X_test)
        predicted = np.array([int(x) for x in predicted])
      #  print(y_test)
        print(predicted)
        print()

    elif mlAlg == 'knn':
        neigh = KNeighborsClassifier(n_neighbors=3)
        neigh.fit(X_train,y_train)
        predicted = neigh.predict(X_test)
        print(predicted)
        print()
    
    elif mlAlg == 'svm':
        myModel = svm.SVC(gamma='auto',kernel='rbf')
        myModel.fit(X_train,y_train)
        predicted = myModel.predict(X_test)
        
    elif mlAlg == 'nn':
            #neural network
         clf = MLPClassifier(solver='lbfgs',alpha=1e-5,hidden_layer_sizes=(1000,2),random_state = 1)
         clf.fit(X_train,y_train)
         predicted = clf.predict(X_test)
            
    f1 = f1_score(y_test.tolist(),predicted)
    accuracy = accuracy_score(y_test.tolist(),predicted)
    print(f1)
    print(accuracy)
    
    print('time: ', str(time.time() - start))

    actualFile = open('actualY.csv', "w")
    predictFile = open("predictedY.csv","w")
    
    for el in y_test.tolist():
        actualFile.write(str(el) + "\n")
        
    for el in predicted:
        predictFile.write(str(el) + "\n")
        
    actualFile.close
    predictFile.close

#do crossval on training set
#eventually make it not cross_val_predict because it isn't supposed to return guesses
def run(feats,y,MLalg):
    
 #   start = time.time()
    #neural network
   # clf = MLPClassifier(solver='lbfgs',alpha=1e-5,hidden_layer_sizes=(1000,2),random_state = 1)
   # predicted = cross_val_predict(clf,feats,y,cv=3)
   
   #decision tree
    if MLalg == 'dt':
        clf = tree.DecisionTreeClassifier()
        predicted = cross_val_predict(clf,feats,y,cv=5)
        scores = cross_val_score(clf,feats,y,cv=5,scoring = "f1")
        print(scores)
        
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
        f1 = run(tempFeatures,y,mlAlg)
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
    
#depending on whether it is run 1 or 2, return either the first or last half as training or test and vice versa
def getTrainingAndTest(X,y,attack,featureFile,train,number):
    
    #split by number of attacks for each attack type
    if attack == 'dos':
        trainTestSplitIdx = 71347
     #   trainTestSplitIdx = 140000
    elif attack == 'probe':
        trainTestSplitIdx = 74537
    elif attack == 'u2r':
        trainTestSplitIdx = 93867
    elif attack == 'r2l':
        trainTestSplitIdx = 55286
        
    print(trainTestSplitIdx)
    
    if number == 1:
        training_X = X[:trainTestSplitIdx,:]
        training_y = y[:trainTestSplitIdx]
    
        test_X = X[trainTestSplitIdx:,:]
        test_y = y[trainTestSplitIdx:]
    elif number ==2:
        test_X = X[:trainTestSplitIdx,:]
        test_y = y[:trainTestSplitIdx]
    
        training_X = X[trainTestSplitIdx:,:]
        training_y = y[trainTestSplitIdx:]
        
  #  shuffledArray = getShuffleArray(len(training_X))
  #  training_X, training_y = doShuffle(training_X,training_y, shuffledArray)
 #   training_X = np.array(training_X)
 #   training_y = np.array(training_y)
    tempX = np.zeros(training_X.shape)
    tempy = np.zeros(training_y.shape)
    
    for idx, el in enumerate(training_X):
        tempX[idx] = training_X[idx]
        tempy[idx] = training_y[idx]
        
    training_X = tempX
    training_y = tempy
    return training_X,training_y,test_X,test_y

def main(attack, shuffle,mlCode, featureFile,train):
    print(attack)
    print(mlCode)
    X,y = clean(featureFile)#returns data from specified file minus the -1 values and then returns zscore of each sample
    startingNames = getNames(featureFile)
    y = oneVAll(attack,y).reshape(len(y),)
        

    print(np.shape(X))#gives (samples,features)
    #trainTestSplitIdx = math.floor( np.shape(X)[0] * 0.5)#gives index at 50% of dataset
    
    if train == 'train':
        training_X,training_y,test_X,test_y = getTrainingAndTest(X,y,attack,featureFile,train,1)
      #  training_X = training_X[50000:60000,:]
       # training_y = training_y[50000:60000]
        runMLAlg(training_X,training_y,mlCode,startingNames,"scores_delete_" + mlCode + "_" + attack + "_6feattimewindows1_1.txt")
       
#        training_X,training_y,test_X,test_y = getTrainingAndTest(X,y,attack,featureFile,train,2)
      #  training_X = training_X[50000:60000,:]
      #  training_y = training_y[50000:60000]
#        runMLAlg(training_X,training_y,mlCode,startingNames,"scores_" + mlCode + "_" + attack + "_6feattimewindows1_2.txt")
    
    elif train == 'test':#test set
        
        #before running, make sure the last number is set correctly. It should match the cv number of the file
        training_X,training_y,test_X,test_y = getTrainingAndTest(X,y,attack,featureFile,train,1)
   #     training_X = training_X[40400:40900,:]
    #    training_y = training_y[40400:40900]
        runTest(training_X,test_X,training_y,test_y,mlCode)



    
#params(attack, shuffle, mlalg, featurefile, train)

main('dos',True, 'dt', 'featureVals_8sec.csv','train')
#ranking of classifiers for DOS. SVM is particularly bad at predicting the non DoS attacks, but other classifiers are better.
#many perform better for non Dos

#1. Vanilla Neural net with RELU activation and alpha 1e-5 and 2 1000 node hidden layers. Also takes substantially longer. Since NN already does feature selection to a certain degree, you wonder how much better it would get. This leads into using CNN and slecting features with convolution
#2. knn 91 seconds
#3. decision trees comparable but faster little less than 4 seconds, svm  67 seconds
#4. kmeans,GaussianNB