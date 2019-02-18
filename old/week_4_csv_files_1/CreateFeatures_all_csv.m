%Same as CreateFeatures_all_csv.m, but saves features scaled using z score so that all
%values have a stdev of one

% Script that finds all csv files in current folder and creates a large
% feature table by appending them all together

%CSVFiles = dir('*.csv');
%CSVFiles = dir(fullfile('C:','Users','User','Downloads', 'Matlab', 'fakedata', '*.csv'));
%CSVFiles = dir(fullfile('C:','Users','User','Documents', 'GitHub', 'ids_svm_slidingwindow', 'fakedata', '*.csv'));
CSVFiles = dir(fullfile('C:','Users','User','Documents', 'GitHub', 'ids_svm_slidingwindow','week_4_csv_files_1', '*.csv'));
%CSVFiles = dir(fullfile('C:','Users','User','Documents', 'GitHub', 'ids_svm_slidingwindow', 'allsplitfiles','*.csv'));%right now this ignores a few files not labeled as csvs
%CSVFiles = dir(fullfile('C:','Users','User','Documents', 'GitHub', 'ids_svm_slidingwindow','inside_5_3_split_3_queso_probe.csv'));

TimeWindows = [1 2 4 8 16 32 60];

% Structure to Store All Features for All Clean Attacks:
AllFeatures = struct;
AllFeatures.NumberOfPackets = [];
AllFeatures.MeanNumberOfPackets = [];
AllFeatures.CVNumberOfPackets = [];
AllFeatures.ThirdMomentNumberOfPackets = [];
AllFeatures.MeanPacketSize = [];
AllFeatures.CVPacketSize = [];
AllFeatures.ThirdMomentPacketSize = [];
AllFeatures.HTTPorFTPandExeCodeCount = [];
AllFeatures.CorJavaScriptCount = [];
AllFeatures.HTTPandMalformedCount = [];
AllFeatures.FTPandCcodeCount = [];
AllFeatures.SYNBoolean = [];
AllFeatures.SYNCount = [];
AllFeatures.ECHOBoolean = [];
AllFeatures.ECHOCount = [];
AllFeatures.UniqProtocols = [];
AllFeatures.UniqSrcIPs = [];
AllFeatures.UniqDestIPs = [];
AllFeatures.URGCount = [];
AllFeatures.DNSCount = [];
AllFeatures.TCPCount = [];
AllFeatures.ARPCount = [];
AllFeatures.ICMPCount = [];
AllFeatures.UDPCount = [];
AllFeatures.FTPCount = [];
AllFeatures.HTTPCount = [];
AllFeatures.RSTCount = [];
AllFeatures.CCodeCount = [];
AllFeatures.EXECodeCount = [];
AllFeatures.TELNETCount = [];
AllFeatures.SSHCount = [];

AllLabels = struct;
AllLabels.HLClass = [];
AllLabels.LLClass = [];

%added initialization to remove any issues with Labels
Labels = struct;
Labels.HLClass = [];
Labels.LLClass = [];

disp("before iteration");
fprintf('the length of the set of CSVFiles is %i\n', length(CSVFiles));
for i = 1:length(CSVFiles)
    disp("iterate through file ");disp(i);disp(CSVFiles(i).name);
    [Features, Labels] = CreateFeatures_function( CSVFiles(i, 1).name, TimeWindows );
    AllLabels.HLClass = [AllLabels.HLClass; Labels.HLClass];
    AllLabels.LLClass = [AllLabels.LLClass; Labels.LLClass];
    AllFeatures.NumberOfPackets = [AllFeatures.NumberOfPackets; Features.NumberOfPackets];
    AllFeatures.MeanNumberOfPackets = [AllFeatures.MeanNumberOfPackets; Features.MeanNumberOfPackets];
    AllFeatures.CVNumberOfPackets = [AllFeatures.CVNumberOfPackets; Features.CVNumberOfPackets];
    AllFeatures.ThirdMomentNumberOfPackets = [AllFeatures.ThirdMomentNumberOfPackets; Features.ThirdMomentNumberOfPackets];
    AllFeatures.MeanPacketSize = [AllFeatures.MeanPacketSize; Features.MeanPacketSize];
    AllFeatures.CVPacketSize = [AllFeatures.CVPacketSize; Features.CVPacketSize];
    AllFeatures.ThirdMomentPacketSize = [AllFeatures.ThirdMomentPacketSize; Features.ThirdMomentPacketSize];
    AllFeatures.HTTPorFTPandExeCodeCount = [AllFeatures.HTTPorFTPandExeCodeCount; Features.HTTPorFTPandExeCodeCount];
    AllFeatures.CorJavaScriptCount = [AllFeatures.CorJavaScriptCount; Features.CorJavaScriptCount];
    AllFeatures.HTTPandMalformedCount = [AllFeatures.HTTPandMalformedCount; Features.HTTPandMalformedCount];
    AllFeatures.FTPandCcodeCount = [AllFeatures.FTPandCcodeCount; Features.FTPandCcodeCount];
    AllFeatures.SYNBoolean = [AllFeatures.SYNBoolean; Features.SYNBoolean];
    AllFeatures.SYNCount = [AllFeatures.SYNCount; Features.SYNCount];
    AllFeatures.ECHOBoolean = [AllFeatures.ECHOBoolean; Features.ECHOBoolean];
    AllFeatures.ECHOCount = [AllFeatures.ECHOCount; Features.ECHOCount];
    AllFeatures.UniqProtocols = [AllFeatures.UniqProtocols; Features.UniqProtocols];
    AllFeatures.UniqSrcIPs = [AllFeatures.UniqSrcIPs; Features.UniqSrcIPs];
    AllFeatures.UniqDestIPs = [AllFeatures.UniqDestIPs; Features.UniqDestIPs];
    AllFeatures.URGCount = [AllFeatures.URGCount; Features.URGCount];
    AllFeatures.DNSCount = [AllFeatures.DNSCount; Features.DNSCount];
    AllFeatures.TCPCount = [AllFeatures.TCPCount; Features.TCPCount];
    AllFeatures.ARPCount = [AllFeatures.ARPCount; Features.ARPCount];
    AllFeatures.ICMPCount = [AllFeatures.ICMPCount; Features.ICMPCount];
    AllFeatures.UDPCount = [AllFeatures.UDPCount; Features.UDPCount];
    AllFeatures.FTPCount = [AllFeatures.FTPCount; Features.FTPCount];
    AllFeatures.HTTPCount = [AllFeatures.HTTPCount; Features.HTTPCount];
    AllFeatures.RSTCount = [AllFeatures.RSTCount; Features.RSTCount];
    AllFeatures.CCodeCount = [AllFeatures.CCodeCount; Features.CCodeCount];
    AllFeatures.EXECodeCount = [AllFeatures.EXECodeCount; Features.EXECodeCount];
    AllFeatures.TELNETCount = [AllFeatures.TELNETCount; Features.TELNETCount];
    AllFeatures.SSHCount = [AllFeatures.SSHCount; Features.SSHCount];
    
end


% Save output:
save ..\week_4_features_1\AllFeatures.mat AllFeatures
save ..\week_4_features_1\AllLabels.mat AllLabels


fprintf('the length of the set of CSVFiles is %i\n', length(CSVFiles));
