function edgeWeights   = getEdgeWeights(edges, vertices, kernelWidth, O_EDGE_DIST_MEAN,OLC_EDGE_DIST_MEAN)
%GETEDGEWEIGHTS Get Edge Weights for the 

%% Initialize

vCount = size(vertices, 2);
eCount = size(edges,2);
edgeWeights = zeros(eCount,1);

%% Get the average odom distance

% -- get count for odometry edges
oECount = vCount -1;
% -- Get distance among two vertices
odomEdgeDist = zeros(oECount, 1);
for i = 1:oECount
    v1 = edges(i).v1;
    v2 = edges(i).v2;
    odomEdgeDist(i) = se2Distance(v1, v2, vertices);
    edgeWeights(i) = O_EDGE_DIST_MEAN;
end
unitDist = mean(odomEdgeDist);
unitDist2 = median(odomEdgeDist);

% -- Debug
fprintf(1,'Unit Distance based on mean  : %f\n',unitDist);
fprintf(1,'Unit Distance based on median: %f\n',unitDist2);

%% Get the proximity of the loop closure Edges

% if the two vertices have a distance of within 2* kernel width, then it is
% considered to be a decent edge, else it is consdered to be a bad edge

lcECount = eCount - oECount;
lcEdgeDist = zeros(lcECount, 1);
idx = 1;
for i= (oECount + 1): eCount
    % -- get loop closure distance
    v1 = edges(i).v1;
    v2 = edges(i).v2;
    lcEdgeDist(idx) = se2Distance(v1, v2, vertices);
    % -- compare distance
    if (lcEdgeDist(idx) < 20 * kernelWidth * unitDist)
        edgeWeights(i) = 1*OLC_EDGE_DIST_MEAN;
    else
        edgeWeights(i) = ((kernelWidth*unitDist) / lcEdgeDist(idx))*OLC_EDGE_DIST_MEAN;
    end
    % -- update indexes
    idx = idx + 1;
end


%% return EdgeWeights



end