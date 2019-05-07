# -*- coding: utf-8 -*-
"""
Created on Tue May  7 12:34:00 2019

@author: User
"""
import numpy as np

def oneVAll(attack, table):
    print('Attack type: ', attack)
  #  if(attack=='all'):
  #      return attackVsR(attack,table)
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