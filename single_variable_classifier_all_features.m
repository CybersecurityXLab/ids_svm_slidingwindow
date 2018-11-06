%runs a single variable classifier on every feature/window combo. Saves
%f1score and other measure in featureWindowPerformance table

%scale matlabe data from link
%https://www.mathworks.com/help/matlab/ref/normalize.html. Min-max
%normalization (between zero and one) is specified as the parameter 'range'
%allFeatures = load('.\feature_sets\allFeatures.mat');
%allLabels = load('.\feature_sets\allLabels.mat');

allFeatures = load('.\zscore_feature_sets\allFeatures.mat');
allLabels = load('.\zscore_feature_sets\allLabels.mat');
memory
%Model = load('testrundeletethisfile.mat');

numWindows = size(allFeatures.AllFeatures.CVPacketSize,2);%choose one of the features to get the number of time windows for all. Choice is arbitrary.
disp(numWindows);
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

%u2r
fields = fieldnames(allFeatures.AllFeatures);
correctLabels = one_v_all_function('u2r', allLabels.AllLabels.HLClass());

for val = 1:(numel(fields)-9)
    disp(fields{val});
    %for n = 6:7%loopEnd%numWindows
    n = 6
        tic = cputime;
        fprintf('u2r feature %s time window %i...', fields{val}, n);
        currentTestFeature = allFeatures.AllFeatures.(fields{val})(:,n);
        predictAllOtherTrafficTypes = repmat({'not'},size(currentTestFeature,1),1);%to get a baseline for what the f1 score would be in the case of all traffic being predicted as 'not' (i.e. anything but r2l)
       % predictAllCorrectTrafficType = repmat({'u2r'},size(currentTestFeature,1),1);%to get a baseline for what the f1 score would be in the case of all traffic being predicted as 'r2l'
       % memory
        Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'not',  'u2r'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');
        
        fprintf('Model trained\n');
        
        baselinePerformanceNotU2R = classperf(correctLabels, predictAllOtherTrafficTypes);%gives the F1 score when everything is guessed as regular traffic
        baselineF1NotU2R = 2 * baselinePerformanceNotU2R.Sensitivity*baselinePerformanceNotU2R.PositivePredictiveValue/(baselinePerformanceNotU2R.Sensitivity+baselinePerformanceNotU2R.PositivePredictiveValue);

        predicted = kfoldPredict(Model);
        
        cv_svm_performance_all_features = classperf(correctLabels, predicted);
        f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)

        %[featureCounter,featureWindowPerformance] = recordFeatureScores('u2r',fields{val},n,f1score,baselineF1NotU2R, baselineF1U2R,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);

        [featureCounter,featureWindowPerformance] = recordFeatureScores('u2r',fields{val},n,f1score,baselineF1NotU2R,correctLabels,predicted,loopEnd,featureCounter,featureWindowPerformance);
        toc = cputime;
        fprintf('this run took %i seconds\n', toc-tic);
        disp('___________________________________________________');

        n = n + 2;%to exit loop
        
    %end
end

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
    
    
    [indexedAttackList,attackPercentageList] = correctness_analyzer_function_single_variable(attack);
    attackPercentageList(:,3:5) = zeros(size(attackPercentageList(1)));
    
    
    
    %keeps track of current index for attackPercentageList
    attackPercentageListCounter = 1;
    %keeps track of true positives
    truePositiveCount = 0;

    for val = (2:size(indexedAttackList))
        if ~((str2double(indexedAttackList(val,2)) - str2double(indexedAttackList(val-1,2)) == 1))%the cells of the second column are not contiguous, therefore are a different attack
            attackPercentageListCounter = attackPercentageListCounter + 1;%index of the row of attackePercentageList
            truePositiveCount = 0;%restart count for next attack
        end

        if strcmp(predicted(str2double(indexedAttackList(val,2))), indexedAttackList(val,1)) == 1%if there is one match, add to list
            attackPercentageList(attackPercentageListCounter,3) = 1;
            truePositiveCount = truePositiveCount + 1;
            attackPercentageList(attackPercentageListCounter,4) = truePositiveCount;
        end
    end
    
    %attackPercentageList(:,5) = str2double(attackPercentageList(:,4))./str2double(attackPercentageList(:,2));%5th col is percentage true pos
    
    %attack feature window
    
    %create filename to save correct guess percentage
    %s = '.\single_var_classifier_percentages\';
    %s = strcat(attack);
    %s = strcat(s,feature);
    %s = strcat(s,int2str(window));
    %s = strcat(s,'.mat');
   % disp(s);
    %save(s);

    %featureWindowPerformance(((featureCounter * loopEnd)+window),10) = struct(attackPercentageList);
    
    
    %
    if window == loopEnd
        featureCounter = featureCounter + 1;%keeps track of which feature we are on to tell the table which row to update
    end
end
