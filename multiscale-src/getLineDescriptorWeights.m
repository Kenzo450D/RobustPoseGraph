function [edgeWeights, prunedEdges] = getLineDescriptorWeights(vertices, edges, debugSt)
%GETLINEDESCRIPTORWEIGHTS Get weights of the edges, based on the similarity
%of the perpendicular distances from the lines to the straight line passing
%through the loop closure vertex
% Input:
%   vertices:
%   edges:
%   initECount: *for debug purposes only*
% Output:
%   lcEdgeWeights: A column matrix containing the weights

% Documentation: As of 9th Jan, 2015: it works only for 2D

% -- Declare storage
% ---- Get count for lcEdges
vCount         = size(vertices,2);
eCount         = size(edges,2);

%% Get the average odometry edge
allEdgeWeight = 0;
for i = 1:(vCount-1)
    allEdgeWeight = allEdgeWeight + se2Distance(edges(i).v1,edges(i).v2,vertices);
end
unitDist = allEdgeWeight / (vCount-1);

%% Line Similarity between the edges

% -- Init
lineSimilarity = zeros(eCount,1); %smaller the value, better it is
% vertexOdom = getOdometry2D(vertices);

% -- Calculate line similarity
for i = 1:eCount
    % -- Debug
    if (debugSt == 1)
        fprintf(1,'i = %d\n',i);
        fprintf(1,'edgeConsistancy(%d,%d,vertices,%f)\n',edges(i).v1,edges(i).v2,unitDist);
    end
    % -- Get line Similarity
    lineSimilarity(i) = edgeConsistancy(edges(i).v1,edges(i).v2,vertices,unitDist,debugSt);
    
    if (edges(i).v2 - edges(i).v1 == 1) %odom edge
        if (lineSimilarity(i) > 4)
            % --override manual debug, report it.
            fprintf(1,'Odometry Exceeds Normal Condition, run: ');
            fprintf(1,'edgeConsistancy(%d,%d,vertices,%f,1)\n',edges(i).v1,edges(i).v2,unitDist);
        end
    end
    % -- Debug
    if debugSt == 1
        fprintf(1,'Line Similarity here: %f\n',lineSimilarity(i));
    end
        
end

% -- debug
% plot(lineSimilarity);
fprintf('calculated line similarity\n');
prunedEdges = find(lineSimilarity > 4);
% fprintf('lines pruned: %d\n',length(prunedEdges));

lineSimilarity(prunedEdges) = 4;
edgeWeights= lineSimilarity;
end