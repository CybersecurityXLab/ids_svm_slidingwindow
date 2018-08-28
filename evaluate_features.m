dosfeaturesfilename = '.\matfiles\dosFeatures.mat';
doslabelsfilename = '.\matfiles\dosLabels.mat';
dosFeatures = load(dosfeaturesfilename);
dosLabels = load(doslabelsfilename);
u2rfeaturesfilename = '.\matfiles\u2rFeatures.mat';
u2rlabelsfilename = '.\matfiles\u2rLabels.mat';
u2rFeatures = load(u2rfeaturesfilename);
u2rLabels = load(u2rlabelsfilename);
%r2lfeaturesfilename = '.\matfiles\r2lFeatures.mat';
%r2llabelsfilename = '.\matfiles\r2lLabels.mat';
%r2lFeatures = load(r2lfeaturesfilename);
%r2lLabels = load(r2llabelsfilename);
probefeaturesfilename = '.\matfiles\probeFeatures.mat';
probelabelsfilename = '.\matfiles\probeLabels.mat';
probeFeatures = load(probefeaturesfilename);
probeLabels = load(probelabelsfilename);

%Model = load('testrundeletethisfile.mat');

dosinds = ~strcmp(dosLabels.dosLabels.HLClass, 'r2l');
correctLabels = dosLabels.dosLabels.HLClass(dosinds); 

%remove_probes = ~strcmp(u2rLabels.u2rLabels.HLClass, 'probe');
%remove_r2l = ~strcmp(u2rLabels.u2rLabels.HLClass, 'r2l');
%u2rinds = remove_probes & remove_r2l;%logical and of the two variables (which have elements of either 1 or 0)
%correctLabels = u2rLabels.u2rLabels.HLClass(u2rinds);

%r2linds = ~strcmp(dosLabels.dosLabels.HLClass, 'dos');
%correctLabels = r2lLabels.r2lLabels.HLClass(r2linds); 

%remove_u2r = ~strcmp(probeLabels.probeLabels.HLClass, 'u2r');
%remove_r2l = ~strcmp(probeLabels.probeLabels.HLClass, 'r2l');
%probeinds = remove_u2r & remove_r2l;
%correctLabels = probeLabels.probeLabels.HLClass(probeinds); 




%for n = 1:7
   % disp(n);
    
    currentTestFeature = dosFeatures.dosFeatures.SYNCount(dosinds, 6);
    Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'dos'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');
    
    %currentTestFeature = u2rFeatures.u2rFeatures.SYNCount(u2rinds, n);
    %Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'u2r'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

    %currentTestFeature = r2lFeatures.r2lFeatures.SYNCount(r2linds, n);
    %Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'r2l'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

    %currentTestFeature = probeFeatures.probeFeatures.SYNCount(probeinds, n);
    %Model = fitcsvm(currentTestFeature,correctLabels,'Classnames',{'R',  'probe'}, 'CrossVal', 'on','Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

    
    %save testrundeletethisfile.mat Model

    predicted = kfoldPredict(Model);

    cv_svm_performance_all_features = classperf(correctLabels, predicted);
    f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)
    disp('___________________________________________________');
%end

falsePositivesByLabel = getFalsePositives_function(correctLabels, predicted);