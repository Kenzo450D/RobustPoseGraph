function [ threshold, badIdx, goodIdx ] =  getInitThresholdLCEdge(file1)
%GETINITTHRESHOLDLCEDGE Checks all the loop closures in the ground truth
%file, which has all the correct loop closure edges. (We consider all loop
%closure edges to be correct, and set our threshold in that order)
%   Input: 
%       file1: mat file containing vertices, edges, vCount, eCount

% file1 = 'veinput_MITb_g2o-lc200-optm.mat';

%% read files
load(file1);

%% extract loop closure edges
lcEdges = eCount - (vCount - 1);

%% record the distance between the two vertices in the loop closure edges
distlcEdges = zeros(lcEdges, 1);

% ---- populate the vector
for i = 1:lcEdges
    idx = i + (vCount - 1);
%     disp(edges(idx));
%     fprintf('idx = %d\n',idx);
%     pause(0.05);
    v1x = vertices(edges(idx).v1).x;
    v1y = vertices(edges(idx).v1).y;
    v2x = vertices(edges(idx).v2).x;
    v2y = vertices(edges(idx).v2).y;
    dist = sqrt((v1x - v2x)^2 + (v1y - v2y)^2 );
    distlcEdges(i,:) = dist;
end


%% threshold lcEdges with const multiplied by avg of odometry distance

threshold = max(distlcEdges);
threshold = threshold * 2;
finalIdx = find(distlcEdges <= threshold)+(vCount - 1);
goodIdx  = finalIdx;
badIdx   = [];
% finalIdx = finalIdx + (vCount -1 );
% fprintf('Good_LC: %d\n',length(finalIdx));
% fprintf('Bad_LC: %d\n',(lcEdges - length(finalIdx)));
end

