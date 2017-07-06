function calculateAte(fileName, groundTruth)
%CALCULATEATE Calculates Absolute Translation Error for a given dataset of files
%-------------------------------------------------------------------------------
% Input:
%   inputFilesCreated: filename for the input .g2o file
%   groundTruth      : filename for ground truth (.mat file)/(.g2o file)
% ------------------------------------------------------------------------------
% Output:
%   File1: file with performance RPE and ATE for graph
% ------------------------------------------------------------------------------
% Author: 
%   Sayantan Datta < sayantan dot datta at research dot iiit dot ac dot in>
%   Robotics Research Center
%   International Institute of Information Technology, Hyderabad
% ------------------------------------------------------------------------------


%% Initialization

% -- Check if file exists
if (exist(fileName,'file') ~= 2)
    fprintf('ERROR: %s does not exist!\n', fileName);
    return;
end

% -- get filename Basis
idx = find(fileName == '.');
idx = idx(end);
idx = idx - 1;
fileNameBasis = fileName(1:idx);

outputPerfFile     = ['ATE_perf-',fileNameBasis,'.txt'];

% -- load ground truth for calculating tScale
[pathstr,name,ext] = fileparts(groundTruth);
if (strcmp(ext,'.mat'))
    load(groundTruth);
elseif (strcmp(ext,'.g2o'))
    readg2oFile(groundTruth, 'filesCreated.txt', 1);
    groundTruth = [pathstr,name,'.mat'];
end

% -- load fileName for calculating tScale
[pathstr,name,ext] = fileparts(fileName);
if (strcmp(ext,'.mat'))
    load(groundTruth);
elseif (strcmp(ext,'.g2o'))
    readg2oFile(fileName, 'filesCreated.txt', 1);
    fileName = [pathstr,name,'.mat'];
end

% -- Open output performance file
fperf = fopen(outputPerfFile,'w');

% -- Read the inputFilesCreated file
inFile = fopen(inputFilesCreated,'r');
[ate]  = g2oPerformanceATE(groundTruth,inputMatFileName);
fprintf(fperf,'%s\nATE: %f\n',fileName,ate);

% -- close file descriptors
fclose(inFile);
fclose(fperf);
end
