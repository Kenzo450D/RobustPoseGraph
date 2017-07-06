function [ A ] = getChi2IncidenceMatrix(initEdges, initVertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN)
%GETORACLEINCIDENCEMATRIX Get the Incidence matrix by checking edge tags from
%the ground truth.
%   Each edge is mapped to the vertices to that of the ground truth, and the
%   consistency is checked.

%% -- Initialize
vCount = size(initVertices,2);
eCount = size(initEdges,2);
A = zeros(vCount, eCount);

%% Edge chi2 errors from cpp code
cppCode = 'getChi2Error.o';
tmpG2oFileName = 'tmpG2oFile-forCalculatingChi2Weights.g2o';
export2DTNFileG2o(initVertices, initEdges, tmpG2oFileName, [], []);
tmpChi2FileName = 'tmpChi2File-forCalculatingChi2Weights.txt';
command = ['./',cppCode, ' ',tmpG2oFileName,' ',tmpChi2FileName];
% -- Debug Print
fprintf(1,'command to get loop closure Edge Weights:%s\n ',command);

% -- Make system call
system(command);

% -- load the chi2error file.
lcChi2EdgeWeights = load(tmpChi2FileName);

%% form the edge Weights for incidence matrix

% -- Initialize
mapDistEdges = zeros(1,size(initEdges,2));

% -- Odometry edges
odomEdges = 1:(vCount - 1);
mapDistEdges(odomEdges) = O_EDGE_DIST_MEAN;

% -- Loop closure Edges
lcEdges = (vCount:eCount);
% ---- map the weights from chi2 error
low = min(lcChi2EdgeWeights);
low = low(1);
high = max(lcChi2EdgeWeights);
high = high(1);
lcMap = ((lcChi2EdgeWeights - low)/(high-low))*(OLC_EDGE_DIST_MEAN - LC_EDGE_DIST_MEAN);
lcMap = OLC_EDGE_DIST_MEAN - lcMap;
mapDistEdges(lcEdges) = lcMap;

%% -- form the incidence MAtrix
for i = 1:size(initEdges,2)
    A(initEdges(i).v1, i) = -mapDistEdges(i);
    A(initEdges(i).v2, i) = mapDistEdges(i);
end

end

