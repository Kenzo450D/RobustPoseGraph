function [ A ] = getIncidenceMatrixFromDCS( inputFileNameBasis, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, vCount, edgeWeightMap)
%GETINCIDENCEMATRIXFROMDCS Returns the incidence matrix of a semi weighted graph
%   Make sure the sorting is done properly as done in "readFile.m"
%   Input:
%       inputG2oFileName: 
%       O_EDGE_DIST_MEAN: mean of the mapping of the odometry edge
%       LC_EDGE_DIST_MEAN: mean of the mapping of lc edge
%       edgeWeightMap: weight of each edge (optional)
%   OUTPUT:
%       A: (n x m) matrix, incidence matrix of the vertices and edges
%   Note: This doesn't include the variance in code. It just considers
%   fixed weights

%% initialize
inputG2oFileName = [inputFileNameBasis,'.g2o'];

%% Distance Mapping
if isempty(edgeWeightMap)
%     fprintf('\n\nCALCULATING weights in "GetIncidenceMatrix"\n\n');
    % -- Optimize the file by DCS
    % ---- Initialize
    outG2oFile = 'tmpFile.g2o';
    if (vCount > 5000)
        kernelWidth = 10;
    elseif (vCount > 10000)
        kernelWidth = 20;
    else
        kernelWidth = 1;
    end
    command          = ['g2o -i 30 -robustKernel DCS -robustKernelWidth ', ...
                        kernelWidth', ' -o ',outG2oFile, ' ',inputG2oFileName];
    % ---- Run the command
    sysCmdOutput     = system(command);
    
    % -- read the output File
    [vertices,vCount,edges,eCount, zeroVertex, zeroEdge, dim] = readg2oFile(outG2oFile,'filesCreated.txt',1);
    A = zeros(vCount, eCount);
    % -- Declare loop closure weights based on their distance between their
    % v1 and v2 in the g2o-dcs optimized graph
    mapDistEdges   = getEdgeWeights(edges, vertices, kernelWidth, O_EDGE_DIST_MEAN,OLC_EDGE_DIST_MEAN);   
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

