%one v all. specify an attack to classify as the 'one', and the attack will classify everything else as 'all'

allFeatures = load('.\feature_sets\allFeatures.mat');
allLabels = load('.\feature_sets\allLabels.mat');

attack = 'u2r';
table = allLabels.AllLabels.HLClass();

%table = one_v_all_function(attack, table);
for val = 1:size(table)
    if ~strcmp(table(val),attack)
        table(val) = {'not'};
    end
end