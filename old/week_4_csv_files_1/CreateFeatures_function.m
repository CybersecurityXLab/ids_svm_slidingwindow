function [Features, Labels] = CreateFeatures_function( filename, TimeWindows );

TimeWindows = [1 2 4 8 16 32 60];
%% Initialize variables.
for m = 1:50
    fprintf("\nNEW RUN.......... on %s",filename);
end

delimiter = ',';
startRow = 1;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%q%q%q%q%q%q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
  raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
  for col=1:length(dataArray)-1
      raw(1:length(dataArray{col}),col) = dataArray{col};
  end
  numericData = NaN(size(dataArray{1},1),size(dataArray,2)); 


% Convert the contents of columns with dates to MATLAB datetimes using date
% format string.
try
    dates{4} = datetime(dataArray{4}, 'Format', 'HH:mm:ss.SS', 'InputFormat', 'HH:mm:ss.SS');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{4} = cellfun(@(x) x(2:end-1), dataArray{4}, 'UniformOutput', false);
        dates{4} = datetime(dataArray{4}, 'Format', 'HH:mm:ss.SS', 'InputFormat', 'HH:mm:ss.SS');
    catch
        dates{4} = repmat(datetime([NaN NaN NaN]), size(dataArray{4}));
    end
end

anyBlankDates = cellfun(@isempty, dataArray{4});
anyInvalidDates = isnan(dates{4}.Hour) - anyBlankDates;
dates = dates(:,4);
% 
%  %% Split data into numeric and cell columns.
%  % rawNumericColumns = raw(:, 8);
rawCellColumns = raw(:, [1,2,5,6,7,9]);
%  
%  
%% Replace non-numeric cells with NaN
% R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
% rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

% Create output variable
X = table;
X.LLClass = rawCellColumns(:, 1);
%these all have a space for the first char. remove with line below
X.HLClass = strip(rawCellColumns(:, 2), ' ');
X.Time = dates{:, 1};
X_Time_old = X.Time;
X.Source = rawCellColumns(:, 3);
X.Destination = rawCellColumns(:, 4);
X.Protocol = rawCellColumns(:, 5);
X.Length = cellfun(@str2num,dataArray{1, 8});
X.Info = rawCellColumns(:, 6);

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers inval

%% Define additional packet-level features which will be used to compute features for various time windows
X.Time = 3600*hour(X.Time)+60*minute(X.Time)+second(X.Time); % Convert datetime format to time in seconds (only use for csv files!)

%% Packet Interarrival
%X.PacketInterarrival = [0; diff(X.Time)]; % Time since previous packet; for first packet make this zero since there is no prior packet

% Create a new time column that is always increasing by adding 3,600 when
% the hour changes
% Note: negative(1:8) is required to include 8 different hours that may be
% included in one file
for i=1:8
    negative(i) = 0;
end
j = 1;
for i = 1:(length(X.Time) - 1)
    if(X.Time(i+1) - X.Time(i) < 0)
        negative(j) = i;
        j = j + 1;
    end
end
for j=1:8
    if negative(j) > 0
        for i = negative(j):length(X.Time)
            X.Time(i) = X.Time(i) + j*3600;
        end
    end
end

% Find indices which partition the data into one second intervals
edges = X.Time(1):1:X.Time(length(X.Time));
edges(length(edges)) = X.Time(length(X.Time)); %Round last entry up to include all times
SecondIndex = discretize(X.Time, edges);

% moved NumberOfSeconds for files that change the hour and we add 3,600 it
% needs to be calculated here
NumberOfSeconds = floor(X.Time(length(X.Time))-X.Time(1));
%% Compress Data into Second-level summary data (the summary data will be used to compute features over different time windows)
% Note: each row represents one second

XCompress = table;
XCompress.NumberOfPackets = zeros(NumberOfSeconds,1);
XCompress.NumberOfPacketsSquared = zeros(NumberOfSeconds,1);
XCompress.NumberOfPacketsCubed = zeros(NumberOfSeconds,1);
XCompress.PacketSizeSum = zeros(NumberOfSeconds,1);
XCompress.PacketSizeSumSquares = zeros(NumberOfSeconds,1);
XCompress.PacketSizeSumCubes = zeros(NumberOfSeconds,1);
XCompress.HLClass = cell(NumberOfSeconds,1);
XCompress.LLClass = cell(NumberOfSeconds,1);
XCompress.CorJavaScriptCount = zeros(NumberOfSeconds,1);
XCompress.HTTPandMalformedCount = zeros(NumberOfSeconds,1);
XCompress.HTTPorFTPandExeCodeCount = zeros(NumberOfSeconds,1);
XCompress.FTPandCcodeCount = zeros(NumberOfSeconds,1);
XCompress.SYNBoolean = zeros(NumberOfSeconds,1);
XCompress.SYNCount = zeros(NumberOfSeconds,1);
XCompress.ECHOBoolean = zeros(NumberOfSeconds,1);
XCompress.ECHOCount = zeros(NumberOfSeconds,1);
XCompress.RSTCount = zeros(NumberOfSeconds,1);
XCompress.URGCount = zeros(NumberOfSeconds,1);
XCompress.TCPCount = zeros(NumberOfSeconds,1);
XCompress.DNSCount = zeros(NumberOfSeconds,1);
XCompress.ARPCount = zeros(NumberOfSeconds,1);
XCompress.ICMPCount = zeros(NumberOfSeconds,1);
XCompress.UDPCount = zeros(NumberOfSeconds,1);
XCompress.FTPCount = zeros(NumberOfSeconds,1);
XCompress.HTTPCount = zeros(NumberOfSeconds,1);
XCompress.TELNETCount = zeros(NumberOfSeconds,1);
XCompress.SSHCount = zeros(NumberOfSeconds,1);
XCompress.CCodeCount = zeros(NumberOfSeconds,1);
XCompress.EXECodeCount = zeros(NumberOfSeconds,1);
XCompress.UniqSrcIPs = zeros(NumberOfSeconds,length(TimeWindows));
XCompress.UniqDestIPs = zeros(NumberOfSeconds,length(TimeWindows));
XCompress.UniqProtocols = zeros(NumberOfSeconds,length(TimeWindows));

%counters below for verification of correctness of expected and actual flag counts
http_malformed_packet_counter = 0;
ftp_dotc_counter = 0;
httpftp_dotexe_counter = 0;
syn_flag_counter = 0;
echo_flag_counter = 0;
source_ip_counter = 0;
dest_ip_counter = 0;
rst_flag_counter = 0;
urg_counter = 0;
tcp_counter = 0;
dns_counter = 0;
arp_counter = 0;
icmp_counter = 0;
udp_counter = 0;
ftp_counter = 0;
http_counter = 0;
c_code_counter = 0;
EXE_code_counter = 0;
telnet_counter = 0;
ssh_counter = 0;


for i=1:NumberOfSeconds
    index = find(SecondIndex==i);%finds all elements in nonzero second tables
    
    % Record the High level class
    % Note: if there are no packets in the interval, the label is taken
    % from the previous interval
    if length(index) == 0
        XCompress.HLClass(i) = XCompress.HLClass(i-1);
        XCompress.LLClass(i) = XCompress.LLClass(i-1);
    else
        possible_labelsHL = unique(X.HLClass(index));
        possible_labelsLL = unique(X.LLClass(index));
        if length(possible_labelsHL) == 1
           XCompress.HLClass(i) = possible_labelsHL;
           XCompress.LLClass(i) = possible_labelsLL;
        else
            n = zeros(length(possible_labelsHL), 1);
            for j = 1:length(possible_labelsHL)
              n(j) = length(find(strcmp(possible_labelsHL{j}, X.HLClass(index))));
            end
            [~, itemp] = max(n);
            XCompress.HLClass(i)=possible_labelsHL(itemp);
            XCompress.LLClass(i)=possible_labelsLL(itemp);
        end
    end

    XCompress.NumberOfPackets(i) = length(index);
    XCompress.NumberOfPacketsSquared(i) = length(index).^2;
    XCompress.NumberOfPacketsCubed(i) = length(index).^3;
    
    % Packet Size Info (for CV and third moment of packet size)
    
    XCompress.PacketSizeSum(i) = sum(X.Length(index));
    XCompress.PacketSizeSumSquares(i) = sum(X.Length(index).^2);
    XCompress.PacketSizeSumCubes(i) = sum(X.Length(index).^3);
    
    % Record C or Javascript Boolean
    if length(index)>0
        expr_C = '\.*((\.c[^a-zA-Z+]|\.c$))|}|{|if(|for(|main(';%if .c with whitespace immediately after or other attributes. Ignores .c in cases like .com
        expr_Javascript = 'attr|index|all|id|value|className|document|getElement*';
        code_flag_count = 0;
        for j=index(1):index(length(index));
            [startStr1] = regexp(X.Info(j), expr_C);
            [startStr2] = regexp(X.Info(j), expr_Javascript);
            if(length(startStr1{1,1}) > 0 || length(startStr2{1,1}) > 0)
                code_flag_count = code_flag_count+1;
            end
        end
        XCompress.CorJavaScriptCount(i) = code_flag_count;
    end
    
    % Record HTTP and Malformed Boolean
    %returns the number of Malformed HTTP packets per second
    if length(index)>0
        http_malformed_packet_counter = 0;
        
        %malformed_string_indeces = strfind(X.Info(index),'Malformed');
       malformed_string_indeces = regexp(X.Info(index),'Malformed', 'match', 'ignorecase');%returns index of syn string if relevant
       http_protocol = regexp(X.Protocol(index),'HTTP', 'match', 'ignorecase');
       for n = 1:length(malformed_string_indeces)
           
           if ~isempty(malformed_string_indeces{n})%if it is empty, strfind found no match, and thus returned no index
               if ~isempty(http_protocol{n})%if it is empty, the protocol was not http
                   
                   http_malformed_packet_counter = http_malformed_packet_counter + 1;
                   
               end
           end
       end
       XCompress.HTTPandMalformedCount(i) = http_malformed_packet_counter;
    end
    
    %Record *.exe in payload and HTTP or FTP in protocol boolean
    if length(index)>0
       dotexe_regex = '\.*((\.exe[^a-zA-Z+]|\.exe$))';%finds .exe strings with 0 or more characters after, and ignores english letters after .c
       dotexe_string_indeces = regexp(X.Info(index),dotexe_regex, 'match');
       httpftp_protocol = regexp(X.Protocol(index),'HTTP|FTP', 'match', 'ignorecase');
       
       for n = 1:length(dotexe_string_indeces)
           if ~isempty(dotexe_string_indeces{n})%if it is empty, regexp found no match, and thus returned no index
               if ~isempty(httpftp_protocol{n})
                   
                   httpftp_dotexe_counter = httpftp_dotexe_counter + 1;%global counter, count all
                   
                   XCompress.HTTPorFTPandExeCodeCount(i) = XCompress.HTTPorFTPandExeCodeCount(i) + 1;%count only current second
               end
           end
       end
       
    end
    
    % Record FTP in protocol and "*.c" in content flag boolean
    if length(index)>0
        
       dotc_regex = '\.*((\.c[^a-zA-Z+]|\.c$))|}|{|if(|for(|main(';%if .c with whitespace immediately after or other attributes. Ignores .c in cases like .com
       dotc_string_indeces = regexp(X.Info(index),dotc_regex, 'match');
       ftp_protocol = regexp(X.Protocol(index),'FTP', 'match', 'ignorecase');
      
       
       for n = 1:length(dotc_string_indeces)
           
           if ~isempty(dotc_string_indeces{n})%if it is empty, regexp found no match, and thus returned no index
               if ~isempty(ftp_protocol{n})
                   ftp_dotc_counter = ftp_dotc_counter + 1;%global counter
                   
                   %records ftp and .c counts per second
                   XCompress.FTPandCcodeCount(i) = XCompress.FTPandCcodeCount(i) + 1;
               end
           end
       end
    end
    
    % Record SYN flag boolean and count
    if length(index)>0
   % if index>0
       syn_string = '[SYN]';
       
       syn_string_indeces = strfind(X.Info(index),syn_string);%returns index of syn string if relevant
       syn_protocol = strfind(X.Protocol(index),'TCP');%returns value if it is a TCP protocol
       
       for n = 1:length(syn_string_indeces)
           if ~isempty(syn_string_indeces{n})%if it is empty, strfind found no match, and thus returned no index
               if ~isempty(syn_protocol{n})%if this is empty, it is not TCP protocol
                   syn_flag_counter = syn_flag_counter + 1;
                   XCompress.SYNCount(i) = XCompress.SYNCount(i) + 1;%counter for current sec
                   
                   XCompress.SYNBoolean(i) = 1;%set to one because a single occurence flags the entire second as a positive
               end
           end
       end
    end
    
    %Record ECHO boolean
    if length(index) > 0
       echo_string = 'Echo';
       
       echo_string_indeces = strfind(X.Info(index),echo_string);%returns the indeces of the matching string if relevant
       echo_string_protocol = strfind(X.Protocol(index),'ICMP');%Determines if the echo type is ICMP
       
       for n = 1:length(echo_string_indeces)
           if ~isempty(echo_string_indeces{n})%if it is empty, strfind found no match, and thus returned no index
               if ~isempty(echo_string_protocol{n})%only counts if it is an icmp type
                   echo_flag_counter = echo_flag_counter + 1;
                   XCompress.ECHOCount(i) = XCompress.ECHOCount(i) + 1; %count for current second
                   XCompress.ECHOBoolean(i) = 1;%set to one because a single occurence flags the entire second as a positive
               end
           end
       end
    end
    
     % Record RST flag count
    if length(index)>0
   % if index>0
       rst_string = '[RST]';
       
       rst_string_indeces = strfind(X.Info(index),rst_string);%returns index of syn string if relevant
       rst_protocol = strfind(X.Protocol(index),'TCP');%returns value if it is a TCP protocol
       
       for n = 1:length(rst_string_indeces)
           if ~isempty(rst_string_indeces{n})%if it is empty, strfind found no match, and thus returned no index
               if ~isempty(rst_protocol{n})%if this is empty, it is not TCP protocol
                   rst_flag_counter = rst_flag_counter + 1;
                   XCompress.RSTCount(i) = XCompress.RSTCount(i) + 1;%counter for current sec
                   
               end
           end
       end
    end
    
     % Record URG flag count
    if length(index)>0
   % if index>0
       urg_string = '[URG|URG]';
       
       urg_string_indeces = strfind(X.Info(index),urg_string);%returns index of syn string if relevant
       urg_protocol = strfind(X.Protocol(index),'TCP');%returns value if it is a TCP protocol
       
       for n = 1:length(urg_string_indeces)
           if ~isempty(urg_string_indeces{n})%if it is empty, strfind found no match, and thus returned no index
               if ~isempty(urg_protocol{n})%if this is empty, it is not TCP protocol
                   urg_counter = urg_counter + 1;%global count
                   XCompress.URGCount(i) = XCompress.URGCount(i) + 1;%counter for current sec
                   
               end
           end
       end
    end
    
     % Record TCP protocol count
    if length(index)>0
       tcp_protocol = strfind(X.Protocol(index),'TCP');%returns value if it is a TCP protocol
       for n = 1:length(tcp_protocol)
           if ~isempty(tcp_protocol{n})%if this is empty, it is not TCP protocol
                 tcp_counter = tcp_counter + 1;%global count
                 XCompress.TCPCount(i) = XCompress.TCPCount(i) + 1;%counter for current sec  
           end
       end
    end
    
    % Record DNS protocol count
    if length(index)>0
       dns_protocol = strfind(X.Protocol(index),'DNS');%returns value if it is a dns protocol
       for n = 1:length(dns_protocol)
           if ~isempty(dns_protocol{n})%if this is empty, it is not dns protocol
                 dns_counter = dns_counter + 1;%global count
                 XCompress.DNSCount(i) = XCompress.DNSCount(i) + 1;%counter for current sec  
           end
       end
    end
    
    % Record ARP protocol count
    if length(index)>0
       arp_protocol = strfind(X.Protocol(index),'ARP');%returns value if it is a arp protocol
       for n = 1:length(arp_protocol)
           if ~isempty(arp_protocol{n})%if this is empty, it is not arp protocol
                 arp_counter = arp_counter + 1;%global count
                 XCompress.ARPCount(i) = XCompress.ARPCount(i) + 1;%counter for current sec  
           end
       end
    end
    
        % Record ICMP protocol count
    if length(index)>0
       icmp_protocol = strfind(X.Protocol(index),'ICMP');%returns value if it is a ICMP protocol
       for n = 1:length(icmp_protocol)
           if ~isempty(icmp_protocol{n})%if this is empty, it is not icmp protocol
                 icmp_counter = icmp_counter + 1;%global count
                 XCompress.ICMPCount(i) = XCompress.ICMPCount(i) + 1;%counter for current sec  
           end
       end
    end
    
            % Record UDP protocol count
    if length(index)>0
       udp_protocol = strfind(X.Protocol(index),'UDP');%returns value if it is a udp protocol
       for n = 1:length(udp_protocol)
           if ~isempty(udp_protocol{n})%if this is empty, it is not udp protocol
                 udp_counter = udp_counter + 1;%global count
                 XCompress.UDPCount(i) = XCompress.UDPCount(i) + 1;%counter for current sec  
           end
       end
    end
    
                % Record ftp protocol count
    if length(index)>0
       ftp_protocol = strfind(X.Protocol(index),'FTP');%returns value if it is a udp protocol
       for n = 1:length(ftp_protocol)
           if ~isempty(ftp_protocol{n})%if this is empty, it is not TCP protocol
                 ftp_counter = ftp_counter + 1;%global count
                 XCompress.FTPCount(i) = XCompress.FTPCount(i) + 1;%counter for current sec  
           end
       end
    end
    
                    % Record http protocol count
    if length(index)>0
       http_protocol = strfind(X.Protocol(index),'HTTP');%returns value if it is a udp protocol
       for n = 1:length(http_protocol)
           if ~isempty(http_protocol{n})%if this is empty, it is not TCP protocol
                 http_counter = http_counter + 1;%global count
                 XCompress.HTTPCount(i) = XCompress.HTTPCount(i) + 1;%counter for current sec  
           end
       end
    end
    
        % Record C count
    if length(index)>0
        expr_C = '\.*((\.c[^a-zA-Z+]|\.c$))';%if .c with whitespace immediately after or other attributes. Ignores .c in cases like .com
        for j=index(1):index(length(index));
            [startStr1] = regexp(X.Info(j), expr_C);
            if(length(startStr1{1,1}) > 0 )
                c_code_counter = c_code_counter+1;%global counter
                %disp('here')
                XCompress.CCodeCount(i) = XCompress.CCodeCount(i) + 1;%counter for current sec
            end
        end
    end
    
      % Record EXE count
    if length(index)>0
        expr_EXE = '\.*((\.exe[^a-zA-Z+]|\.exe$))';%if exe with whitespace immediately after or other attributes. Ignores .c in cases like .com
        for j=index(1):index(length(index));
            [startStr1] = regexp(X.Info(j), expr_EXE);
            if(length(startStr1{1,1}) > 0 )
                EXE_code_counter = EXE_code_counter+1;%global counter
                %disp('here')
                XCompress.EXECodeCount(i) = XCompress.EXECodeCount(i) + 1;%counter for current sec
            end
        end
    end
    
    
             % Record telnet protocol count
    if length(index)>0
       telnet_protocol = strfind(X.Protocol(index),'TELNET');%returns value if it is a udp protocol
       for n = 1:length(telnet_protocol)
           if ~isempty(telnet_protocol{n})%if this is empty, it is not Telnet protocol
                 telnet_counter = telnet_counter + 1;%global count
                 XCompress.TELNETCount(i) = XCompress.TELNETCount(i) + 1;%counter for current sec  
           end
       end
    end
    
    
    % Record ssh protocol count
    if length(index)>0
       ssh_protocol = strfind(X.Protocol(index),'SSH');%returns value if it is a udp protocol
       for n = 1:length(ssh_protocol)
           if ~isempty(ssh_protocol{n})%if this is empty, it is not SSH protocol
                 ssh_counter = ssh_counter + 1;%global count
                 XCompress.SSHCount(i) = XCompress.SSHCount(i) + 1;%counter for current sec  
           end
       end
    end
    
end

fprintf('\n\nthe number of HTTP Malformed packets is %i', http_malformed_packet_counter);
fprintf('\nthe number of HTTP or FTP .exe packets is %i', httpftp_dotexe_counter);
fprintf('\nthe number of FTP .c packets is %i', ftp_dotc_counter);
fprintf('\nthe number of syn flags is %i', syn_flag_counter);
fprintf('\nthe number of echo flags is %i', echo_flag_counter);
fprintf('\nthe number of RST flags is %i', rst_flag_counter);
fprintf('\nthe number of URG flags is %i', urg_counter);
fprintf('\nthe number of TCP protocols is %i', tcp_counter);
fprintf('\nthe number of DNS protocols is %i', dns_counter);
fprintf('\nthe number of ARP protocols is %i', arp_counter);
fprintf('\nthe number of ICMP protocols is %i', icmp_counter);
fprintf('\nthe number of UDP protocols is %i', udp_counter);
fprintf('\nthe number of FTP protocols is %i', ftp_counter);
fprintf('\nthe number of HTTP protocols is %i', ftp_counter);
fprintf('\nthe number of c code packets is is %i', c_code_counter);
fprintf('\nthe number of EXE code packets is is %i', EXE_code_counter);
fprintf('\nthe number of Telnet protocols is is %i', telnet_counter);
fprintf('\nthe number of SSH protocols is is %i', ssh_counter);

%% Define Features In Various Time Windows

num_of_time_windows = length(TimeWindows);

start_time = 1;
end_time = length(XCompress.NumberOfPackets);
total_time = end_time - start_time;

Features = struct;
Labels = struct;

Features.NumberOfPackets = zeros(total_time,num_of_time_windows);%%
Features.MeanNumberOfPackets = zeros(total_time,num_of_time_windows);%%
Features.CVNumberOfPackets = zeros(total_time,num_of_time_windows);%%
Features.ThirdMomentNumberOfPackets = zeros(total_time,num_of_time_windows);%%
Features.MeanPacketSize = zeros(total_time,num_of_time_windows);%%
Features.CVPacketSize = zeros(total_time,num_of_time_windows);%%
Features.ThirdMomentPacketSize = zeros(total_time,num_of_time_windows);%%
Features.HTTPorFTPandExeCodeCount = zeros(total_time,num_of_time_windows);%right now this is a boolean count need a per sec count
Features.CorJavaScriptCount = zeros(total_time,num_of_time_windows);%
Features.HTTPandMalformedCount = zeros(total_time,num_of_time_windows);%
Features.FTPandCcodeCount = zeros(total_time,num_of_time_windows);%
Features.SYNBoolean = zeros(end_time,num_of_time_windows);%
Features.SYNCount = zeros(end_time,num_of_time_windows);%
Features.ECHOBoolean = zeros(total_time,num_of_time_windows);%
Features.ECHOCount = zeros(total_time,num_of_time_windows);%
Features.UniqProtocols = zeros(total_time,num_of_time_windows);%
Features.UniqSrcIPs = zeros(total_time,num_of_time_windows);%
Features.UniqDestIPs = zeros(total_time,num_of_time_windows);%
Features.URGCount = zeros(total_time,num_of_time_windows);%
%mean
%cv
%tm
Features.DNSCount = zeros(total_time,num_of_time_windows);%
Features.TCPCount = zeros(total_time,num_of_time_windows);%
Features.ARPCount = zeros(total_time,num_of_time_windows);%
Features.ICMPCount = zeros(total_time,num_of_time_windows);%
Features.UDPCount = zeros(total_time,num_of_time_windows);%
Features.FTPCount = zeros(total_time,num_of_time_windows);%
Features.HTTPCount = zeros(total_time,num_of_time_windows);
Features.RSTCount = zeros(total_time,num_of_time_windows);%"[RST] count https://stackoverflow.com/questions/15182106/what-is-the-reason-and-how-to-avoid-the-fin-ack-rst-and-rst-ack
Features.CCodeCount = zeros(total_time,num_of_time_windows);
Features.EXECodeCount = zeros(total_time,num_of_time_windows);
Features.TELNETCount = zeros(total_time,num_of_time_windows);
Features.SSHCount = zeros(total_time,num_of_time_windows);%ssh for ssh processtable dos

%% create occurence count over time windows features
%x = 1:num_of_time_windows;
%y = TimeWindows(x);
%i = 1:NumberOfSeconds;
%index = zeros(length(SecondIndex),1);
%for i=1:NumberOfSeconds
%    if ~isempty(index)
%       telnet_protocol = strfind(X.Protocol(index),'.');%returns value if it is a udp protocol
%       for n = 1:length(telnet_protocol)
%           if ~isempty(telnet_protocol{n})%if this is empty, it is not Telnet protocol
%                 telnet_counter = telnet_counter + 1;%global count
%                 XCompress.UniqProtocols(i) = XCompress.UniqProtocols(i) + 1;%counter for current sec  
%           end
%       end
%    end
%end
%index = find(SecondIndex==i);
%SecondIndex(i);

%syn_protocol = strfind(X.Protocol(index),'RIP');%returns value if it is a TCP protocol
%indx = find(SecondIndex==i);
%index = zeros(NumberOfSeconds,1);
%disp(x);
%disp(y);
%index = unique(SecondIndex);
%disp(index);
%srcIP = X.Source(index);
%index = find(SecondIndex(i)==(y));
%disp(index);
%for i = 1:NumberOfSeconds


%    index = find(SecondIndex==(i - y + 1));
%    disp(index);
%end

for i=1:NumberOfSeconds
    
    %count uniq src ips
    for x = 1:num_of_time_windows %Loop over windows
        ipList = {};
        for y = 1:TimeWindows(x)%length of current time window
            index = find(SecondIndex==(i - y + 1));%finds index where the value i matches a given second (i.e. there are packets in all listed seconds)
           % disp(index);
            srcIP = X.Source(index);
           % disp(srcIP);
            

            if ~isempty(index)
                
                for n = 1:length(srcIP)
                    if ~strcmp(srcIP, '"')
                        ipList{end+1}=srcIP{n};%get a list of all ips in current second
                        ipList = unique(ipList);%make list only unique ips
                     %   disp(srcIP{n});
                    end
                   % disp(ipList);
                   % disp(length(ipList));
                    XCompress.UniqSrcIPs(i,x) = length(ipList);%count each individual column. 
                end
            end
        end
    end
    
    %count uniq dest ips
    for x = 1:num_of_time_windows %Loop over windows
        ipList = {};
        for y = 1:TimeWindows(x)%length of current time window
            index = find(SecondIndex==(i - y + 1));%finds index where the value i matches a given second (i.e. there are packets in all listed seconds)
            destIP = X.Destination(index);
            

            if ~isempty(index)
                
                for n = 1:length(destIP)
                    if ~strcmp(destIP, '"')
                        ipList{end+1}=destIP{n};%get a list of all ips in current second
                        ipList = unique(ipList);%make list only unique ips
                    end
                    XCompress.UniqDestIPs(i,x) = length(ipList);%count each individual column. 
                end
            end
        end
    end
    
        %count uniq protocols
    for x = 1:num_of_time_windows %Loop over windows
        protoList = {};
        for y = 1:TimeWindows(x)%length of current time window
            index = find(SecondIndex==(i - y + 1));%finds index where the value i matches a given second (i.e. there are packets in all listed seconds)
            proto = X.Protocol(index);
            

            if ~isempty(index)
                
                for n = 1:length(proto)
                    if ~strcmp(proto, '"')
                        protoList{end+1}=proto{n};%get a list of all protocols in current second
                        protoList = unique(protoList);%make list only unique protocols
                    end
                    XCompress.UniqProtocols(i,x) = length(protoList);%count each individual column. 
                end
            end
        end
    end
    
        
 %   for x = 1:num_of_time_windows %Loop over windows
  %      disp("here");
   %     disp(x);
    %    protoList = {};
     %   idx = 1:num_of_time_windows;
        %index = zeros(NumberOfSeconds,1);
        %size(index(idx))
      %  index = find(SecondIndex==(i - TimeWindows(idx) + 1));
       % disp(index);
        %proto = X.Protocol(index);
        %for y = 1:TimeWindows(x)%length of current time window
            %index = find(SecondIndex==(i - y + 1));%finds index where the value i matches a given second (i.e. there are packets in all listed seconds)
           % proto = X.Protocol(index);
            

    %        if ~isempty(index)
   %             
  %              for n = 1:length(proto)
 %                   if ~strcmp(proto, '"')
 %                       protoList{end+1}=proto{n};%get a list of all ips in current second
 %                       protoList = unique(protoList);%make list only unique ips
 %                   end
 %                   XCompress.UniqProtocols(i,x) = length(protoList);%count each individual column. 
 %              end
 %           end
 %       %end
 %   end
    
 
end

Labels.HLClass = cell(end_time,1);
Labels.LLClass = cell(total_time,1);

for sec=start_time:end_time %Loop over times
    for i = 1:num_of_time_windows %Loop over windows
        
        Labels.HLClass(sec-start_time+1) = XCompress.HLClass(sec);
        Labels.LLClass(sec-start_time+1) = XCompress.LLClass(sec);
        
        %time window is too large to hold first i seconds
        %set all irrelevant sliding windows to -1
        if(TimeWindows(i) > sec)
            Features.SYNBoolean(sec-start_time+1, i) = -1;
            Features.SYNCount(sec-start_time+1,i) = -1;
            Features.HTTPorFTPandExeCodeCount(sec-start_time+1,i) = -1;
            Features.CorJavaScriptCount(sec-start_time+1, i) = -1;
            Features.HTTPandMalformedCount(sec-start_time+1, i) = -1;
            Features.FTPandCcodeCount(sec-start_time+1, i) = -1;
            Features.ECHOBoolean(sec-start_time+1, i) = -1;
            Features.ECHOCount(sec-start_time+1, i) = -1;
            Features.MeanPacketSize(sec-start_time+1, i) = -1;
            Features.CVPacketSize(sec-start_time+1, i) = -1;
            Features.ThirdMomentPacketSize(sec-start_time+1, i) = -1;
            Features.NumberOfPackets(sec-start_time+1, i) = -1;
            Features.MeanNumberOfPackets(sec-start_time+1, i) = -1;
            Features.CVNumberOfPackets(sec-start_time+1, i) = -1;
            Features.ThirdMomentNumberOfPackets(sec-start_time+1, i) = -1;
            Features.RSTCount(sec-start_time+1,i) = -1;
            Features.URGCount(sec-start_time+1,i) = -1;
            Features.TCPCount(sec-start_time+1,i) = -1;
            Features.DNSCount(sec-start_time+1,i) = -1;
            Features.ARPCount(sec-start_time+1,i) = -1;
            Features.ICMPCount(sec-start_time+1,i) = -1;
            Features.UDPCount(sec-start_time+1,i) = -1;
            Features.FTPCount(sec-start_time+1,i) = -1;
            Features.HTTPCount(sec-start_time+1,i) = -1;
            Features.CCodeCount(sec-start_time+1,i) = -1;
            Features.EXECodeCount(sec-start_time+1,i) = -1;
            Features.TELNETCount(sec-start_time+1,i) = -1;
            Features.SSHCount(sec-start_time+1,i) = -1;
            Features.UniqSrcIPs(sec-start_time+1,i) = -1;
            Features.UniqDestIPs(sec-start_time+1,i) = -1;
            Features.UniqProtocols(sec-start_time+1,i) = -1;
            
        %current time window is >= the current seconds passed
        else

            Features.SYNBoolean(sec-start_time+1, i) = sum(XCompress.SYNBoolean(sec-TimeWindows(i)+1 : sec));
            Features.SYNCount(sec-start_time+1, i) = sum(XCompress.SYNCount(sec-TimeWindows(i)+1 : sec));
            Features.HTTPorFTPandExeCodeCount(sec-start_time+1,i) = sum(XCompress.HTTPorFTPandExeCodeCount(sec-TimeWindows(i)+1 : sec));
            Features.CorJavaScriptCount(sec-start_time+1, i) = sum(XCompress.CorJavaScriptCount(sec-TimeWindows(i)+1 : sec));
            Features.HTTPandMalformedCount(sec-start_time+1, i) = sum(XCompress.HTTPandMalformedCount(sec-TimeWindows(i)+1 : sec));
            Features.FTPandCcodeCount(sec-start_time+1, i) = sum(XCompress.FTPandCcodeCount(sec-TimeWindows(i)+1 : sec));
            Features.ECHOBoolean(sec-start_time+1, i) = sum(XCompress.ECHOBoolean(sec-TimeWindows(i)+1 : sec));
            Features.ECHOCount(sec-start_time+1, i) = sum(XCompress.ECHOCount(sec-TimeWindows(i)+1 : sec));
            Features.NumberOfPackets(sec-start_time+1, i) = sum(XCompress.NumberOfPackets(sec-TimeWindows(i)+1 : sec));
            Features.RSTCount(sec-start_time+1, i) = sum(XCompress.RSTCount(sec-TimeWindows(i)+1 : sec));
            Features.URGCount(sec-start_time+1, i) = sum(XCompress.URGCount(sec-TimeWindows(i)+1 : sec));
            Features.TCPCount(sec-start_time+1, i) = sum(XCompress.TCPCount(sec-TimeWindows(i)+1 : sec));
            Features.DNSCount(sec-start_time+1, i) = sum(XCompress.DNSCount(sec-TimeWindows(i)+1 : sec));
            Features.ARPCount(sec-start_time+1, i) = sum(XCompress.ARPCount(sec-TimeWindows(i)+1 : sec));
            Features.ICMPCount(sec-start_time+1, i) = sum(XCompress.ICMPCount(sec-TimeWindows(i)+1 : sec));
            Features.UDPCount(sec-start_time+1, i) = sum(XCompress.UDPCount(sec-TimeWindows(i)+1 : sec));
            Features.FTPCount(sec-start_time+1, i) = sum(XCompress.FTPCount(sec-TimeWindows(i)+1 : sec));
            Features.HTTPCount(sec-start_time+1, i) = sum(XCompress.HTTPCount(sec-TimeWindows(i)+1 : sec));
            Features.CCodeCount(sec-start_time+1, i) = sum(XCompress.CCodeCount(sec-TimeWindows(i)+1 : sec));
            Features.EXECodeCount(sec-start_time+1, i) = sum(XCompress.EXECodeCount(sec-TimeWindows(i)+1 : sec));
            Features.TELNETCount(sec-start_time+1, i) = sum(XCompress.TELNETCount(sec-TimeWindows(i)+1 : sec));
            Features.SSHCount(sec-start_time+1, i) = sum(XCompress.SSHCount(sec-TimeWindows(i)+1 : sec));
            Features.UniqSrcIPs(sec-start_time+1, i) = XCompress.UniqSrcIPs(sec,i);
            Features.UniqDestIPs(sec-start_time+1, i) = XCompress.UniqDestIPs(sec,i);
            Features.UniqProtocols(sec-start_time+1, i) = XCompress.UniqProtocols(sec,i);
            
            % Construct continuous features from stored information: 
            sum_number_packets = sum(XCompress.NumberOfPackets(sec-TimeWindows(i)+1 : sec));
            sumsquares_number_packets = sum(XCompress.NumberOfPacketsSquared(sec-TimeWindows(i)+1 : sec));
            sumcubes_number_packets = sum(XCompress.NumberOfPacketsCubed(sec-TimeWindows(i)+1 : sec));
            mean_number_packets = sum_number_packets / TimeWindows(i);
            var_number_packets = (sumsquares_number_packets / TimeWindows(i)) - mean_number_packets^2;
            
            Features.MeanNumberOfPackets(sec-start_time+1, i) = mean_number_packets;
            Features.CVNumberOfPackets(sec-start_time+1, i) = sqrt(var_number_packets)/mean_number_packets;
            Features.ThirdMomentNumberOfPackets(sec-start_time+1, i) = (sumcubes_number_packets/TimeWindows(i)) - 3*mean_number_packets*(sumsquares_number_packets/TimeWindows(i)) + 2*mean_number_packets^3;
            
            if sum_number_packets > 0
                % Packet Size
                sum_packetsize = sum(XCompress.PacketSizeSum(sec-TimeWindows(i)+1 : sec));
                sumsquares_packetsize = sum(XCompress.PacketSizeSumSquares(sec-TimeWindows(i)+1 : sec));
                sumscubes_packetsize = sum(XCompress.PacketSizeSumCubes(sec-TimeWindows(i)+1 : sec));
                mean_packetsize = sum_packetsize / sum_number_packets;
                var_packetsize = (sumsquares_packetsize / sum_number_packets) - mean_packetsize^2;
                
                Features.MeanPacketSize(sec-start_time+1, i) = mean_packetsize;
                Features.CVPacketSize(sec-start_time+1, i) = sqrt(var_packetsize)/mean_packetsize;
                Features.ThirdMomentPacketSize(sec-start_time+1, i) = (sumscubes_packetsize/sum_number_packets) - 3*mean_packetsize*(sumsquares_packetsize/sum_number_packets) + 2*mean_packetsize^3;
                

            end
        end
    end
end



% Re-shaping because Matlab automatically transposed very short label cell arrays from 2
% by 1 to 1 by 2
Labels.HLClass = reshape(Labels.HLClass, [ max(size(Labels.HLClass)), 1]);
Labels.LLClass = reshape(Labels.LLClass, [ max(size(Labels.LLClass)), 1]);
