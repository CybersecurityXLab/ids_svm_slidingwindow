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
currentCol = 1;%says what column to work on on the temporary data table created
for i = 1:numFeatures
    tempTimeWindowList = getRandTimeWindows(numWindows,numFeatures);
    disp(tempTimeWindowList);
    [tempRowNum, tempColNum] = size(tempTimeWindowList);
    disp(tempColNum);
    for j = 1:tempColNum
        data(:,currentCol) = combinedFeatures(:,((i*7)-7)+tempTimeWindowList(j));%gets the particular time window from current feature
        currentCol = currentCol + 1;
    end
end

%save randFeatureWindowcombo.mat data

function returnList = getRandTimeWindows(numWindows,numFeatures)
    %randStart = randi(numWindows);%random number of features to start with for gradient descent
    randWindowCountNum = randi(numWindows);%decides the total number of random time windows per feature
    randWindowIndex = randi(numWindows);%decides the actual specific time numbers to use. If randWindowNumb is 7, this variable is irrelevant.

    %list to show whether or not the randWindowNum has already been used
    indecesUsedList = false(7,1);
    if randWindowCountNum == 7
        indecesUsedList = true(7,1);
    else
        for i = 1:randWindowCountNum
            indecesUsedList(randWindowIndex) = true;

            %logic to check if the newly generated random number index for the time windows has already been used
            breakLoop = false;
            while(~breakLoop)
                randWindowIndex = randi(numWindows);
                if(indecesUsedList(randWindowIndex) == false)
                    breakLoop = true;
                end

            end
        end
    end
    %return a list of only the indeces with a value of true
    returnList = [];
    for i = 1:7
        if(indecesUsedList(i) == true)
            returnList(end+1)=i;
        end
    end
end
