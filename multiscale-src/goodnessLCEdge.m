function [ threshold, badIdx, goodIdx ] =  goodnessLCEdge( file1, const, thrhd)
%COMPAREGOODNESSLCEDGE Compares the vertex positions of the lc edges
%against the odometry edges, and checks if they are really relevant.
%   Each mat file should have the same vertex structure.
%   const: a multipler for the threshold. Higher would lead to lesser
%   results
%   Input: 
%       file1: mat file containing vertices, edges, vCount, eCount
%       const: higher constant, higher threshold
%       thrhd: if maunal threshold required

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

%% find mean distance of odometry step (Edge)
avgODist = 0;

for i = 1:(vCount - 1)
    idx = i;
    v1x = vertices(edges(idx).v1).x;
    v1y = vertices(edges(idx).v1).y;
    v2x = vertices(edges(idx).v2).x;
    v2y = vertices(edges(idx).v2).y;
    dist = sqrt((v1x - v2x)^2 + (v1y - v2y)^2 );
    avgODist = avgODist + dist;
end

avgODist = avgODist / (vCount - 1);

%% threshold lcEdges with const multiplied by avg of odometry distance

if isempty(thrhd)
    threshold = avgODist * const;
else
    threshold = thrhd;
end
finalIdx = find(distlcEdges <= threshold)+(vCount - 1);
goodIdx  = finalIdx;
badIdx   = find(distlcEdges > threshold)+(vCount - 1);
% finalIdx = finalIdx + (vCount -1 );
% fprintf('Good_LC: %d\n',length(finalIdx));
% fprintf('Bad_LC: %d\n',(lcEdges - length(finalIdx)));
end

