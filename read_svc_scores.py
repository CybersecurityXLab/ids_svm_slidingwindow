# -*- coding: utf-8 -*-
"""
Created on Wed Jan  2 12:50:36 2019

@author: Casey

Read serialized feature performance data for single variable classifier
"""
from joblib import  dump, load
def main():
    print('loaded info:')
    allScores = []
    allScores.append([load("./parallel_temp_files/test57.txt"),'57'])
    allScores.append([load("./parallel_temp_files/test58.txt"),'58'])
    allScores.append([load("./parallel_temp_files/test59.txt"),'59'])
    allScores.append([load("./parallel_temp_files/test60.txt"),'60'])
    allScores.append([load("./parallel_temp_files/test61.txt"),'61'])
    print(allScores)
    #
    
main()