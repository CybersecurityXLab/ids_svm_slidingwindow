%one v all. specify an attack to classify as the 'one', and the attack will classify everything else as 'all'
function table = one_v_all_function(attack, table);


for val = 1:size(table)
    if ~strcmp(table(val),attack)
        table(val) = {'not'};
    end
end