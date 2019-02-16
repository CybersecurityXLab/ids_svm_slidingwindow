# -*- coding: utf-8 -*-
"""
Created on Sat Feb  9 11:28:05 2019

@author: Casey

create custom metric to give score to evaluate performance for ranking in recursive feature elim

For this problem, standard classification metrics are inadequate. The nature of time windows for attacks 
presents an interesting metric problem when compared to usual classification tasks. A simple one to one 
comparison of prediction to label for each individual second does not completely capture the 
effectiveness of attack classification when an 'attack' is better defined as a sequence of seconds, not a single 
second. This means we not only want to maximize standard TPR, where each individual SECOND in an attack is
considered a positive, we also want to maximize the TPR when considering each individual ATTACK as 
a positive. 
A simple 10 sec example where 0 is a non-attack second and 1 is an attack second:[0,0,0,1,1,1,1,0,0,0]. 
In this example indeces 3, 4, 5, and 6 are each part of single, four-second attack. We not only want 
each index to be considered in its own right (a perfect standard TPR being 4/4 correctly classified positives),
we also want the classification of the entire attack itself to be considered (a perfect per-attack TPR being 1/1
correctly classified attacks). We don't simply want one or the other, both are important to maximize. For this
reason, we want to use both measures in our metric. These are standard TPR, and per-attack TPR. A true positive 
in per-attack TPR is defined as: when even 1 second is correctly classified as positive in the attack window,
the attack itself counts as a true positive.

In addition to these two metrics, we want to reduce the false positive rate, for well-established
reasons given in the base rate fallacy paper.

Another factor is that while we do want standard TPR to help define a score, if it is given equal weight as FPR 
and per-attack TPR, the standard TPR can overwhelm the score of the metric and give a poor score to an 
IDS that in reality performs very well with regards to total attacks detected and FPR in a practical sense.
For example, consider 1000 seconds, with 5 attacks, each 50 seconds. If the classifier has zero FPs
and correctly classifies 20/50 seconds in each attack as a positive, this would be an effective IDS
in reality, but the score would be ((20*5/50*5) * 1.0 * 1.0) = 0.4. Even though every attack
was classified as such, there were no false positives, and a large percentage of the individual 
seconds were classified as an attack relative to the number of false positives. 
For this reason, the standard TPR is weighted to only have 1/4 the importance of the other two measures.
This way, it still is used to measure performance, but it is not as important as actually detecting attacks 
or reducing false positives. In an intuitive sense, a few missed seconds don't penalize the score all 
that much when the overall attack is detected. However, if very large percentage of individual seconds are
missed, the score is penalized (because the true positives make up a small percentage of actual positives, 
therefore the true positives do not look confident percentage-wise, and therefore they start to look like 
false positives. Thus a true positive is more likely to be ignored by an analyst, and become a false negative).

Since we still want the score to be between 0 for the worst and 1 for a perfect prediction, the standard
TPR is weighted in a way that allows the scores to stay in this range with these attributes. This means
that instead of pure TPR, we want to reduce the penalization of this measure, while still keeping the
worst and best case of the TPR between 0 and 1. This is done by creating a function of the TPR, shown
below.   
f(tpr) = tpr / (tpr + (0.25*(1-tpr)))  #gives tpr 1/4 weight but still allows customMetric to be between 0 and 1

We also penalize FPR by 50%. The formula is given below. This equivalently gives double weight to TNR
f(fpr) = fpr / (fpr + (0.5*(1-fpr)))
f(tnr) = 1 - f(fpr)

The final formula for the metric is given below:
    
customMetric = f(tpr) * f(tnr) * perAttackTPR
0   <=   customMetric   <=   1


Adjustments should be made to the formula in the case of all 0s or all 1s in the correctly labelled
data. In these cases, to calculate customMetric, simply remove the metrics where the denomintors 
would be 0. This can be done in the form of a simple check. If the denom equals 0, simply set the value
of that metric to 1.

Current work. In the reg vs all attacks (R = 0; u2r, r2l, dos, or probe = 1), Use custom metric, 
accuracy, and f1 to rank RFE performance. compare performances of final feature sets of F1, accuracies, 
false positives, true positives, attacks detected percentages, and custom metric of the selected features 
for ranking metric. My hypothesis is each score used to rank (F1, acc, and custom) will be highest in the scenario
that it is used to rank, but custom will be highest not only in its own score, but also have the least FPs and 
most detected attacks (per-attack TPR), and maybe standard (per-second) TPR. 
Probably do this on 16 second time window. Verify again using optimally selected features/windows at the end
if time/resources allow.
Also consider adding F1 * perAttackTPR. See which is best.

future work should look into this three factors and find the weights for each that most correspond to best
security incident reduction for analyst team

#Note. If all are predicted 0s or 1s it may be better to determine more than just 0 or 1 for score

"""
from sklearn.metrics import confusion_matrix, accuracy_score


def main():
    #each of the lists below has a description of what the are supposed to be
    actualY = [0,0,0,0,1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0]#sample correct labels. 0 for regular. 1 for attack
    perfectY = actualY#everything predicted correct, should be 1, a perfect score
    
   # test = [1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    
    allPosY = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]#all predicted positive. Useless. should be 0
    allNegY = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]#all predicted negative. Useless. should be 0
    
    sampleYBadThreshold = [0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]#percentage of standard TPR very poor, perfect TNR, perfect per-attack TPR,
    sampleYBadFPs = [0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,1,1,1,1]#perfect standard TPR, bad FP, perfect per-attack TPR
    sampleYBadAttackPercent = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]# perfect standard TPR (of detected attacks), perfect fp, missed half attacks
    sampleYBadFPandThresh = [0,1,1,0,1,0,0,1,1,0,0,0,0,0,1,1,0,0,1,0,1,0,1,1,0,1,0,0,0,0,0,1,1,0,1,1,0,1,0,0,0,0,1,0,0,0,0,0,0,0]#bad standard TPR, bad fp, perfect per-attack TPR
    randomY = [1,1,0,0,0,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,0,0,1,1,1,1,1,1,0,1,1,0,0,0,0,1,1,0,0,1,1,1,0,1,1,1,0,0,0,1]#randomly assign 0s and 1s. Should give very poor score
    sampleYGoodThresh = [0,0,0,0,1,0,0,0,1,1,1,1,1,1,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0]#only misses 1 second from 1 attack. No FPs. Should still have a high score

    
    #first param is ground truth/correct values. second param is predicted
    #adjust try any relevant combo of correct and predicted value and see score returned
    #with this metric, a very high score is hard to achieve in most real scenarios. somewhere in the 70s or 80s is a good score for practical purposes (low fps, high attacks detected, decent percentage of attack seconds detected)
    customMetric = getCustomMetric(actualY,perfectY)

    print(customMetric)
    return customMetric

#attack indeces for total attack calc
#save the first index of attack window, and num of pos seconds as a list ex ([34, 7]) means index 34 has 7 seconds of attack
#when verifying, jump to index 34 of the predicted. If any of the predicted value at index == any of the actual value at index, increment 1 to total attack windows correctly classified. break current window loop
#after this, find the percentage of attacks classified with at least 1 window as an attack.


#eventually check to make sure all actualY are not the same (i.e. all 0s or all 1s).  In the case of all 1s, use custom metric without TNR. This because the FPR would have a denominator of 0, and would not be a relevant metric.
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
    
    if totalPositives == len(actualY):
        val = allPositive(actualY,predictedY,attackIndexList,totalPositives)
        print('here')
    elif totalPositives == 0:
        val = allNegative(actualY,predictedY)
    else:
        val = posAndNegValues(actualY,predictedY,attackIndexList,totalPositives,totalNegatives)
        
    #val contains f(tpr), f(tnr), and per attack tpr in that order.
    print(val)
    print('\n\nweighted tpr:', val[0], "\nweighted tnr:",val[1],'\nperAttackTPR:',val[2],'\n')#,'\n\nCustom Metric Score:', customMetric)

    return val[0] * val[1] * val[2]
    
def calcPerAttackTPR(predictedY, attackIndexList):
    totalAttacksCounted = 0
    
    for i in range(len(attackIndexList)):#for every attack
        for j in range(attackIndexList[i][1]):#for the number of seconds of an attack at current index
            if predictedY[attackIndexList[i][0] + j] == 1:
                totalAttacksCounted += 1# a single attack in the attack window was successfully found, break
                break
                
                
    print('total attacks',totalAttacksCounted)
    
    perAttackTPR = totalAttacksCounted / len(attackIndexList)
    return perAttackTPR

def posAndNegValues(actualY,predictedY,attackIndexList,totalPositives,totalNegatives):
    tn, falsePositives, fn, truePositives = confusion_matrix(actualY,predictedY).ravel()
    print(truePositives, falsePositives)

    perAttackTPR = calcPerAttackTPR(predictedY,attackIndexList)
    print(perAttackTPR)

        
     #the true positive rate is the total number of true positives predicted as such divided by the total number of true positives (i.e. the sum of the second column in the attackIndexList)
    tpr = truePositives/totalPositives
    fpr = falsePositives/totalNegatives
    print('fpr',fpr)
    fOfTnr = 1 - fOfFPR(fpr)
    fOfTpr = fOfTPR(tpr)
       
    
    #we want to use the TPR, but we only want to give it 1/4 weight. Getting every second classified in a window is not as important as classifying some of the correct seconds or reducing false positive rates
    # f(tpr) gives the value only 1/4 weight, but still keeps the final score between 0 (worst) and 1 (best)
    
    print('weighted tpr', fOfTpr)

    
    return fOfTpr, fOfTnr, perAttackTPR

def allPositive(actualY,predictedY,attackIndexList,totalPositives):
    print('the entire list is positive')
    TNR = 1#there are no negs, therefore denom is 0, therefore set value to 1 to eliminate TNR effect on formula
    
    truePositives = confusion_matrix(actualY,predictedY).ravel()#bad sklearn design, returns only 1 val if perfect, else returns 4, must be handled
    print(truePositives)
    #everything is wrong, final score is 0
    if(len(truePositives)==1):#there everything is predicted 1, i.e. everything is right. score of 1
        print('score of 1')
        return 1, 1, 1.0
    
    
    #default to weighted accuracy score which penalizes incorrect 1s more than incorrect 0s. 
    #This is because since the TNR will always be 0, when all are predicted 1s, it will get a score of 0 regardless if 1 or n-1 are correct.
    #we still wish to penalize FPs more than FNs, since the attack is composed of multiple seconds.
    #This implies predicting all 1s will be penalized more heavily than predicting all 0s
    tn, falsePositives, fn, truePositives = confusion_matrix(actualY,predictedY).ravel()#normal case. not a perfect score
    #print(truePositives)
    
    #Verify that per attack TPR does not matter in this case by uncommenting two lines below this comment. 
    #If the normal TPR is >1, perattack tpr = 1, leaving it the same. 
    #If standard tpr is 0, so is per attack tpr, again leaving it the same. For practical purposes, per attack TPR can be set to 1 in either case and give the correct score
    #perAttackTPR = calcPerAttackTPR(predictedY,attackIndexList)
    #print(perAttackTPR)
    
    perAttackTPR = 1
    
    tpr = truePositives/totalPositives
    #print(tpr)
    fOfTpr = fOfTPR(tpr)#still needs to be weighted for same reasons as usual case
    return fOfTpr, TNR, perAttackTPR
    
    
#This will give nan, in the case of zero, use regular accuracy as the metric, which in this case is essentially the same thing as the TNR.  
#There are no true positives of either standard or per-attack TPR (i.e. both denoms are 0. set them to 1 in formula)
def allNegative(actualY,predictedY):
    print('the entire list is negative')
    #set the two variables below to 1 because for normal calcuation, they would have a value of 0
    fOfTpr = 1
    perAttackTPR = 1
    
    #in this case, since there are no positives, the TNR is equal to accuracy
   # TNR = accuracy_score(actualY,predictedY)#,normalize=True)
   # accuracy_score()
  #  print(TNR)
  
    truePositives = confusion_matrix(actualY,predictedY).ravel()#bad sklearn design, returns only 1 val if perfect, else returns 4, must be handled
  
    if(len(truePositives)==1):#there everything is predicted 0, i.e. everything is right. score of 1
        print('score of 1')
        return 1, 1, 1.0
    
    
    #to verify that accuracy is correct for the scenario of all zeros in actualY, note that
    #accuracy gives the exact same score as below lines, which use the full TNR formula
    tn, falsePositives, fn, truePositives = confusion_matrix(actualY,predictedY).ravel()
    print(tn, falsePositives, fn, truePositives)
    FPR = falsePositives/(tn + falsePositives)
    #TNR = 1 - FPR
    #print(TNR)
    fOfTNR = 1 - fOfFPR(FPR)
    
    return fOfTpr, fOfTNR, perAttackTPR
    
#function of TPR
def fOfTPR(tpr):
    return tpr / (tpr + (0.25*(1-tpr)))

#function of FPR
def fOfFPR(fpr):
    return fpr / (fpr + (0.25*(1-fpr)))

main()