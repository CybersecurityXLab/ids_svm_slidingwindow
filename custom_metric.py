# -*- coding: utf-8 -*-
"""
Created on Sat Feb  9 11:28:05 2019

@author: Casey


create custom metric
"""
from sklearn.metrics import confusion_matrix


def main():
    actualY = [0,0,0,0,1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0]
    
    allPosY = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    allNegY = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    perfectY = actualY
    sampleYBadThreshold = [0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]#perfect attack WINDOW percent (there could be multiple overlapping attacks), perfect rule 2, each attack only has 1 correctly positively classified second
    sampleYBadFPs = [0,1,0,1,1,0,0,0,1,1,1,0,1,1,1,1,0,1,0,1,1,1,1,1,1,1,0,1,0,0,1,1,0,1,0,0,0,0,1,0,0,1,1,0,0,0,0,1,1,0]#perfect attack percent, bad FP, good threshold
    sampleYBadAttackPercent = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]#missed half attacks, perfect fp, perfect threshold
    sampleYBadFPandThresh = [0,1,1,0,1,0,0,1,1,0,0,0,0,0,1,1,0,0,1,0,1,0,1,1,0,1,0,0,0,0,0,1,1,0,1,1,0,1,0,0,0,0,1,0,0,0,0,0,0,0]#perfect attacks, bad fp, bad threshold
    
    chosenList = sampleYBadThreshold
    
    getCustomMetric(actualY,chosenList)

#I think that the threshold should  be weighted to carry less of a penalty. It is a harder problem to solve, and often times, 1 or a few positives per attack is enough. We still want to maximize, but we don't want to penalize for ex, a classifier that correctly classifies some of every attack and has no FPs, which would still likely get a low score
#we decided to give the threshold half the weight of the other variables. To keep the score from 0 to 1, the entire equation was multiplied by two
#future work should look into this three factors and find the weights that most correspond to best security reduction for analyst team

# for threshold and FP
#avg number of correctly predicted per attack window is same as TPR, sensitiveity, or recall
#1 - FPR = TNR

#attack indeces for total attack calc
#save the first index of attack window, and num of pos seconds as a list ex ([34, 7]) means index 34 has 7 seconds of attack
#when verifying, jump to index 34 of the predicted. If any of the predicted value at index == any of the actual value at index, increment 1 to total attack windows correctly classified. break current window loop
#after this, find the percentage of attacks classified with at least 1 window as an attack.

def getCustomMetric(actualY,predictedY):
    
    attackIndexList = []
    indexCounter = 0
    totalPositives = 0#the true positives is the index counter, but it is never reset
    wasAttack = False#status of whether prev second was attack
    attackStartIndex = 0
    for idx in range(len(actualY)):
        if actualY[idx] == 1:
            indexCounter += 1#increment number of seconds of current attack
            totalPositives += 1
            if not wasAttack:#only add the first second to the indexList
                attackStartIndex = idx
            wasAttack = True
            if idx == len(actualY)-1:#if it is the last index and an attack
                attackIndexList.append([attackStartIndex, indexCounter])
        else:#the value was 0
            if wasAttack:
                attackIndexList.append([attackStartIndex, indexCounter])
                indexCounter = 0
            wasAttack = False    
                #if the previous was attack, change wasAttack, resetIndexCounter,append to attackIndexList
    
    #true negatives is the actual length of the vector minus the number of true positives
    totalNegatives = len(actualY) - totalPositives
    
    print(attackIndexList)
    
    tn, falsePositives, fn, truePositives = confusion_matrix(actualY,predictedY).ravel()
    print(truePositives, falsePositives)
    
    #the true positive rate is the total number of true positives predicted as such divided by the total number of true positives (i.e. the sum of the second column in the attackIndexList)
    tpr = truePositives/totalPositives
    fpr = falsePositives/totalNegatives
    tnr = 1 - fpr
    
    #print(truePositives/totalPositives)#TPR
    #fpr = falsePositives/totalNegatives#FPR
    #print(1-fpr)#TNR
    totalAttacksCounted = 0
    
    for i in range(len(attackIndexList)):#for every attack
        for j in range(attackIndexList[i][1]):#for the number of seconds of an attack at current index
            if predictedY[attackIndexList[i][0] + j] == 1:
                totalAttacksCounted += 1# a single attack in the attack window was successfully found, break
                break
                
                
    print('total attacks',totalAttacksCounted)
    
    perAttackTPR = totalAttacksCounted / len(attackIndexList)
    print(perAttackTPR)
    
    fOfTpr = tpr / (tpr + (0.25*(1-tpr)))
    print('weighted tpr', fOfTpr)
    
    #we want tpr to be tpr / (0.5*(1-tpr))
    
    oldcustomMetric = (tpr*tnr*perAttackTPR)
    print(oldcustomMetric)
    
    customMetric = fOfTpr * tnr * perAttackTPR
    
    print('\ntpr:',tpr,"\ntnr:",tnr,'\nperAttackTPR:',perAttackTPR,'\n\nCustom Metric Score:', customMetric)
    

'''
#total attacks

countSwitch = False
prevState = False

totalAttacks = 0


for idx in range(len(actualY)-1):#count the number of times the label changes# for every other change, increment the attack
    if actualY[idx] == actualY[idx + 1]:#was changed. Later divide by 2 since this is binary
        totalAttacks += 1
    
if actualY[0] == 1:#if the first element is 1, zeros are counted as the 'attack'. Subtract 1 from total count
        
'''

main()