# -*- coding: utf-8 -*-
"""
Created on Thu Feb  7 13:35:40 2019

@author: Casey

checklist for individual changes for each run
1 file name to something like acc_scores.txt
2 in record run, change the scores to be written as needed
3 in parallelrfe, change the ranking metric to be returned
4 check that the number of folds is correct in both functions
"""

#from recursive_feature_elimination import specifyDataset
import numpy as np
#from process_data import readAllFeatures, chooseFeatures
from sklearn.cross_validation import KFold
from sklearn import svm
from sklearn.metrics import accuracy_score, f1_score
from itertools import chain
from joblib import Parallel, delayed#, dump
from read_featureval_csv import getFeatures,chooseFeatures, getNames
import multiprocessing
import time
import math
from custom_metric import getCustomMetric
from clean_data import clean, getFeatureSubset, getFeatureStack
from shuffle_test import getShuffleArray, doShuffle, doUnshuffle

def attackVsR(attack,table):#regular vs generic attack traffic
    print('here with ',all)
    tempTable = np.array(table)
    for idx,el in enumerate(tempTable):
        if el != 'R':
            tempTable[idx] = 1
        else:
            tempTable[idx] = 0
            
    return tempTable

def oneVAll(attack, table):
    print('here withh ', attack)
    if(attack=='all'):
        return attackVsR(attack,table)
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

def recordRun(i,featureIndices,labels,X,names):#not used in RFE, only used to record current scorestartingFeatureIndeces.append(-1)#on negative one, run all features for recording purposes
 #reshape into a vector
    labels = labels.reshape(len(labels),)
    print('the feature indices', featureIndices)

    featureVals = getFeatureStack(featureIndices, X)
    
    accuracyScores = []
    customMetricScores = []
    f1Scores = []
    
    kf = KFold(len(labels),5)
    print('current feature: ',str(i), 'sentinel value')
    
    for train_index, test_index in kf:
        print("TRAIN:", train_index, "TEST:", test_index)
        X_train, X_test = featureVals[train_index], featureVals[test_index]
        y_train, y_test = labels[train_index], labels[test_index]
        
        if not (np.any(y_train) and np.any(y_test)):#np.any returns false if all 0. skip round if this is the case
            print('y_train contains any 1s?' ,np.any(y_train))
            print('y_test contains any 1s?' ,np.any(y_test))
            print('skipping cross val round')
        else:
        
            myModel = svm.SVC(gamma='auto',kernel='rbf')#,C=20.0)#for gamma: (1/n_feats) * stdX. In this case, n_feats is 1, so first part is ignored
    
            myModel.fit(X_train,y_train)
            #predict
            predicted = myModel.predict(X_test)
    
            print('custom score all feats',getCustomMetric(y_test,predicted))
            print('accuracy all feats',accuracy_score(y_test,predicted))
            print('f1 for all feats',f1_score(y_test,predicted))
            
            customMetricScores.append(getCustomMetric(y_test,predicted))
            accuracyScores.append(accuracy_score(y_test,predicted))
            f1Scores.append(f1_score(y_test,predicted))

    

    accScoresAvg = np.mean(np.asarray(accuracyScores))#
    customScoresAvg = np.mean(np.asarray(customMetricScores))
    f1ScoresAvg = np.mean(np.asarray(f1Scores))
    print('custom')
    print(customMetricScores)
    print(customScoresAvg)
    print('accuracy')
    print(accuracyScores)
    print(accScoresAvg)
    print('f1')
    print(f1Scores)
    print(f1ScoresAvg)
    f = open('scores.txt','a')
    f.write('custom: ')
    f.write(str(customScoresAvg))
    writeArrayElements(customMetricScores,f)
    f.write('\naccuracy: ')
    f.write(str(accScoresAvg))
    f.write('\nf1: ')
    f.write(str(f1ScoresAvg))
    f.write('\n')
    for i in featureIndices:
        f.write(str(i))
        f.write(' ')
    
    f.write('\n\n')
    f.close()

def writeArrayElements(array, f):
    f.write("   [")
    for el in array:
        f.write(str(el))
        f.write(' ')
    f.write(("]"))

def parallelRFE(i,featureIndices,labels,X,names):
    #reshape into a vector
    labels = labels.reshape(len(labels),)
    print('feature indices:',featureIndices)
   # print('shape of featureVals', featureVals.shape)
    #featureVals, non, non2 = chooseFeatures(featureVals,'sixteenSecWindows.csv','labels.csv')#this is just a lazy way to get the feature name)
   
    featureVals = getFeatureStack(featureIndices, X)
    
    
    
    #featureVals, non, non2 = chooseFeatures(featureIndices,'featureVals.csv','labels.csv')#this is just a lazy way to get the feature name)

   # print('after getting vals', featureVals[0][0])
    customMetricScores = []
    accuracyScores = []
    f1Scores = []
    rankingScoresVerbose = []#scores to use for RFE run
    
    
    kf = KFold(len(labels),5)
    nonFeatures = names[i]
    print('current feature: ',str(i), nonFeatures)
    
    #if either all y_train or y_test are 0, skip the iteration
    for train_index, test_index in kf:
        print("TRAIN:", train_index, "TEST:", test_index)
        X_train, X_test = featureVals[train_index], featureVals[test_index]
        y_train, y_test = labels[train_index], labels[test_index]

        if not (np.any(y_train) and np.any(y_test)):#np.any returns false if all 0. skip round if this is the case
            print('y_train contains any 1s?' ,np.any(y_train))
            print('y_test contains any 1s?' ,np.any(y_test))
            print('skipping cross val round')
        else:
           # myModel = svm.SVC(gamma=1.0,kernel='rbf')
            myModel = svm.SVC(gamma='auto',kernel='rbf')#,C=20.0)#for gamma: (1/n_feats) * stdX. In this case, n_feats is 1, so first part is ignored
           # myModel = svm.SVC(gamma=2.0,kernel='rbf',C=5.0)
            # print(y_train.shape)
            myModel.fit(X_train,y_train)
            #predict
            predicted = myModel.predict(X_test)
            #temp measure to use placeholder for name
            
            
            #non,non2,nonFeatures = chooseFeatures([i],'sixteenSecWindows.csv','labels.csv')#this is just a lazy way to get the feature name
            
            
            #the nature of time windows presents an interesting problem with metrics compared to usual classification tasks. A simple one to one comparison of prediction to label for each individual second does not completely capture the effectiveness of attack classification when an attack is a sequence of seconds, not a single second.
            #also important is the idea that ANY value of an attack window is classified as an attack (a single flagged event in an entire window may be enough for a sec analyst to check for (and discover) an attack). Of course this method alone neither takes into account reducing FPs and it does not give weight to the normal true positive rate. (e.g. if an attack is 1000 seconds, and only 1 sec is classified as such, a sec analyst would (reasonably) be more likely to overlook it than if 700 / 1000 are classified as an attack in the same window).
            #in other words, it looks more like a false positive. We want a measure that considers the total attacks correctly flagged, the percentage of individual attack seconds classified as such, and the individual regular seconds incorrectly classified as an attack. All three of these measures are important and impact the real world performance of an IDS, and any useful measure of an IDS should consider all three.
            #we want all of these things to be considered together and give us a measure between 0 and 1
            #accuracy alone is a poor predictor of IDS performance [cite base rate fallacy paper]
            
            #Factors for successful IDS metric: 
            #1 perAttackTPR: we want to maximize number of attacks classified as such (with even 1 packet correctly labelled in the entire attack) (domain specific) (gives each attack equal weight) (every attack is important to classify as such)
            #2 TNR: we want to minimize the percentage of false positives (equiv. maximize TNR: (1 - FPR) == TNR) (Regular traffic has an attack prediction.) (all false positives are bad bc of base rate fallacy) (the more, the worse)
            ####get rid of? 3: we want to maximize the average percentage of seconds correctly classified as an attack for each attack, which is equivalent to getting TPR (per attack basis) (this measure gives all attacks equal weight) (threshold)
            #4 TPR: we want to maximize the overall average percentage of true positives (eqiv: total number of correct attack seconds classified as such) (this gives larger attacks more weight (prob good for our purposes)) (per attack accuracy) (larger attacks are more relevant to time-based attacks and therefore should have more weight given to them)
           
            
            #we need a measure which gives all attacks weight, gives longer attacks more weight (time relevant), and penalizes false positives
            #in the future, experimentation can be done to consider the optimal weights given to each of these
            
            
            print('accuracy minus feature',str(i), nonFeatures,accuracy_score(y_test,predicted))
            print('custom score minus feature',str(i), nonFeatures,getCustomMetric(y_test,predicted))
            print('f1 minus feature',str(i), nonFeatures,f1_score(y_test,predicted))
            
    
            customMetricScores.append(getCustomMetric(y_test,predicted))
            accuracyScores.append(accuracy_score(y_test,predicted))
            f1Scores.append(f1_score(y_test,predicted))


    accScoresAvg = np.mean(np.asarray(accuracyScores))#
    customScoresAvg = np.mean(np.asarray(customMetricScores))
    f1ScoresAvg = np.mean(np.asarray(f1Scores))
    print('custom')
    print(customMetricScores)
    print(customScoresAvg)
    print('accuracy')
    print(accuracyScores)
    print(accScoresAvg)
    print('f1')
    print(f1Scores)
    print(f1ScoresAvg)
    
    rankingScoresVerbose.append([customScoresAvg,nonFeatures,i])
        
    print(rankingScoresVerbose)
    return rankingScoresVerbose

    

def oneRound(startingFeatureIndeces,idx,y,X,names):
    popList = startingFeatureIndeces#so that operations can be performed without changing global list
    popList.pop(0)#remove -1 sentinel for actual run
    if(idx == -1):
        print('running all features to record score')
        return recordRun(idx,popList,y.astype('int'),X,names)
    tempFeatures = [popList[0:idx]]
    tempFeatures.append(popList[idx+1:])
    tempFeatures = list(chain.from_iterable(tempFeatures))
            
    #tempFeatures = np.delete(startingFeatureIndeces,feature)#all features in current round minus one (i.e. remove a column)
    print('this rounds features:',tempFeatures)
            
    print('the feature index is', idx)
    #https://stackoverflow.com/questions/45346550/valueerror-unknown-label-type-unknown
    
    return parallelRFE(idx,tempFeatures,y.astype('int'),X,names)
    #featureScores.append(parallelRFE(feature,tempFeatures,y.astype('int')))
    #print('feature scores outside the loop')
    #print(featureScores)
    #print('\n\n')

#put the traffic type as a parameter evenutally
def main(attack):
    print('using custom metric')
    X,y = clean()
    names = getNames()

    
    ####IMPORTANT THE NAMES ARE ONLY CORRECT IF ALL OF THE COLUMN INDICES ARE USED
    
    #shuffledArray = getShuffledArray()
   # X, y, featureNames = getFeatures()
    
    #here remove all -1s and corresp labels
    #here check and remove NaN 
    #here get f-scores#needs to be done before, therefore above needs to be done before to avoid processing every time
    #here remove
    
    #X,y,features = readAllFeatures('./datasets/kc_house_data/kc_house_data_X.csv','./datasets/kc_house_data/kc_house_data_y_classification_2_class.csv')
    
    print(y)
    
    y = oneVAll(attack, y).reshape(len(y),)
    
    print(y)
    

    
    start = time.time()
    
    #temporary
  #  sixteenSecWindows = [4,11,18,25,32,39,46,53,60,67]
  #  X = np.take(X,sixteenSecWindows)
    #X = X[:,0:4]
    
    startingFeatures = X

    print(X)
   # print(featureNames)
    
    
    startingFeatureIndeces = [] #get indeces of features for next round
    startingFeatureIndeces.append(-1)#on negative one, run all features for recording purposes
    for i in range(len(startingFeatures[0])):
        startingFeatureIndeces.append(i)
    
    
    for round in range(len(X[0])):#total rounds to run.
        #print('feature scores for current round')
        #print(featureScores)
        featureScores = []
        print('startingFeatures is',startingFeatureIndeces)
    
        print('len of starting features', str(len(startingFeatureIndeces)))
        
        #here keep track of score from best features from previous round. If it is worse in new round, stop
        if len(startingFeatureIndeces)>2:#else this is the last element with the sentinel. don't perform another round
            #parallelize this
            
            num_cores = multiprocessing.cpu_count()
            print("the number of cores is", str(num_cores))
    
            retVal = Parallel(n_jobs=num_cores-2)(delayed(oneRound)(startingFeatureIndeces,idx, y,X,names) for idx in startingFeatureIndeces)
            print('retval',retVal)
            print(retVal.remove(None))
            print('retval after nonetype removed', retVal)
            featureScores.append(retVal)
            print('the feature scores',featureScores)
            
            #for feature in range(len(startingFeatures[0])):#number of features in current round
           # for idx, feature in enumerate(startingFeatureIndeces):    
              #  featureScores.append(oneRound(startingFeatureIndeces,idx,feature,y))
                
            sortedList = sorted(featureScores[0], reverse=False)#feature scores is a single element nested list
            print('sorted list',sortedList)
            
            print(len(sortedList)*.1)
            print(math.floor(len(sortedList)*.1))
            
            toElim = math.floor(len(sortedList)*0.1)#eliminates 10% of each round's features
            
            if(toElim == 0):#1 feature is less than threshold
                toElim = 1
            
            print('this round, eliminates', toElim,'features')
            for i in range(toElim):
            
                print('last place feature',sortedList[-1])
                print('\n\n\neliminate feature',(sortedList[-1][0][1]),'\n\n')
                #print(np.asarray(sortedList)[:,:-1])
                #startingFeatures = np.asarray(sortedList)[:,:-1]
                
                
                #number of elements to remove
                sortedList = sortedList[:-1]
            
            startingFeatureIndeces = []
            startingFeatureIndeces.append(-1)#append sentinel
            for el in sortedList:
                startingFeatureIndeces.append(el[0][2])
            
            
            print('new feature indeces', startingFeatureIndeces)
            
        #    startingFeatures, non, non2 = chooseFeatures(startingFeatureIndeces, 'sixteenSecWindows.csv','labels.csv')
                
            startingFeatures = getFeatureStack(startingFeatureIndeces,X)
            
            #exit()
                #X = sortedList
    
    startingFeatureIndeces = np.delete(startingFeatureIndeces,0) #remove -1
    startingFeatures = getFeatureStack(startingFeatureIndeces,X)
    print("the final feature set is", startingFeatures)
    recordRun(0,startingFeatureIndeces,y.astype('int'),X)    #final run with last feature. Remove -1
    
    print('total run time', (time.time() - start))
    f = open('completion_sentinel.txt',"a")
    f.write('finished run at ')
    f.write(str(time.time()))
    #for total number of rounds (round)
        #featureScores = []
        
        #parallelize
        #for each feature (feature)
            #append to featureScores svm run score without (feature)
            
        #sort featureScores
        #remove worst feature
    
    #define the features to run before each parallel RFE call
    
    
    #specifyDataset(X,y,'svm',15)

#plot the average change in accuracy, f1 and custom over time (per round) for a given score used to rank
    #eventually, at the end run a cross-val with 20 rounds for robustness and lessen poor scores.
    #if f1 performs better, it is likely because of PATPR, which may need to have its weight lessened
    #not using 'all' because PATPR doesn't calculate correctly for this scenario.
main('r2l')#BEFORE FINAL RUN, MAKE SURE ALL CORRECTLY SEPARATES ATTACKS FOR PATPR
#if the best feature set is all features, choose a local minimum under a reasonable threshold of features