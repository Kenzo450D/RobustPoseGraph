function [ edgeIdx ] = identifyLC( edges )
%IDENTIFYLC Identifies the loop closures and returns back it's indexes
%   Function checks the v1 and v2 of each edge, if they are not
%   consecutive, it is considered as a Loop Closure Edge

eCount = length(edges);
edgeIdx = zeros(1);
idx = 1;
for i = 1 : eCount
    if (abs(edges(i).v2 - edges(i).v1) ~=  1)
        edgeIdx(idx) = i;
        idx = idx +1 ;
    end
end
end

