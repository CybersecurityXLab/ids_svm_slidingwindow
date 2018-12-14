%convert a given file to csv
allFeatures = load('.\zscore_feature_sets\allFeatures.mat');
allLabels = load('.\zscore_feature_sets\allLabels.mat');


featureVals = [allFeatures.AllFeatures.CVPacketSize allFeatures.AllFeatures.ThirdMomentPacketSize allFeatures.AllFeatures.CVPacketInterarrival allFeatures.AllFeatures.ThirdMomentPacketInterarrival allFeatures.AllFeatures.CorJavaScriptCount allFeatures.AllFeatures.HTTPorFTPandExeCodeCount allFeatures.AllFeatures.HTTPandMalformedCount allFeatures.AllFeatures.FTPandCcodeCount allFeatures.AllFeatures.SYNCount allFeatures.AllFeatures.ECHOCount];
features = ["CVPacketSize" "ThirdMomentPacketSize" "CVPacketInterarrival" "ThirdMomentPacketInterarrival" "CorJavaScriptCount" "HTTPorFTPandExeCodeCount" "HTTPandMalformedCount" "FTPandCcodeCount" "SYNCount" "ECHOCount"];
%B = padarray(i,1,0,'pre');
%B(1,1) = "test";
dlmwrite('featureVals.csv',featureVals);
%dlmwrite('features.csv',features);
