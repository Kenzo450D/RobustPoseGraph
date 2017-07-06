function [v1start,v2start,v1end,v2end] = getEndPoints(v1,v2, vertices, thresholdDist)
%GETENDPOINTS Get end points to compare similarity in local topology, of two
% vertices
% Input:
%   v1: Vertex 1 of a loop closure edge
%   v2: Vertex 2 of a loop closure edge
%   vertices: The structure of vertices, containing id, and pose information
%   thresholdDist: the threshold distance after which it is considered to be a
%       descriptive enough for a scale

%% Initialize
v1start   = v1;
v1end     = v1;
v2start   = v2;
v2end     = v2;
startFlag = 1;
endFlag   = 1;
vCount    = size(vertices,2);

% fprintf(1,'Threshold Distance: %f\n',thresholdDist);
%% Loop through poses to get end points
while (true)
    % -- check if start vertex is within range
    tmpV1Start = v1start - 1;
    tmpV2Start = v2start - 1;
    if (tmpV1Start <= 0 || tmpV2Start <= 0)
        startFlag = 0;
    else
        v1start = tmpV1Start;
        v2start = tmpV2Start;
    end
    
    % -- Check if end vertex is within range
    tmpV1End   = v1end + 1;
    tmpV2End   = v2end + 1;
    if (tmpV1End > vCount || tmpV2End > vCount)
        endFlag = 0;
    else
        v1end = tmpV1End;
        v2end = tmpV2End;
    end
    
    % -- Check if distance crosses threshold distance
    distn1 = se2Distance(v1start, v1end, vertices);
%     fprintf('v2start: %f\tv2end: %f\n',v2start,v2end);
    distn2 = se2Distance(v2start, v2end, vertices);
%     fprintf(1,'Distance 1: %f\tDistance 2: %f\n',distn1, distn2);
    if (distn1 > thresholdDist && distn2 > thresholdDist)
        startFlag = 0;
        endFlag = 0;
    end
    if (startFlag == 0 && endFlag == 0)
        break;
    end
    
    % -- Check if any orientation difference is more than pi
    endFlag1 = checkOrientationDifference(v1start, v1end,vertices);
    endFlag2 = checkOrientationDifference(v2start, v2end,vertices);
%     endFlag1 = checkOrientationDifference(v1start, v1end, vertexOdom);
%     endFlag2 = checkOrientationDifference(v2start, v2end, vertexOdom);
    if(endFlag1 == 0 || endFlag2 == 0)
        break;
    end
end

end