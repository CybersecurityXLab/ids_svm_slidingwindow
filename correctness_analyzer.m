allfeaturesfilename = '.\matfiles\allFeatures.mat';
alllabelsfilename = '.\matfiles\allLabels.mat';
allFeatures = load(allfeaturesfilename);
allLabels = load(alllabelsfilename);

arrayLenMat = size(allLabels.AllLabels.HLClass());
arrayLen = arrayLenMat(1);

indexedListOfAttacks = strings;%create an empty matrix of 2 string columns

test = allLabels.AllLabels.HLClass(63);

counter = 1;%counter to keep track of current index for new data structure

%creates a data structure that has the attack type in the first column and
%its index in the second. This is for comparison to predicted values.
for val = 1:size(allLabels.AllLabels.HLClass())
    if ~strcmp(allLabels.AllLabels.HLClass(val),' R')
        indexedListOfAttacks(counter,1) = allLabels.AllLabels.HLClass(val);
        indexedListOfAttacks(counter,2) = val;
        counter = counter + 1;
    end
end

attackList = strings;
counter = 1;
durationCounter = 1;%Counts the duration in seconds of the attack
%creates a data structure to show the index ranges of duration for each
%type. This will be how percentages will be calculated. Second col shows
%the duration of the attack. Third col shows whether one of the individual
%seconds was correctly classified. Fourth column will show number of
%correct classifications. Fifth column will show percentage of correct
%classification (col 4 / col 2);
for val = 1:size(indexedListOfAttacks)-1 
    if ~((str2double(indexedListOfAttacks(val+1,2)) - str2double(indexedListOfAttacks(val,2)) == 1))%the cells are not contiguous, therefore are a different attack
        durationCounter = 1;
        attackList(counter,1) = indexedListOfAttacks(val,1);
        counter = counter + 1;
    else
        durationCounter = durationCounter + 1;
    end
    attackList(counter,2) = durationCounter;
end

%the next three lines simply append the last attack to the list, since
%the previous loop cannot
arrayLenMat = size(indexedListOfAttacks);
arrayLen = arrayLenMat(1);
attackList(counter,1) = indexedListOfAttacks(arrayLen,1);
