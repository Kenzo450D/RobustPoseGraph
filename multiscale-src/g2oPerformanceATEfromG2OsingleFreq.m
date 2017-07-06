function [ate] = g2oPerformanceATEfromG2OsingleFreq(AUTFileName, GTFileName)
%CALCULATEG2OATE This script is to take two files and find the ATE difference.
% Input:
%   AUTFileName: .g2o filename for AUT
%   GTFileName: .g2o filename for GT or .mat file


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

% -- check if the vCount is the same
load(AUTMatFileName);
vCount1 = vCount;
load(GTMatFileName);
if (vCount1 ~= vCount)
    ate = NaN;
    return;
end


%% Calculate ATE error
[ate] = g2oPerformanceATEfromMATsingleFreq(GTMatFileName, AUTMatFileName);

end

