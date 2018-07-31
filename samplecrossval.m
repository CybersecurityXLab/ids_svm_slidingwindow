load fisheriris

t = templateSVM('Standardize',1,'KernelFunction','gaussian','KernelScale','auto');

X = meas;
Y = species;

Mdl = fitcecoc(X,Y,'Learners',t,'ClassNames',{'setosa','versicolor','virginica'});
CVMdl = crossval(Mdl);

predicted = kfoldPredict(CVMdl);

cperf = classperf(Y, predicted);