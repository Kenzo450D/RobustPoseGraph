function [lcEdgeWeights, prunedEdges] = getDescriptorWeights(vertices, edges, dim)
%GETDESCRIPTORWEIGHTS Get weights of the edges, based on the similarity of the
%descriptors
% Input:
%   vertices:
%   edges:
%   dim: dimensionality of the graph
% Output:
%   lcEdgeWeights: A column matrix containing the weights


% -- Declare storage
% ---- Get count for lcEdges
vCount         = size(vertices,2);
eCount         = size(edges,2);
lcEdgeCount    = eCount - (vCount - 1);
lcEdgeStartIdx = (vCount -1);
lcEdges        = edges(vCount:eCount);
% ---- Histogram descriptor for each of vertices
% ------ 8 bin histogram for each pose in the lcEdges
vHistogram = zeros(vCount,8);
% ------ To store the vertices encountered
encounteredVertices = zeros(1,vCount);
% ------ To store the similarity of histograms
simHist = zeros(lcEdgeCount,1);

% -- Get descriptor for each vertex in lcEdges

for i = 1:lcEdgeCount
    % -- for 2D
    % +- 10 steps to be considered, for boundary points, we consider lesser
    % number of steps
    % ---- get vertex index
    v1 = lcEdges(i).v1;
    v2 = lcEdges(i).v2;
    flagV1 = 0;
    flagV2 = 0;
    % ---- check if vertices are already encountered
    if encounteredVertices(v1) == 0
        flagV1 = 1;
    end
    if encounteredVertices(v2) == 0
        flagV2 = 1;
    end
    
    % ---- fill histogram 
    if (flagV1 == 1)
        vHistogram(v1,:) = getHistogram(v1,vertices,dim);
    end
    if (flagV2 == 1)
        vHistogram(v2,:) = getHistogram(v2,vertices,dim);
    end
    % ---- calculate similarity in histogram
    histDiff = vHistogram(v1) - vHistogram(v2);
    simHist(i) = sqrt(2) - sumsqr(histDiff);
    % ---- mark vertices as encountered
    encounteredVertices(v1) = 1;
    encounteredVertices(v2) = 1;
end

lcEdgeWeights = simHist;
prunedEdges = edges;
% -- DEBUG :: making a fancy print
fprintf(1,'number of loop closure Edges: %d\n',lcEdgeCount);
% return;
% for i=1:lcEdgeCount
%     fprintf(1,'Similarity: %f',lcEdgeWeights(i));%\t\t'
%     if lcEdgeWeights(i) == 0
%         fprintf(1,'\t\tZero for edge: %d,%d\n',lcEdges(i).v1,lcEdges(i).v2);
%         fprintf(1,'Edge to Delete: %d',(lcEdgeStartIdx + i));
%         lcEdgeStartIdx = lcEdgeStartIdx - 1;
%         prunedEdges(lcEdgeStartIdx+i)=[];
%     else
%         fprintf(1,'\n');
%     end
% end
end