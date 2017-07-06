function [ edges ] = pruneEdges( edges, badLC )
%PRUNEEDGES Prunes edges off 'edges', Index specified by vector badLC
%   Detailed explanation goes here
    edges(badLC) = [];
end

