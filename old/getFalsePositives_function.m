function [falsePositivesByLabel] = getFalsePositives_function(correctLabels, predicted);

    %calculate false positive percentages of regular traffic
    falsePositivesByLabel = strings;
    falsePositivesByLabel(1,1) = 'dos';
    falsePositivesByLabel(2,1) = 'u2r';
    falsePositivesByLabel(3,1) = 'r2l';
    falsePositivesByLabel(4,1) = 'probe';
    falsePositivesByLabel(5,1) = 'totalFP';
    falsePositivesByLabel(6,1) = 'totalNumLabels';
    falsePositivesByLabel(:,2) = zeros;

    totalFalsePositiveCount = 0;
    dosFalsePositiveCount = 0;
    u2rFalsePositiveCount = 0;
    r2lFalsePositiveCount = 0;
    probeFalsePositiveCount = 0;
    
    for index = (1:size(correctLabels))
        if strcmp(correctLabels(index), 'R') & ~strcmp(predicted(index),'R')
            if (strcmp(predicted(index),falsePositivesByLabel(1,1)))%incorrectly classified as dos
                dosFalsePositiveCount = dosFalsePositiveCount + 1;

            elseif (strcmp(predicted(index),falsePositivesByLabel(2,1)))%incorrectly classified as u2r
                u2rFalsePositiveCount = u2rFalsePositiveCount + 1;

            elseif (strcmp(predicted(index),falsePositivesByLabel(3,1)))%incorrectly classified as r2l
                r2lFalsePositiveCount = r2lFalsePositiveCount + 1;

            elseif (strcmp(predicted(index),falsePositivesByLabel(4,1)))%incorrectly classified as probe
                probeFalsePositiveCount = probeFalsePositiveCount + 1;
            end
            totalFalsePositiveCount = totalFalsePositiveCount + 1;
        end
    end
    
    falsePositivesByLabel(1,2) = dosFalsePositiveCount;
    falsePositivesByLabel(2,2) = u2rFalsePositiveCount;
    falsePositivesByLabel(3,2) = r2lFalsePositiveCount;
    falsePositivesByLabel(4,2) = probeFalsePositiveCount;
    falsePositivesByLabel(5,2) = totalFalsePositiveCount;
    falsePositivesByLabel(6,2) = size(correctLabels,1);
    

end