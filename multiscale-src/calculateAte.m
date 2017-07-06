function calculateAte(inputFilesCreated, inputDir, groundTruth)
%CALCULATEATE Calculates Absolute Translation Error for a given dataset of files
%-------------------------------------------------------------------------------
% Input:
%   inputFilesCreated: filename for the .g2o files
%   inputDir         : directory for input of the .g2o files
%   groundTruth      : filename for ground truth (.mat file)/(.g2o file)
% ------------------------------------------------------------------------------
% Output:
%   File1: a filescreated file
%   File2: file with performance RPE and ATE for each graph
% ------------------------------------------------------------------------------
% Author: 
%   Sayantan Datta < sayantan dot datta at research dot iiit dot ac dot in>
%   Robotics Research Center
%   International Institute of Information Technology, Hyderabad
% ------------------------------------------------------------------------------



% clear all; close all; clc;
% inputFilesCreated='intelDCSDataset/intelDCSFilesCreated.txt';
% groundTruth='intelDCS.mat';


%% Initialization

% -- Check if file exists
if (exist(inputFilesCreated,'file') ~= 2)
    fprintf('ERROR: %s does not exist!\n', inputFilesCreated);
    return;
end


% -- Read input Directory
pathdiridx      = find(inputFilesCreated == '/');
if ( ~ isempty(pathdiridx) )
    pathdiridx     = pathdiridx(end);
    inputFileBasis = inputFilesCreated(pathdiridx+1:end);
else
    inputFileBasis = inputFilesCreated;
end
fprintf('Input Directory: %s\n',inputDir);


% -- Create out file name

outputFilesCreated = ['ATE_filesCreated-',inputFileBasis];
outputPerfFile     = ['ATE_perf-',inputFileBasis];

% -- load ground truth for calculating tScale
[pathstr,name,ext] = fileparts(groundTruth);
if (strcmp(ext,'.mat'))
    load(groundTruth);
elseif (strcmp(ext,'.g2o'))
    readg2oFile(groundTruth, outputFilesCreated, 1);
    groundTruth = [pathstr,name,'.mat'];
    load(groundTruth);
end
% -- Open output performance file
fperf = fopen(outputPerfFile,'w');
% -- Read the inputFilesCreated file
inFile   = fopen(inputFilesCreated,'r');
tline    = fgetl(inFile);
count    = 1;
while ischar(tline)
    t = cputime;
    % -- convert .g2o file to .mat file
    [pathstr,name,ext] = fileparts(tline);
    inputMatFileName = strcat(inputDir,name,'.mat');
    if (exist(inputMatFileName,'file') ~= 2)
        fprintf('.mat file: %s does not exist!\n', inputMatFileName);
        inputG2oFileName = strcat(inputDir,tline);
        readg2oFile(inputG2oFileName, outputFilesCreated, 1);
    end
    % -- check if directory path is in inputMatFileName
%     if ( ~isempty(pathdiridx))
%         diridx = find(tline == '/');
%         if ( isempty(diridx))
%             tline = [inputDir,tline];
%             inputMatFileName = [inputDir, inputMatFileName];
%         end
%     end
    [ate] = g2oPerformanceATE(groundTruth,inputMatFileName);
    outFileName = tline;
    fprintf(fperf,'%s\nATE: %f\n',outFileName,ate);
    % -- next step of loop
    tline = fgetl(inFile);
    e = cputime - t;
    fprintf(1,'Time for loop: %f\n',e);
end
fclose(inFile);
fclose(fperf);
end
