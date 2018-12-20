

timeDay = 86400%seconds in a day

scores = zeros(21*8,3);

incCount = 1;

for purchaseVar = 1:21%num potential purchases per day 0-20
    for maxOn = 1:8
        for numPurchases = 21 - purchaseVar:21%calculate current number of purchases
            disp((maxOn/(timeDay- (maxOn*numPurchases))));
            
           % incCount = incCount + 1;
        end
        scores(21*(purchaseVar-1)+incCount, 1) = purchaseVar;
        incCount = incCount + 1;
        
    end
    incCount = 1;
end