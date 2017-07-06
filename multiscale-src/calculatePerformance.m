function [precisionAllLC, recallAllLC, precisionOrgLC, recallOrgLC, precisionSynLC, ...
    recallSynLC] = calculatePerformance(file, gt, bad_LC_idx, const)
% CALCULATEPERFORMANCE calculates the performance of the algorithm
%   Input:
%       file     : g2o file with pruned edges and optimised by g2o
%       gt       : initial g2o optimised by g2o
%       const    : constant for threshold, higher the more threshold
%                  (usually 2)
%   Output:
%       None, printed output

%% Load Files

% -- load ground Truth
load(gt);
initEdges = edges;
initVertices = vertices;
initvCount = vCount;
initeCount = eCount;

% -- load file
load(file); %eCount, vCount, edges and vertices

% -- output info
% fprintf('FileVertices : %d\n',vCount);
% fprintf('FileEdges    : %d\n',eCount);
% fprintf('GroundtruthVertices : %d\n',initvCount);
% fprintf('GroundtruthEdges    : %d\n',initeCount);

% -- get badEdges
badEdges = edges(bad_LC_idx);

%% find bad edges among ground truth
% threshold - threshold to calculate whether bad edges or not
% badinit   - indexes of incorrect loop closures in ground truth
% [threshold, badInit, goodInit] = goodnessLCEdge(gt, const,[]);
[threshold, badInit, goodInit] = getInitThresholdLCEdge(gt);

% % we ignore this step, stating that all loop closures in the file is good.
% % initializing goodInit as all of them
% goodInit = (vCount-1):eCount;
% badInit = [];

%  -- DEBUG : Print
% fprintf('File: groundTruth :: %s\n',gt);
% fprintf('Calculated threshold: %d\n',threshold);


%% find good & bad edges among the file

% -- Calculate badLC edges based on threshold
% Using previously acquired threshold
[precisionAllLC, recallAllLC, precisionOrgLC, recallOrgLC, precisionSynLC, ...
    recallSynLC] = goodnessLCEdgetoGt(file, threshold, initvCount, ...
    initVertices, initeCount, initEdges, badInit, goodInit, bad_LC_idx);

end