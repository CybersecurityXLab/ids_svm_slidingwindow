# -*- coding: utf-8 -*-
"""
Created on Sat Feb  9 11:28:05 2019

@author: Casey

create custom metric to give score to evaluate performance for ranking in recursive feature elim

For this problem, standard classification metrics are inadequate. The nature of time windows presents 
an interesting metric problem when compared to usual classification tasks. A simple one to one 
comparison of prediction to label for each individual second does not completely capture the 
effectiveness of attack classification when an attack is a sequence of seconds, not a single second.
This means we not only want to maximize standard TPR, where each individual SECOND in an attack is
considered a positive, we also want to maximize the TPR when considering each individual ATTACK as 
a positive. 
For a simple example where 0 is a non-attack second and 1 is an attack second:[0,0,0,1,1,1,1,0,0,0]. 
In this example indeces 3, 4, 5, and 6 are each part of single, four-second attack. We not only want 
each index to be considered in its own right (a perfect TPR being 4/4 correctly classified positives),
we want the entire attack itself to be considered valueable (1/1 attacks in this 10 second interval
correctly classified). We don't simply want one or the other, both are important to maximize. For this
reason, we want to use both measures in our metric. These are standard TPR, and per-attack TPR. Per
attack TPR is calculated by if even 1 second is correctly classified as positive in the attack, the 
attack itself counts as a true positive.

In addition to these two metrics, we want to reduce the false positive rate, for well-established
reasons given in the base rate fallacy paper.

Another factor is that while we do want standard TPR to have value, if it is given equal weight to FPR 
and per-attack TPR, the standard TPR can overwhelm the score of the metric and give a poor score to an 
IDS that in reality performs very well with regards to total attacks detected and FPR.
For example, consider 1000 seconds, with 5 attacks, each 50 seconds. If the classifier has zero FPs
and correctly classifies 20/50 seconds in each attack as a positive, while in reality this would be
a very effective IDS, the score would be ((20*5/50*5) * 1.0 * 1.0) = 0.4, even though every attack
was classified as such, there were no false positives, and a large percentage of the individual 
seconds were classified as an attack relative to the number of false positives. 
For this reason, the standard TPR is weighted to only have 1/4 the importance of the other two measures.
This way, it still is considered, but it is not as important as actually detecting attacks or reducing
false positives. In an intuitive sense, a few missed time windows don't penalize the score all that much,
which is good, because they might not really matter.

Since we still want the score to be between 0 for the worst and 1 for a perfect prediction, the standard
TPR is weighted in a way that allows the scores to stay in this range with these attributes. This means
that instead of pure TPR, we want to reduce the penalization of this measure, while still keeping the
best and worse case of the TPR between 0 and 1. This is done by creating a functiono f the TPR, shown
below.   
f(tpr) = tpr / (tpr + (0.25*(1-tpr)))  #gives tpr 1/4 weight but still allows customMetric to be between 0 and 1


The final formula for the metric is given below:
    
customMetric = f(tpr) * tnr * perAttackTPR
0   <=   customMetric   <=   1


Adjustments should be made to the formula in the case of all 0s or all 1s in the correctly labelled
data. In these cases, simply remove the metrics where the denomintors would be 0.
"""
from sklearn.metrics import confusion_matrix


def main():
    actualY = [0,0,0,0,1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0]
    perfectY = actualY#everything predicted correct, should be 1, a perfect score
    
    allPosY = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]#all predicted positive. Useless. should be 0
    allNegY = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]#all predicted negative. Useless. should be 0
    sampleYBadThreshold = [0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]#perfect attack WINDOW percent (there could be multiple overlapping attacks), perfect rule 2, each attack only has 1 correctly positively classified second
    sampleYBadFPs = [0,1,0,1,1,0,0,0,1,1,1,0,1,1,1,1,0,1,0,1,1,1,1,1,1,1,0,1,0,0,1,1,0,1,0,0,0,0,1,0,0,1,1,0,0,0,0,1,1,0]#perfect attack percent, bad FP, good threshold
    sampleYBadAttackPercent = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]#missed half attacks, perfect fp, perfect threshold
    sampleYBadFPandThresh = [0,1,1,0,1,0,0,1,1,0,0,0,0,0,1,1,0,0,1,0,1,0,1,1,0,1,0,0,0,0,0,1,1,0,1,1,0,1,0,0,0,0,1,0,0,0,0,0,0,0]#perfect attacks, bad fp, bad threshold
    randomY = [1,1,0,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,0,0,1,1,1,1,1,1,0,1,1,0,0,0,0,1,1,0,0,1,1,1,0,1,1,1,0,0,0,1]
    sampleYBadThresholdQuarter = [0,0,0,0,1,0,0,0,1,1,1,0,1,1,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0]

    
    chosenList = sampleYBadThresholdQuarter
    
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


#eventually check to make sure all actualY are not the same (i.e. all 0s or all 1s). This will give nan, in the case of zero, use regular accuracy as the metric, which in this case is essentially the same thing as the TNR. In the case of all 1s, use custom metric without TNR. This because the FPR would have a denominator of 0, and would not be a relevant metric.
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
    
    totalAttacksCounted = 0
    
    for i in range(len(attackIndexList)):#for every attack
        for j in range(attackIndexList[i][1]):#for the number of seconds of an attack at current index
            if predictedY[attackIndexList[i][0] + j] == 1:
                totalAttacksCounted += 1# a single attack in the attack window was successfully found, break
                break
                
                
    print('total attacks',totalAttacksCounted)
    
    perAttackTPR = totalAttacksCounted / len(attackIndexList)
    print(perAttackTPR)
    
    #we want to use the TPR, but we only want to give it 1/4 weight. Getting every second classified in a window is not as important as classifying some of the correct seconds or reducing false positive rates
    # f(tpr) gives the value only 1/4 weight, but still keeps the final score between 0 (worst) and 1 (best)
    fOfTpr = tpr / (tpr + (0.25*(1-tpr)))
    print('weighted tpr', fOfTpr)
    
    #we want tpr to be tpr / (0.5*(1-tpr))
    
    oldcustomMetric = (tpr*tnr*perAttackTPR)
    print(oldcustomMetric)
    
    customMetric = fOfTpr * tnr * perAttackTPR
    
    print('pure tpr:',tpr, '\n\nweighted tpr:', fOfTpr, "\ntnr:",tnr,'\nperAttackTPR:',perAttackTPR,'\n\nCustom Metric Score:', customMetric)
    

main()