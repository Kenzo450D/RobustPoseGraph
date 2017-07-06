function [mappedPoints] = mapPosesOnLine(line,v1start,v1end,vertices)
%MAPPOSESONLINE Maps poses on a fixed line
% Input:
%   line:    struct in the form a,b,c, representing a line in the format 
%               ax + by + c = 0
%   v1start: start vertex
%   v1end:   end vertex
% Output:
%   mappedPoints: a 2rows x(number of points)cols array containing the
%   mapped points of the pose points on the line.

% Documentation available on:
%   https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line#Line_defined_by_an_equation

%% Initialization
nPoints = v1end - v1start + 1;
mappedPoints = zeros(2,nPoints);

%% loop through the points
idx = 1;
for i = v1start:v1end
    px = vertices(i).x;
    py = vertices(i).y;
    
    mappedPoints(1,idx) = ((line.b * ((line.b)*px - (line.a)*py) - line.a * line.c) / ((line.a)^2 + (line.b)^2));
    mappedPoints(2,idx) = ((line.a * ( - (line.b)*px + (line.a)*py) - line.b * line.c) / ((line.a)^2 + (line.b)^2));
    % check whether the point is on the line
%     output = line.a * mappedPoints(1,idx) + line.b * mappedPoints(2,idx) + line.c;
%     fprintf(1,'Point: %d, output: %f\n',i,output);
    idx = idx + 1;
end

end