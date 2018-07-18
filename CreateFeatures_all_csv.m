% Script that finds all csv files in current folder and creates a large
% feature table by appending them all together

%CSVFiles = dir('*.csv');
%CSVFiles = dir(fullfile('C:','Users','User','Downloads', 'Matlab', 'fakedata', '*.csv'));
%CSVFiles = dir(fullfile('C:','Users','User','Documents', 'GitHub', 'ids_svm_slidingwindow', 'fakedata', '*.csv'));
CSVFiles = dir(fullfile('C:','Users','User','Documents', 'GitHub', 'ids_svm_slidingwindow', '*.csv'));%right now this ignores a few files not labeled as csvs
TimeWindows = [1 2 4 8 16 32 60];

% Structure to Store All Features for All Clean Attacks:
AllFeatures = struct;
AllFeatures.CVPacketSize = [];
AllFeatures.ThirdMomentPacketSize = [];
AllFeatures.CVPacketInterarrival = [];
AllFeatures.ThirdMomentPacketInterarrival = [];
AllFeatures.CorJavaScriptCount = [];
AllFeatures.HTTPorFTPandExeCodeCount = [];
AllFeatures.HTTPandMalformedCount = [];
AllFeatures.FTPandCcodeCount = [];
AllFeatures.SYNCount = [];
AllFeatures.ECHOCount = [];

AllLabels = struct;
AllLabels.HLClass = [];
AllLabels.LLClass = [];

%added initialization to remove any issues with Labels
Labels = struct;
Labels.HLClass = [];
Labels.LLClass = [];

% Structure for DoS Attacks:

dosFeatures = struct;
dosFeatures.CVPacketSize = [];
dosFeatures.ThirdMomentPacketSize = [];
dosFeatures.CVPacketInterarrival = [];
dosFeatures.ThirdMomentPacketInterarrival = [];
dosFeatures.CorJavaScriptCount = [];
dosFeatures.HTTPorFTPandExeCodeCount = [];
dosFeatures.HTTPandMalformedCount = [];
dosFeatures.FTPandCcodeCount = [];
dosFeatures.SYNCount = [];
dosFeatures.ECHOCount = [];

dosLabels = struct;
dosLabels.HLClass = [];
dosLabels.LLClass = [];

% Structure for Probe Attacks:

probeFeatures = struct;
probeFeatures.CVPacketSize = [];
probeFeatures.ThirdMomentPacketSize = [];
probeFeatures.CVPacketInterarrival = [];
probeFeatures.ThirdMomentPacketInterarrival = [];
probeFeatures.CorJavaScriptCount = [];
probeFeatures.HTTPorFTPandExeCodeCount = [];
probeFeatures.HTTPandMalformedCount = [];
probeFeatures.FTPandCcodeCount = [];
probeFeatures.SYNCount = [];
probeFeatures.ECHOCount = [];

probeLabels = struct;
probeLabels.HLClass = [];
probeLabels.LLClass = [];

% Structure for User to Root Attacks:

u2rFeatures = struct;
u2rFeatures.CVPacketSize = [];
u2rFeatures.ThirdMomentPacketSize = [];
u2rFeatures.CVPacketInterarrival = [];
u2rFeatures.ThirdMomentPacketInterarrival = [];
u2rFeatures.CorJavaScriptCount = [];
u2rFeatures.HTTPorFTPandExeCodeCount = [];
u2rFeatures.HTTPandMalformedCount = [];
u2rFeatures.FTPandCcodeCount = [];
u2rFeatures.SYNCount = [];
u2rFeatures.ECHOCount = [];

u2rLabels = struct;
u2rLabels.HLClass = [];
u2rLabels.LLClass = [];

disp("before iteration");

for i = 1:length(CSVFiles) - 50
    disp("iterate through file ");disp(i);disp(CSVFiles(i).name);
    [Features, Labels] = CreateFeatures_function( CSVFiles(i, 1).name, TimeWindows );
    AllLabels.HLClass = [AllLabels.HLClass; Labels.HLClass];
    AllLabels.LLClass = [AllLabels.LLClass; Labels.LLClass];
    AllFeatures.CVPacketSize = [AllFeatures.CVPacketSize; Features.CVPacketSize];
    AllFeatures.ThirdMomentPacketSize = [AllFeatures.ThirdMomentPacketSize; Features.ThirdMomentPacketSize];
    AllFeatures.CVPacketInterarrival = [AllFeatures.CVPacketInterarrival; Features.CVPacketInterarrival];
    AllFeatures.ThirdMomentPacketInterarrival = [AllFeatures.ThirdMomentPacketInterarrival; Features.ThirdMomentPacketInterarrival];
    AllFeatures.CorJavaScriptCount = [AllFeatures.CorJavaScriptCount; Features.CorJavaScriptCount];
    AllFeatures.HTTPorFTPandExeCodeCount = [AllFeatures.HTTPorFTPandExeCodeCount; Features.HTTPorFTPandExeCodeCount];
    AllFeatures.HTTPandMalformedCount = [AllFeatures.HTTPandMalformedCount; Features.HTTPandMalformedCount];
    AllFeatures.FTPandCcodeCount = [AllFeatures.FTPandCcodeCount; Features.FTPandCcodeCount];
    AllFeatures.SYNCount = [AllFeatures.SYNCount; Features.SYNCount];
    AllFeatures.ECHOCount = [AllFeatures.ECHOCount; Features.ECHOCount];
    
    %disp(Labels.HLClass);
    if any(strcmp(Labels.HLClass,' probe'))==1
        disp("I am at HLClass probe");
        probeLabels.HLClass = [probeLabels.HLClass; Labels.HLClass];
        probeLabels.LLClass = [probeLabels.LLClass; Labels.LLClass];
        probeFeatures.CVPacketSize = [probeFeatures.CVPacketSize; Features.CVPacketSize];
        probeFeatures.ThirdMomentPacketSize = [probeFeatures.ThirdMomentPacketSize; Features.ThirdMomentPacketSize];
        probeFeatures.CVPacketInterarrival = [probeFeatures.CVPacketInterarrival; Features.CVPacketInterarrival];
        probeFeatures.ThirdMomentPacketInterarrival = [probeFeatures.ThirdMomentPacketInterarrival; Features.ThirdMomentPacketInterarrival];
        probeFeatures.CorJavaScriptCount = [probeFeatures.CorJavaScriptCount; Features.CorJavaScriptCount];
        probeFeatures.HTTPorFTPandExeCodeCount = [probeFeatures.HTTPorFTPandExeCodeCount; Features.HTTPorFTPandExeCodeCount];
        probeFeatures.HTTPandMalformedCount = [probeFeatures.HTTPandMalformedCount; Features.HTTPandMalformedCount];
        probeFeatures.FTPandCcodeCount = [probeFeatures.FTPandCcodeCount; Features.FTPandCcodeCount];
        probeFeatures.SYNCount = [probeFeatures.SYNCount; Features.SYNCount];
        probeFeatures.ECHOCount = [probeFeatures.ECHOCount; Features.ECHOCount];
    end
    
    if any(strcmp(Labels.HLClass,' dos'))==1
        disp("I am at the HLCLass dos");
        dosLabels.HLClass = [dosLabels.HLClass; Labels.HLClass];
        dosLabels.LLClass = [dosLabels.LLClass; Labels.LLClass];
        dosFeatures.CVPacketSize = [dosFeatures.CVPacketSize; Features.CVPacketSize];
        dosFeatures.ThirdMomentPacketSize = [dosFeatures.ThirdMomentPacketSize; Features.ThirdMomentPacketSize];
        dosFeatures.CVPacketInterarrival = [dosFeatures.CVPacketInterarrival; Features.CVPacketInterarrival];
        dosFeatures.ThirdMomentPacketInterarrival = [dosFeatures.ThirdMomentPacketInterarrival; Features.ThirdMomentPacketInterarrival];
        dosFeatures.CorJavaScriptCount = [dosFeatures.CorJavaScriptCount; Features.CorJavaScriptCount];
        dosFeatures.HTTPorFTPandExeCodeCount = [dosFeatures.HTTPorFTPandExeCodeCount; Features.HTTPorFTPandExeCodeCount];
        dosFeatures.HTTPandMalformedCount = [dosFeatures.HTTPandMalformedCount; Features.HTTPandMalformedCount];
        dosFeatures.FTPandCcodeCount = [dosFeatures.FTPandCcodeCount; Features.FTPandCcodeCount];
        dosFeatures.SYNCount = [dosFeatures.SYNCount; Features.SYNCount];
        dosFeatures.ECHOCount = [dosFeatures.ECHOCount; Features.ECHOCount];
    end
    
    if any(strcmp(Labels.HLClass,' u2r'))==1
        disp("u2r");
        u2rLabels.HLClass = [u2rLabels.HLClass; Labels.HLClass];
        u2rLabels.LLClass = [u2rLabels.LLClass; Labels.LLClass];
        u2rFeatures.CVPacketSize = [u2rFeatures.CVPacketSize; Features.CVPacketSize];
        u2rFeatures.ThirdMomentPacketSize = [u2rFeatures.ThirdMomentPacketSize; Features.ThirdMomentPacketSize];
        u2rFeatures.CVPacketInterarrival = [u2rFeatures.CVPacketInterarrival; Features.CVPacketInterarrival];
        u2rFeatures.ThirdMomentPacketInterarrival = [u2rFeatures.ThirdMomentPacketInterarrival; Features.ThirdMomentPacketInterarrival];
        u2rFeatures.CorJavaScriptCount = [u2rFeatures.CorJavaScriptCount; Features.CorJavaScriptCount];
        u2rFeatures.HTTPorFTPandExeCodeCount = [u2rFeatures.HTTPorFTPandExeCodeCount; Features.HTTPorFTPandExeCodeCount];
        u2rFeatures.HTTPandMalformedCount = [u2rFeatures.HTTPandMalformedCount; Features.HTTPandMalformedCount];
        u2rFeatures.FTPandCcodeCount = [u2rFeatures.FTPandCcodeCount; Features.FTPandCcodeCount];
        u2rFeatures.SYNCount = [u2rFeatures.SYNCount; Features.SYNCount];
        u2rFeatures.ECHOCount = [u2rFeatures.ECHOCount; Features.ECHOCount];
    end
        
end

% Save output:
save .\baz\AllFeatures.mat AllFeatures
save .\baz\AllLabels.mat AllLabels
save .\baz\dosFeatures.mat dosFeatures
save .\baz\dosLabels.mat dosLabels
save .\baz\probeFeatures.mat probeFeatures
save .\baz\probeLabels.mat probeLabels
save .\baz\u2rFeatures.mat u2rFeatures
save .\baz\u2rLabels.mat u2rLabels

fprintf('the length of the set of CSVFiles is %i\n', length(CSVFiles));
