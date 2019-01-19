%number of samples of each type
n = 15;

s = RandStream('mlfg6331_64');
y = datasample(s,1:2*n,n,'Replace',false);
%disp(y);

%random number generator, first param seed, second param algo
rng(10,'twister');
X = randn(10,1000);
Y = datasample(s,X,n,2,'Replace',false);
%disp(Y);

%returns a set of positive SVM samples
positive_min = 22;
positive_max = 30;
negative_min = 3;
negative_max = 15;

%positive_samples = disp(randi(20,2,15));
positive_samples_1d = rand(1,2*n)* (positive_max - positive_min) + positive_min;
positive_samples_2d = reshape(positive_samples_1d,[2,n]);
disp(positive_samples_2d);

%negative_samples
negative_samples_1d = rand(1,2*n)*(negative_max - negative_min) + negative_min;
negative_samples_2d = reshape(negative_samples_1d,[2,n]);
disp(negative_samples_2d);

%plot(positive_samples_2d, negative_samples_2d, 'o');

pos_x = positive_samples_2d(1,1:n); disp('x is '); disp(pos_x); disp(' and y is ');
pos_y = positive_samples_2d(2,1:n); disp(pos_y);

neg_x = negative_samples_2d(1,1:n); disp('x is '); disp(neg_x); disp(' and y is ');
neg_y = negative_samples_2d(2,1:n); disp(neg_y);

all_samples_x = horzcat(pos_x,neg_x);
all_samples_y = horzcat(pos_y,neg_y);

disp("all samples x and y: "); disp(all_samples_x);disp(all_samples_y);

packet_string = '13888 → 80 [SYN] Seq=0 Win=512 Len=0 MSS=1460SYNSYN[SYN]';
match_string = '[SYN]';
k = strfind(packet_string,match_string)
disp(k);
%disp(match_string);
%disp(length(strcmp(match_string,regexp(packet_string,match_string,'match'))));%matches the regexp to see if it returns a SYN
%if strcmp(match_string,regexp(packet_string,match_string,'match'))
counter = 0;
if ~isempty(k)
    for idx = 1:size(k)
        counter = counter + 1;
        disp(idx);
    end
    disp('i got here');
end
disp(counter);

%Save to file
save autosampletest_all_samples_x&y.mat all_samples_x all_samples_y
