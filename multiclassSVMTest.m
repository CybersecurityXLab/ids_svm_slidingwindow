load fisheriris
allfeaturesfilename = '.\matfiles\allFeatures.mat';
alllabelsfilename = '.\matfiles\allLabels.mat';
dosfeaturesfilename = '.\matfiles\dosFeatures.mat';
doslabelsfilename = '.\matfiles\dosLabels.mat';
u2rfeaturesfilename = '.\matfiles\u2rFeatures.mat';
u2rlabelsfilename = '.\matfiles\u2rLabels.mat';
u2rFeatures = load(u2rfeaturesfilename);
u2rLabels = load(u2rlabelsfilename);
dosFeatures = load(dosfeaturesfilename);
dosLabels = load(doslabelsfilename);
allFeatures = load(allfeaturesfilename);
allLabels = load(alllabelsfilename);

data = load('.\randFeatureWindowCombo');

%Model = load('.\MULTICLASSMODEL');
%Model = load('.\MULTICLASSMODEL3mpi');
%Model = load('.\MULTICLASSMODEL3mpacksizecval');

rng(1);
t = templateSVM('Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

allinds = ~strcmp(allLabels.AllLabels.HLClass, 'asdfasdf');%converts allinds to ones
%allX = allFeatures.AllFeatures.ThirdMomentPacketInterarrival(allinds, 1:7);
%allX = allFeatures.AllFeatures.SYNCount(allinds, 4:7);
%allX = allFeatures.AllFeatures.HTTPorFTPandExeCodeCount(allinds,1:7);
allX = allFeatures.AllFeatures.ThirdMomentPacketSize(allinds,1:7);
ally = allLabels.AllLabels.HLClass(allinds);

Model = fitcecoc(data.data,ally,'Learners',t,'Classnames',{' R', ' u2r', ' dos', ' probe', ' r2l'}, 'CrossVal', 'on');
%Model = fitcecoc(allX,ally,'Learners',t,'Classnames',{' R', ' u2r', ' dos', ' probe', ' r2l'}, 'CrossVal', 'on');

%save the model so that it doesn't have to be rerun every time
save MULTICLASSMODELfeaturecombinertest1.mat Model

predicted = kfoldPredict(Model);%, allX);
%predicted = predict(Model.Model, allX);

%dosinds = ~strcmp(dosLabels.dosLabels.HLClass, ' r2l');%be careful here. This requires spaces. This may need to be changed later.
%dosX = dosFeatures.dosFeatures.SYNCount(dosinds, 4:7);
%dosy = dosLabels.dosLabels.HLClass(dosinds);

%remove_probes = ~strcmp(u2rLabels.u2rLabels.HLClass, ' probe');
%remove_r2l = ~strcmp(u2rLabels.u2rLabels.HLClass, ' r2l');
%u2rinds = remove_probes & remove_r2l;

%Model = fitcecoc(X,Y,'Learners',t,'Classnames',{' R', ' u2r', ' dos'});



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

