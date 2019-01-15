# -*- coding: utf-8 -*-
"""
Created on Wed Jan  2 12:50:36 2019

@author: Casey

Read serialized feature performance data for single variable classifier
"""
from joblib import  dump, load
import numpy as np
def main():
    print('loaded info:')
    allScores = []
    for i in range(280):

        if i < 70:
            curType = 'u2r'
        elif i < 140:
            curType = 'dos'
        elif i < 210:
            curType = 'probe'
        elif i < 280:
            curType = 'r2l'
        modi = i % 70#find what attack and feature
        if modi < 7:
            curFeat = 'cvpacksize'
        elif modi < 14:
            curFeat = '3rdmompacksize'
        elif modi < 21:
            curFeat = 'cvpackinterarrival'
        elif modi < 28:
            curFeat = '3rdmompackinterarrival'
        elif modi < 35:
            curFeat = 'corjavascriptcount'
        elif modi < 42:
            curFeat = 'httporftpandexe'
        elif modi < 49:
            curFeat = 'httpandmalformed'
        elif modi < 56:
            curFeat = 'ftpandc'
        elif modi < 63:
            curFeat = 'syncount'
        elif modi < 70:
            curFeat = 'echocount'
        #cv packet size
        #third moment packet size
        #cv packet interarrival
        #third moment packet interarrival
        #c or javascript
        #http or ftp and exe code count
        #http and malformed count
        #ftp and c code count
        #syn count
        #echo count
        filename = "./parallel_temp_files/f1_run_" + str(i) + ".txt"#test57.txt"
        try:
          #  allScores.append([np.mean(load(filename)),load(filename),curType + ' ' + curFeat + str(modi%7)])
           allScores.append([np.mean(load(filename)),curType + ' ' + curFeat + str(modi%7)])#score, attack, feature, time window
           # raise(Exception('exception'))
        except Exception as error:
            print(str(i), 'doesnt exist')
 #   allScores.append([load("./parallel_temp_files/test57.txt"),'57'])
   # allScores.append([load("./parallel_temp_files/test58.txt"),'58'])
  #  allScores.append([load("./parallel_temp_files/test59.txt"),'59'])
  #  allScores.append([load("./parallel_temp_files/test60.txt"),'60'])
  #  allScores.append([load("./parallel_temp_files/test61.txt"),'61'])
    print(sorted(allScores,reverse=True))
    #
    
    
    
main()