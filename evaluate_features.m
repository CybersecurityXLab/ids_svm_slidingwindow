dosfeaturesfilename = '.\matfiles\dosFeatures.mat';
doslabelsfilename = '.\matfiles\dosLabels.mat';
dosFeatures = load(dosfeaturesfilename);
dosLabels = load(doslabelsfilename);
u2rfeaturesfilename = '.\matfiles\u2rFeatures.mat';
u2rlabelsfilename = '.\matfiles\u2rLabels.mat';
u2rFeatures = load(u2rfeaturesfilename);
u2rLabels = load(u2rlabelsfilename);
r2lfeaturesfilename = '.\matfiles\r2lFeatures.mat';
r2llabelsfilename = '.\matfiles\r2lLabels.mat';
r2lFeatures = load(r2lfeaturesfilename);
r2lLabels = load(r2llabelsfilename);
probefeaturesfilename = '.\matfiles\probeFeatures.mat';
probelabelsfilename = '.\matfiles\probeLabels.mat';
probeFeatures = load(probefeaturesfilename);
probeLabels = load(probelabelsfilename);

%Model = load('testrundeletethisfile.mat');

numWindows = size(dosFeatures.dosFeatures.CVPacketSize,2);%choose one of the features to get the number of time windows for all. Choice is arbitrary.

featureWindowPerformance = strings;%data structure to keep track of the performance of feature/window combos
featureCounter = 0;%keeps track of which individual feature you are on

loopEnd = numWindows;% This is for testing purposes
%{
%dos
dosinds = ~strcmp(dosLabels.dosLabels.HLClass, 'r2l');
correctLabels = dosLabels.dosLabels.HLClass(dosinds); 

%create the beginning of the loop here to go through all features
fields = fieldnames(dosFeatures.dosFeatures);
for val = 1:(numel(fields)-9)%iterate through features
    disp(fields{val});
    %disp(dosFeatures.dosFeatures.(fields{val}));
    
    predictAllRTraffic = repmat({'R'},size(currentTestFeature,1),1);%to get a baseline for what the f1 score would be in the case of all traffic being predicted as 'R'




    for n = 1:4%loopEnd%numWindows%iterate through time windows
        disp(n);
        disp('dos')
        disp(fields{val});

        currentTestFeature = dosFeatures.dosFeatures.(fields{val})(dosinds,n);
        %currentTestFeature = dosFeatures.dosFeatures.SYNCount(dosinds, n);
        %binary SVM
        Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'dos'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

        %save testrundeletethisfile.mat Model

       predicted = kfoldPredict(Model);

       cv_svm_performance_all_features = classperf(correctLabels, predicted);
       baselinePerformance = classperf(correctLabels, predictAllRTraffic);%gives the F1 score when everything is guessed as regular traffic
       f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)
       baselineF1 = 2 * baselinePerformance.Sensitivity*baselinePerformance.PositivePredictiveValue/(baselinePerformance.Sensitivity+baselinePerformance.PositivePredictiveValue);
       [featureCounter,featureWindowPerformance] = recordFeatureScores('dos',fields{val},n,f1score,baselineF1,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);
        disp('___________________________________________________');


    end

end
%}
%{
%u2r
remove_probes = ~strcmp(u2rLabels.u2rLabels.HLClass, 'probe');
remove_r2l = ~strcmp(u2rLabels.u2rLabels.HLClass, 'r2l');
u2rinds = remove_probes & remove_r2l;%logical and of the two variables (which have elements of either 1 or 0)
correctLabels = u2rLabels.u2rLabels.HLClass(u2rinds);

fields = fieldnames(u2rFeatures.u2rFeatures);
for val = 1:(numel(fields)-8)
    disp(fields{val});
    %disp(dosFeatures.dosFeatures.(fields{val}));



    for n = 1:loopEnd%numWindows
        disp(n);
        disp('u2r');

        currentTestFeature = u2rFeatures.u2rFeatures.(fields{val})(u2rinds,n);
        %currentTestFeature = u2rFeatures.u2rFeatures.SYNCount(u2rinds, n);
        Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'u2r'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

        predicted = kfoldPredict(Model);

        cv_svm_performance_all_features = classperf(correctLabels, predicted);
        f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)
        [featureCounter,featureWindowPerformance] = recordFeatureScores('u2r',fields{val},n,f1score,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);
        disp('___________________________________________________');

    end
end

%probe
remove_u2r = ~strcmp(probeLabels.probeLabels.HLClass, 'u2r');
remove_r2l = ~strcmp(probeLabels.probeLabels.HLClass, 'r2l');
probeinds = remove_u2r & remove_r2l;
correctLabels = probeLabels.probeLabels.HLClass(probeinds); 

fields = fieldnames(probeFeatures.probeFeatures);
for val = 1:(numel(fields)-8)
    disp(fields{val});
    %disp(dosFeatures.dosFeatures.(fields{val}));



    for n = 1:loopEnd%numWindows
        disp(n);
        disp('probe');

        currentTestFeature = probeFeatures.probeFeatures.(fields{val})(probeinds,n);
        %currentTestFeature = probeFeatures.probeFeatures.SYNCount(probeinds, n);
        Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'probe'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

        predicted = kfoldPredict(Model);

        cv_svm_performance_all_features = classperf(correctLabels, predicted);
        f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)
        [featureCounter,featureWindowPerformance] = recordFeatureScores('probe',fields{val},n,f1score,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);
        disp('___________________________________________________');

    end
end
%}
%r2l
%{
remove_probes = ~strcmp(r2lLabels.r2lLabels.HLClass, 'probe');
remove_u2r = ~strcmp(r2lLabels.r2lLabels.HLClass, 'u2r');
remove_dos = ~strcmp(r2lLabels.r2lLabels.HLClass, 'dos');
r2linds = remove_probes & remove_u2r & remove_dos;%logical and of the three variables (which have elements of either 1 or 0)
correctLabels = r2lLabels.r2lLabels.HLClass(r2linds);



fields = fieldnames(r2lFeatures.r2lFeatures);
for val = 1:(numel(fields)-9)
    disp(fields{val});
    %disp(r2lFeatures.r2lFeatures.(fields{val}));




    for n = 6:7%loopEnd%numWindows
        %disp(n);
        %disp('r2l');
        fprintf('r2l feature %s time window %i ', fields{val}, n);

        currentTestFeature = r2lFeatures.r2lFeatures.(fields{val})(r2linds,n);
        predictAllRTraffic = repmat({'R'},size(currentTestFeature,1),1);%to get a baseline for what the f1 score would be in the case of all traffic being predicted as 'R'

        %currentTestFeature = r2lFeatures.r2lFeatures.SYNCount(r2linds, n);
        Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'r2l'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

        fprintf('Model trained\n');
        
        baselinePerformance = classperf(correctLabels, predictAllRTraffic);%gives the F1 score when everything is guessed as regular traffic
        baselineF1 = 2 * baselinePerformance.Sensitivity*baselinePerformance.PositivePredictiveValue/(baselinePerformance.Sensitivity+baselinePerformance.PositivePredictiveValue);

        
        predicted = kfoldPredict(Model);

        cv_svm_performance_all_features = classperf(correctLabels, predicted);
        f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)
        [featureCounter,featureWindowPerformance] = recordFeatureScores('r2l',fields{val},n,f1score,baselineF1,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);
        disp('___________________________________________________');

    end
end

%}

%r2l
%correctLabels = one_v_all_function('r2l', allLabels.AllLabels.HLClass());


function [featureCounter, featureWindowPerformance] = recordFeatureScores(attack,feature,window,f1score,baselineF1,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);

    disp(correctLabels(1));
    %[c, cm, ind, confMatrix] = confusion(correctLabels, predicted);%returns confusion matrix as 4th element. i1 fnr, i2 fpr, i3 tpr, i4 tnr.
    falsePositivesByLabel = getFalsePositives_function(correctLabels, predicted);

    
    featureWindowPerformance(((featureCounter * loopEnd)+window),1) = attack;
    featureWindowPerformance(((featureCounter * loopEnd)+window),2) = feature;
    featureWindowPerformance(((featureCounter * loopEnd)+window),3) = window;
    featureWindowPerformance(((featureCounter * loopEnd)+window),4) = f1score;
    featureWindowPerformance(((featureCounter * loopEnd)+window),5) = baselineF1;
    featureWindowPerformance(((featureCounter * loopEnd)+window),6) = f1score - baselineF1;
    featureWindowPerformance(((featureCounter * loopEnd)+window),7) = falsePositivesByLabel(5,2);
    featureWindowPerformance(((featureCounter * loopEnd)+window),8) = falsePositivesByLabel(6,2);
    featureWindowPerformance(((featureCounter * loopEnd)+window),9) = str2double(falsePositivesByLabel(5,2))/str2double(falsePositivesByLabel(6,2));
    
    if window == loopEnd
        featureCounter = featureCounter + 1;
    end
end
