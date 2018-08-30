featureWindowPerformance = strings;
featureWindowPerformance(1,1) = 'dos';
featureWindowPerformance(1,2) = 'SYNCount';
featureWindowPerformance(1,3) = 6;

testStruct = struct('CVPacketSize',6, 'b', 6, 'c', 3);

fields = fieldnames(testStruct);
for val = 1:numel(fields)
    disp(testStruct.(fields{val}));
    disp(fields{val});
end