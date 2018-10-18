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

%data = load('.\randFeatureWindowCombo');
data = load('.\randFeatureWindowCombo2');

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

%currentTestFeatureSet = featurecombiner_function();%for multiple time windows per feature
%currentTestFeatureSet = singlewindowfeaturecombiner_function();%for single time window per feature
[indexedAttackList,attackPercentageList] = correctness_analyzer_function();
attackPercentageList(:,3:5) = zeros(size(attackPercentageList(1)));

%Model = fitcecoc(data.data,correctLabels,'Learners',t,'Classnames',{'R', 'u2r', 'dos',  'probe', 'r2l'}, 'CrossVal', 'on');
%Model = fitcecoc(features,correctLabels,'Learners',t,'Classnames',{'R', 'u2r', 'dos', 'probe', 'r2l'}, 'CrossVal', 'on');
%Model = fitcecoc(data.currentTestFeatureSet,correctLabels,'Learners',t,'Classnames',{'R', 'u2r', 'dos',  'probe', 'r2l'}, 'CrossVal', 'on');
%Model = fitcecoc(currentTestFeatureSet,correctLabels,'Learners',t,'Classnames',{'R', 'u2r', 'dos',  'probe', 'r2l'}, 'CrossVal', 'on');


%save the model so that it doesn't have to be rerun every time
%save MULTICLASSMODEL2week4n5.mat Model

predicted = kfoldPredict(Model.Model);%, features);
%predicted = kfoldPredict(Model);
%predicted = predict(Model.Model, features);

cv_svm_performance_all_features = classperf(correctLabels, predicted);
f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)


%keeps track of current index for attackPercentageList
attackPercentageListCounter = 1;
%keeps track of true positives
truePositiveCount = 0;

for val = (2:size(indexedAttackList))
    if ~((str2double(indexedAttackList(val,2)) - str2double(indexedAttackList(val-1,2)) == 1))%the cells of the second column are not contiguous, therefore are a different attack
        attackPercentageListCounter = attackPercentageListCounter + 1;
        truePositiveCount = 0;%restart count for next attack
    end

    if strcmp(predicted(str2double(indexedAttackList(val,2))), indexedAttackList(val,1)) == 1%if there is one match, add to list
        attackPercentageList(attackPercentageListCounter,3) = 1;
        truePositiveCount = truePositiveCount + 1;
        attackPercentageList(attackPercentageListCounter,4) = truePositiveCount;
    end
end

attackPercentageList(:,5) = str2double(attackPercentageList(:,4))./str2double(attackPercentageList(:,2));%5th col is percentage true pos


falsePositivesByLabel = getFalsePositives_function(correctLabels, predicted);