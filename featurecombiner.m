allfeaturesfilename = '.\matfiles\allFeatures.mat';
alllabelsfilename = '.\matfiles\allLabels.mat';
allFeatures = load(allfeaturesfilename);
allLabels = load(alllabelsfilename);

allinds = ~strcmp(allLabels.AllLabels.HLClass, 'asdfasdf');%converts from cell so that it can be used. String value is just one that will not appear in the file

completeSynFeature = allFeatures.AllFeatures.SYNCount(allinds, 1:7);
completeTMPIFeature = allFeatures.AllFeatures.ThirdMomentPacketInterarrival(allinds, 1:7);
completeTMPSFeature = allFeatures.AllFeatures.ThirdMomentPacketSize(allinds, 1:7);

combinedFeatures = [completeSynFeature, completeTMPIFeature,completeTMPSFeature];

[row,col] = size(combinedFeatures);

for i = 1:col
    data = combinedFeatures(1:col,i{1});%[0:i];
end

