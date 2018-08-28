%load fisheriris
%allfeaturesfilename = 'allFeatures.mat';
%alllabelsfilename = 'allLabels.mat';
allfeaturesfilename = '.\matfiles\allFeatures.mat';
alllabelsfilename = '.\matfiles\allLabels.mat';
%dosfeaturesfilename = '.\matfiles\dosFeatures.mat';
%doslabelsfilename = '.\matfiles\dosLabels.mat';
%u2rfeaturesfilename = '.\matfiles\u2rFeatures.mat';
%u2rlabelsfilename = '.\matfiles\u2rLabels.mat';
%u2rFeatures = load(u2rfeaturesfilename);
%u2rLabels = load(u2rlabelsfilename);
%dosFeatures = load(dosfeaturesfilename);
%dosLabels = load(doslabelsfilename);
allFeatures = load(allfeaturesfilename);
allLabels = load(alllabelsfilename);

data = load('.\randFeatureWindowCombo');

%Model = load('.\MULTICLASSMODEL');
%Model = load('.\MULTICLASSMODEL3mpi');
%Model = load('.\MULTICLASSMODEL3mpacksizecval');
%Model = load('..\filestoolarge\MULTICLASSMODELfeaturecombinertest1All.mat');
%Model = load('..\filestoolarge\MULTICLASSMODELfeaturecombinertest2.mat');
Model = load('..\filestoolarge\MULTICLASSMODEL1week4n5.mat');

%rng(1);
t = templateSVM('Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

allinds = ~strcmp(allLabels.AllLabels.HLClass, 'asdfasdf');%converts allinds to ones
%features = allFeatures.AllFeatures.ThirdMomentPacketInterarrival(allinds, 1:7);
%features = allFeatures.AllFeatures.SYNCount(allinds, 4:7);
%features = allFeatures.AllFeatures.SYNCount(allinds, 7);
%features = allFeatures.AllFeatures.HTTPorFTPandExeCodeCount(allinds,1:7);
%features = allFeatures.AllFeatures.ThirdMomentPacketSize(allinds,1:7);
correctLabels = allLabels.AllLabels.HLClass(allinds);

%currentTestFeatureSet = featurecombiner_function();
[indexedAttackList,attackPercentageList] = correctness_analyzer_function();
attackPercentageList(:,3:5) = zeros(size(attackPercentageList(1)));

%Model = fitcecoc(data.data,correctLabels,'Learners',t,'Classnames',{'R', 'u2r', 'dos',  probe', 'r2l'}, 'CrossVal', 'on');
%Model = fitcecoc(features,correctLabels,'Learners',t,'Classnames',{'R', 'u2r', 'dos', 'probe', 'r2l'}, 'CrossVal', 'on');

%save the model so that it doesn't have to be rerun every time
%save MULTICLASSMODELfeaturecombinertest2.mat Model

predicted = kfoldPredict(Model.Model);%, features);
%predicted = predict(Model.Model, features);

cv_svm_performance_all_features = classperf(correctLabels, predicted);
f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)


%keeps track of current index for attackPercentageList
attackPercentageListCounter = 1;
%keeps track of true positives
truePositiveCount = 0;

for val = (2:size(indexedAttackList))
    if ~((str2double(indexedAttackList(val,2)) - str2double(indexedAttackList(val-1,2)) == 1))%the cells are not contiguous, therefore are a different attack
        attackPercentageListCounter = attackPercentageListCounter + 1;
        truePositiveCount = 0;
    end

    if strcmp(predicted(str2double(indexedAttackList(val,2))), indexedAttackList(val,1)) == 1%if there is one match, add to list
        attackPercentageList(attackPercentageListCounter,3) = 1;
        truePositiveCount = truePositiveCount + 1;
        attackPercentageList(attackPercentageListCounter,4) = truePositiveCount;
    end
end

attackPercentageList(:,5) = str2double(attackPercentageList(:,4))./str2double(attackPercentageList(:,2));%5th col is percentage true pos


%calculate false positive percentages of regular traffic
falsePositivesByLabel = strings;
falsePositivesByLabel(1,1) = 'dos';
falsePositivesByLabel(2,1) = 'u2r';
falsePositivesByLabel(3,1) = 'r2l';
falsePositivesByLabel(4,1) = 'probe';
falsePositivesByLabel(5,1) = 'total';
falsePositivesByLabel(:,2) = zeros;

totalFalsePositiveCount = 0;
dosFalsePositiveCount = 0;
u2rFalsePositiveCount = 0;
r2lFalsePositiveCount = 0;
probeFalsePositiveCount = 0;
for val = (1:size(correctLabels))
    if strcmp(correctLabels(val), 'R') & ~strcmp(predicted(val),'R')
        if (strcmp(predicted(val),falsePositivesByLabel(1,1)))
            dosFalsePositiveCount = dosFalsePositiveCount + 1;
        
        elseif (strcmp(predicted(val),falsePositivesByLabel(2,1)))
            u2rFalsePositiveCount = u2rFalsePositiveCount + 1;
                
        elseif (strcmp(predicted(val),falsePositivesByLabel(3,1)))
            r2lFalsePositiveCount = r2lFalsePositiveCount + 1;
        elseif (strcmp(predicted(val),falsePositivesByLabel(4,1)))
            probeFalsePositiveCount = probeFalsePositiveCount + 1;
        end
        totalFalsePositiveCount = totalFalsePositiveCount + 1;
    end
end

falsePositivesByLabel(1,2) = dosFalsePositiveCount;
falsePositivesByLabel(2,2) = u2rFalsePositiveCount;
falsePositivesByLabel(3,2) = r2lFalsePositiveCount;
falsePositivesByLabel(4,2) = probeFalsePositiveCount;
falsePositivesByLabel(5,2) = totalFalsePositiveCount;