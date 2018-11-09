%to run on node 2 regular traffic features 6 - 10
addpath(genpath('..'))

allFeatures = load('..\feature_sets\allFeatures.mat');
allLabels = load('..\feature_sets\allLabels.mat');
copiedFeatures = zeros(size(allFeatures.AllFeatures.CVPacketSize,1),35);%move all features to this struct to test functionality
numWindows = size(allFeatures.AllFeatures.CVPacketSize,2);%choose one of the features to get the number of time windows for all. Choice is arbitrary.
disp(numWindows);

fields = fieldnames(allFeatures.AllFeatures)

currentAttack = strings(size(allFeatures.AllFeatures.CVPacketSize,1),2);
correctLabels = one_v_all_function('R', allLabels.AllLabels.HLClass());
currentAttack(:,1) = allLabels.AllLabels.HLClass();
currentAttack(:,2) = correctLabels;

tic = cputime;
parfor i = 1:35
    currentField = 0;%since parafor loops cannot be nested arithmetic is to decide the field to run
    if(i < 8)
       currentField=6
    elseif(i < 15)
       currentField=7
    elseif(i < 22)
       currentField=8
    elseif(i < 29)
       currentField=9
    elseif(i < 36)
       currentField=10
    end
   currentWindow = mod(i-1,7)+1%gets 7 time windows%format necessary bc matlab starting index is 1
   disp(fields(currentField));
   disp(currentWindow);
   disp(i);
   
   currentTestFeature = allFeatures.AllFeatures.(fields{currentField})(:,currentWindow);
   
   copiedFeatures(:,i) = allFeatures.AllFeatures.(fields{currentField})(:,currentWindow);
 
end
toc = cputime
save('.\saved_workspaces\node2ws.mat');