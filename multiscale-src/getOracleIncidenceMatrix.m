function [ A ] = getOracleIncidenceMatrix( gtMatFileName, initEdges, initVertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN)
%GETORACLEINCIDENCEMATRIX Get the Incidence matrix by checking edge tags from
%the ground truth.
%   Each edge is mapped to the vertices to that of the ground truth, and the
%   consistency is checked.

% -- Initialize
A = zeros(size(initVertices,2), size(initEdges,2));

% -- check the groundTruth threshold
[ gtThreshold, ~, goodIdx ] =  getGTThresholdLCEdge(gtMatFileName);
[edgeTags] = checkEdgeTags(initVertices, initEdges, gtThreshold, gtMatFileName);

% -- get the edgeWeights
mapDistEdges = zeros(1,size(initEdges,2));
odomEdges = find(edgeTags == 2);
mapDistEdges(odomEdges) = O_EDGE_DIST_MEAN;
goodlcEdges = find(edgeTags == 1);
mapDistEdges(goodlcEdges) = OLC_EDGE_DIST_MEAN;
badlcEdges = find(edgeTags == 0);
mapDistEdges(badlcEdges) = LC_EDGE_DIST_MEAN;

% -- form the incidence MAtrix
for i = 1:size(initEdges,2)
    A(initEdges(i).v1, i) = -mapDistEdges(i);
    A(initEdges(i).v2, i) = mapDistEdges(i);
end

end

