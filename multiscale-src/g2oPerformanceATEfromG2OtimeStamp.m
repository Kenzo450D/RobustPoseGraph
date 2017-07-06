function [ate] = g2oPerformanceATEfromG2OtimeStamp(AUTFileName, GTFileName, gtMapAutPose)
%CALCULATEG2OATE This script is to take two files and find the ATE difference.
% Input:
%   AUTFileName: .g2o filename for AUT
%   GTFileName: .g2o filename for GT
%   freqDiff: Difference in frequency of AUT and GT poses


%% Initialize

% -- Generate Output FileNames
[pathstr1, name1, ext1] = fileparts(AUTFileName);
[pathstr2, name2, ext2] = fileparts(GTFileName);
if (isempty(pathstr1))
    AUTMatFileName = [name1,'.mat'];
else
    AUTMatFileName = [pathstr1,'/', name1,'.mat'];
end
if (isempty(pathstr2))
    GTMatFileName = [name2,'.mat'];
else
    GTMatFileName = [pathstr2,'/', name2,'.mat'];
end

% -- Generate Mat files
filesCreated = 'filesCreated.txt';
readg2oFile(AUTFileName, filesCreated, 1);
if exist(GTMatFileName, 'file') ~= 2
    readg2oFile(GTFileName, filesCreated, 1);
end

%% Calculate ATE error
[ate] = g2oPerformanceATEfromMATtimeStamp(GTMatFileName, AUTMatFileName, gtMapAutPose);

end

