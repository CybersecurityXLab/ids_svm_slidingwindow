
%{
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
%}
%vec = {'1.1.1.1','1.1.1.1','1.1.1.1','1.1.1.2','1.1.1.1','1.1.1.1','1.1.1.1','1.1.1.2','190.2.2.1'};

%keys = {'1.1.1.1','1.1.1.2'};
%values = [0,0];
%mapObj = containers.Map(keys, values);
%disp(mapObj('1.1.1.1'));%

%a=unique(vec,'stable')
%b=cellfun(@(x) sum(ismember(vec,x)),a,'un',0)

%disp(regexp('file.c dsg', '\.*((\.c[^a-zA-Z+]|\.c$))|}|{|if(|for(|main('))
disp(regexp('malformed' ,'Malformed', 'match', 'ignorecase'));
disp(strfind("-DATAFTP ",'FTP'))

