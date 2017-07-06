function [histgrm] = getHistogram(v, vertices, dim)
%GETHISTOGRAM makes a 8 bin histogram of orientations, from 0 to 2pi, comparing
%the vertex(pose) orientations, against the given vertex index. A limit of +- 10
%vertices are chosen.
% Input:
%   v: integer between 1 and vCount (neighbours of which are compared against)
%   vertices: set of vertices (struct containing id, x,y,o)
%   dim: dimension of the data (2/3)
% Output:
%   histgrm: A row matrix containing the 8bin normalized histogram

%% Initialization
vCount = size(vertices,2);

% -- declare empty storage
histgrm = zeros(1,8);

% get start and end Index
startIdx = v - 10;
if (startIdx < 1)
    startIdx = 1;
end
endIdx = v + 10;
if (endIdx > vCount)
    endIdx = vCount;
end

totalElems = endIdx - startIdx;

for i = startIdx : endIdx
    if (i~=v)
        if ( dim == 2 )
            diffO = vertices(v).o - vertices(i).o;
%             fprintf(1,'diffOrientation: %f\t',diffO);
            % ---- check if difference is less than 2*pi
            diffO = rem(diffO,2*pi);
            % ---- check if difference is within 0 and 2pi
            if diffO < 0
                diffO = diffO + 2*pi;
            end
            bin = floor(diffO / (pi/4)) + 1;
%             fprintf(1,'bin: %d\n',bin);
            histgrm(bin) = histgrm(bin) + 1;
        end
    end
end

% -- normalize histogram
histgrm = histgrm/totalElems;
end