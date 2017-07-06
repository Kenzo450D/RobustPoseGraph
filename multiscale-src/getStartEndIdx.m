function [startIdx, endIdx] = getStartEndIdx(mappedPoints, v0Idx)
%GETSTARTENDIDX Get start and end indexes on mappedPoints which are the
%farthest away from x0 and y0
% Input:
%   mappedPoints: a 2xn array, with n (x & y) indexes
%   v0Idx: the index of the centre point (part of the loop closure edge)
% Output:
%   startIdx: index before v0Idx which is farthest from v0Idx
%   endIdx  : index after v0Idx which is farthest from v0Idx

%% Initialization
nMappedPoints = size(mappedPoints,2);
distMap = zeros(nMappedPoints,1);
x0 = mappedPoints(1,v0Idx);
y0 = mappedPoints(2,v0Idx);

%% loop through all vertices, get distance Map
for i = 1:nMappedPoints
    % -- get x and y coord
    xi = mappedPoints(1,i);
    yi = mappedPoints(2,i);
    % -- calculate distance
    distn = sqrt(((xi) -x0)^2 + (yi - y0)^2);
    % -- store distance
    distMap(i,1) = distn;
end
%% get which is the maximum either side
[~,startIdx] = max(distMap(1:v0Idx));
startIdx = startIdx(1);
[~,endIdx] = max(distMap(v0Idx+1:end));
endIdx = endIdx(1);
endIdx = endIdx + v0Idx;
end
