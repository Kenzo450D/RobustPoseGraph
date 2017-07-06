function [line] = getLine2D(v1start, v1end, v1, vertices)
%GETLINE2D Makes a line equation in the format of ax + by + c = 0
% Input:
%   v1start : start point to calculate slope
%   v1end   : end point to calculate slope
%   v1      : point through which the line passes
%   vertices: set of vertices(struct)

%% calculate slope
slope1 = (vertices(v1end).y - vertices(v1start).y)/(vertices(v1end).x - vertices(v1start).x);
% fprintf(1,'getLine2D: slope: %f\n',slope1);

%% get line equation
if (isnan(slope1) || slope1 == inf || slope1 == -inf)
    line.a = 1;
    line.b = 0;
    line.c = -vertices(v1).x;
else
    line.a = slope1;
    line.b = -1;
    line.c = -(slope1*(vertices(v1).x) - (vertices(v1).y));
end

end