%singlewindowfeaturecombiner_function
function data = singlewindowfeaturecombiner_function();

    allfeaturesfilename = '.\matfiles\allFeatures.mat';
    alllabelsfilename = '.\matfiles\allLabels.mat';


    allFeatures = load(allfeaturesfilename);
    allLabels = load(alllabelsfilename);

    allinds = ~strcmp(allLabels.AllLabels.HLClass, 'asdfasdf');%converts from cell so that it can be used. String value is just one that will not appear in the file

    numWindows = 7;
    numFeatures = 10;

    CVPSFeature = allFeatures.AllFeatures.CVPacketSize(allinds, 1:numWindows);
    TMPSFeature = allFeatures.AllFeatures.ThirdMomentPacketSize(allinds, 1:numWindows);
    CVPIFeature =allFeatures.AllFeatures.ThirdMomentPacketInterarrival(allinds, 1:numWindows);
    TMPIFeature = allFeatures.AllFeatures.ThirdMomentPacketInterarrival(allinds, 1:numWindows);
    CorJSFeature = allFeatures.AllFeatures.CorJavaScriptCount(allinds, 1:numWindows);
    ExeFeature = allFeatures.AllFeatures.HTTPorFTPandExeCodeCount(allinds, 1:numWindows);
    HTTPMalformedFeature = allFeatures.AllFeatures.HTTPandMalformedCount(allinds, 1:numWindows);
    FTPandCFeature = allFeatures.AllFeatures.FTPandCcodeCount(allinds, 1:numWindows);
    SynFeature = allFeatures.AllFeatures.SYNCount(allinds, 1:numWindows);
    ECHOFeature = allFeatures.AllFeatures.ECHOCount(allinds, 1:numWindows);

    combinedFeatures = [CVPSFeature,TMPSFeature,CVPIFeature,TMPIFeature,CorJSFeature,ExeFeature,HTTPMalformedFeature,FTPandCFeature,SynFeature,ECHOFeature];
    [row,col] = size(combinedFeatures);

    data = [];%reinitialize this to empty so the variable is cleared in a previously used workspace

    currentWindow = 0;%window to be returned
    currentCol = 1;%window to be returned

    for val = 1:numWindows
        currentWindow = currentWindow + randi(numWindows);
        fprintf('%i ', currentWindow);
        data(:,currentCol) = combinedFeatures(:,currentWindow);
        currentWindow = val * 7;%sets the index to the 0th position of the new time window feature set
        currentCol = currentCol + 1;
    end
end