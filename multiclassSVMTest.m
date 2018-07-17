load fisheriris
dosfeaturesfilename = 'C:\Users\User\Documents\GitHub\ids_svm_slidingwindow\dosFeatures.mat';
doslabelsfilename = 'C:\Users\User\Documents\GitHub\ids_svm_slidingwindow\dosLabels.mat';
u2rfeaturesfilename = 'C:\Users\User\Documents\GitHub\ids_svm_slidingwindow\u2rFeatures.mat';
u2rlabelsfilename = 'C:\Users\User\Documents\GitHub\ids_svm_slidingwindow\u2rLabels.mat';
u2rFeatures = load(u2rfeaturesfilename)
u2rLabels = load(u2rlabelsfilename)
dosFeatures = load(dosfeaturesfilename)
dosLabels = load(doslabelsfilename)

rng(1);
t = templateSVM('Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

dosinds = ~strcmp(dosLabels.dosLabels.HLClass, ' r2l');%be careful here. This requires spaces. This may need to be changed later.
dosX = dosFeatures.dosFeatures.SYNCount(dosinds, 4:7);
dosy = dosLabels.dosLabels.HLClass(dosinds);

remove_probes = ~strcmp(u2rLabels.u2rLabels.HLClass, ' probe');
remove_r2l = ~strcmp(u2rLabels.u2rLabels.HLClass, ' r2l');
u2rinds = remove_probes & remove_r2l;

Model = fitcecoc(X,Y,'Learners',t'Classnames',{' R', ' u2r', ' dos'});



%X = meas;
%Y = species;
%rng(1);%random number generator set seed



%ex 2


%t = templateSVM('Standardize',1);
%Mdl = fitcecoc(X,Y,'Learners',t,'ClassNames',{'setosa','versicolor','virginica'});
%CVMdl = crossval(Mdl);

%oosLoss = kfoldLoss(CVMdl)

%label = predict(Mdl, X)

%ex 1


%Mdl = fitcecoc(X,Y);
%Mdl.ClassNames;
%CodingMat = Mdl.CodingMatrix;
%Mdl.BinaryLearners{1}

%isLoss = resubLoss(Mdl)

