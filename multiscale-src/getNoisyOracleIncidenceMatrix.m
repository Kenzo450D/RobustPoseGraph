function [ A ] = getNoisyOracleIncidenceMatrix( gtMatFileName, initEdges, initVertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN)
%GETORACLEINCIDENCEMATRIX Get the Incidence matrix by checking edge tags from
%the ground truth.
%   Each edge is mapped to the vertices to that of the ground truth, and the
%   consistency is checked.

%% -- Initialize
vCount = size(initVertices,2);
eCount = size(initEdges,2);
A = zeros(vCount, eCount);
NoiseIntensity = 0.2;

%% -- check the groundTruth threshold
[ gtThreshold, ~, goodIdx ] =  getGTThresholdLCEdge(gtMatFileName);
[edgeTags] = checkEdgeTags(initVertices, initEdges, gtThreshold, gtMatFileName);

%% -- get the edgeWeights
mapDistEdges = zeros(1,size(initEdges,2));
% -- odometry edges
odomEdges = find(edgeTags == 2);
mapDistEdges(odomEdges) = O_EDGE_DIST_MEAN;
% -- good loop closure edges
goodlcEdges = find(edgeTags == 1);
noiseGoodLC = randn(size(goodlcEdges));
maxNoise = max(noiseGoodLC);
noiseGoodLC = NoiseIntensity * noiseGoodLC / maxNoise;
mapDistEdges(goodlcEdges) = OLC_EDGE_DIST_MEAN + noiseGoodLC;
% -- bad loop closure edges
badlcEdges = find(edgeTags == 0);
noiseBadLC = randn(size(badlcEdges));
maxNoise = max(noiseBadLC);
noiseBadLC = NoiseIntensity * noiseBadLC/maxNoise;
mapDistEdges(badlcEdges) = LC_EDGE_DIST_MEAN + noiseBadLC;

%% -- form the incidence MAtrix
for i = 1:size(initEdges,2)
    A(initEdges(i).v1, i) = -mapDistEdges(i);
    A(initEdges(i).v2, i) = mapDistEdges(i);
end

end

