function [ oEdges, lcEdges ] = groupOdometryEdge( eData )
%GROUPODOMETRYEDGE Groups all odometry edges to the first few edges, and
%then comes the Loop closures
%   It reads every edge, if found a LC edge, it is marked. moved to a
%   different dataset, deleted off the eData, and then added back to eData
%   at the end.

% if there are n-vertices, there can be at max (n-1) odometry edges.

    [lcEdges,oEdges] = removeOdometry(eData);
    c1 = size(eData,2);
    c2 = size(lcEdges,2);
    c3 = size(oEdges,2);
    if (c1 == (c2 + c3))
%         fprintf('Successful in dividing');
    else
        fprintf('Bug here! in group OdometryEdge\n');
    end

end

