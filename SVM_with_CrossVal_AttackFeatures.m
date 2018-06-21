load('C:\Users\User\Downloads\Matlab\Features_w4_w5.mat');
%load('Labels.mat'); % what should the labels be?? first column?
DataFeatures = X(:,2:17); %Note: Col.'s 1 and 18 are NOT features
classOrder = unique(Y(:,2));

% Choose SVM template:
% rbf vs gaussian vs linear (no kernel at all): we could run both
%t =templateSVM('Standardize',1,'KernelFunction','rbf','KernelScale','auto');



%https://stats.stackexchange.com/questions/73032/linear-kernel-and-non-linear-kernel-for-support-vector-machine
%check this for kernel choice discussion



t = templateSVM('Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

% for loop for features
% for loop for time windows

%% Create and SVM Model using all features:
% ClassificationPartitionedModel (default: 10-fold cross validation; splits
% data into 10 parts and for each part makes predictions based on a model
% trained on remaining 90% of data)
CVMdl_all_features = fitcecoc(DataFeatures,Y(:,2),'CrossVal','on','Learners',t,'ClassNames',classOrder); 
% make predictions based on model
cvlabels_all_features = kfoldPredict(CVMdl_all_features);
cv_svm_performance_all_features = classperf(Y(:,2), cvlabels_all_features)
% calculating f1 score
f1score = 2*cv_svm_performance_all_features.Sensitivity*cv_svm_performance_all_features.PositivePredictiveValue/(cv_svm_performance_all_features.Sensitivity+cv_svm_performance_all_features.PositivePredictiveValue)

% %% Create and SVM Model using Sam's requested features:
% % ClassificationPartitionedModel (default: 10-fold cross validation; splits
% % data into 10 parts and for each part makes predictions based on a model
% % trained on remaining 90% of data)
% CVMdl_sam_features = fitcecoc(X(:,[3:9 11]),Y(:,2),'CrossVal','on','Learners',t,'ClassNames',classOrder); 
% cvlabels_sam_features = kfoldPredict(CVMdl_sam_features);
% cv_svm_performance_sam_features = classperf(Y(:,2), cvlabels_sam_features)
% 
% %% Create and Sparse SVM Model using results of Forward Selection:
% % ClassificationPartitionedModel (default: 10-fold cross validation; splits
% % data into 10 parts and for each part makes predictions based on a model
% % trained on remaining 90% of data)
% CVMdl_FS_features = fitcecoc(X(:,[3:9 11]),Y(:,2),'CrossVal','on','Learners',t,'ClassNames',classOrder); 
% cvlabels_FS_features = kfoldPredict(CVMdl_FS_features);
% cv_svm_performance_FS_features = classperf(Y(:,2), cvlabels_FS_features)

