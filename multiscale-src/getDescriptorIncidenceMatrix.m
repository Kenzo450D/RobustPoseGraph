function [ A ] = getDescriptorIncidenceMatrix( edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, initECount, edgeWeightMap)
%GETDESCRIPTORINCIDENCEMATRIX Returns the incidence matrix of a semi weighted graph
%   Make sure the sorting is done properly as done in "readFile.m"
%   Input:
%       edges: struct(v1,v2,dx,d,dth,covMatrix)
%       vertices: struct(id, x, y, o)
%       O_EDGE_DIST_VARIANCE: variance for the mapping of odometry edge
%       O_EDGE_DIST_MEAN: mean of the mapping of the odometry edge
%       LC_EDGE_DIST_VARIANCE: variance for the mapping of lc edge
%       LC_EDGE_DIST_MEAN: mean of the mapping of lc edge
%       edgeWeightMap: weight of each edge (optional)
%   OUTPUT:
%       A: (n x m) matrix, incidence matrix of the vertices and edges
%   Note: This doesn't include the variance in code. It just considers
%   fixed weights

vCount = length(vertices);
eCount = length(edges);
A = zeros(vCount, eCount);

%% Distance Mapping
if isempty(edgeWeightMap)
%     fprintf('\n\nCALCULATING weights in "GetIncidenceMatrix"\n\n');
    distEdges = zeros(1,eCount);
    % Now to separately calculate mean and var of distEdges for loop closures
    % and odometry edges and make the mapping
    % -- Odometry Edges
    oDistEdges     = distEdges(1:(vCount-1)); %odometry edges
    mapODistEdges  = ones(size(oDistEdges));
    mapODistEdges  = mapODistEdges * O_EDGE_DIST_MEAN;
    
    % -- Loop Closure Edges
    lcWeights = getDescriptorWeights(vertices, edges);
    
    % -- Original Loop closures
    olcDistEdges    = distEdges(vCount:initECount);
    mapolcDistEdges = ones(size(olcDistEdges));
    mapolcDistEdges = mapolcDistEdges * OLC_EDGE_DIST_MEAN;
    
    % -- Loop Closure Edges
    lcDistEdges    = distEdges(initECount+1:eCount);
    maplcDistEdges = ones(size(lcDistEdges));
    maplcDistEdges = maplcDistEdges * LC_EDGE_DIST_MEAN;
    
    % -- concatenate the weights
    mapDistEdges   = [mapODistEdges, mapolcDistEdges, maplcDistEdges];
    
    plot(mapDistEdges);
    %pause(3);
else
%     fprintf('\n\nCOPYING weights in "GetIncidenceMatrix"\n\n');
    mapDistEdges = edgeWeightMap;
end

% -- concatenate the distance maps

% fprintf('Check for correctness:: \ntotal edges:%d\nlength(mapDistEdges):%d\n',eCount,length(mapDistEdges));
% -- Construct Adjacency Matrix
for i = 1:eCount
    A(edges(i).v1, i) = -mapDistEdges(i);
    A(edges(i).v2, i) = mapDistEdges(i);
end


end

