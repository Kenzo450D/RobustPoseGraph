function plotaLine_plot(line, x0,y0, unitDist,color)
%PLOTALINE plots a few points of the line, using 2d line plot
% Input:
%   line: line in form of a structure, 3 parts, a,b,c; ax+by+c = 0
%   x0,y0: neighbourhood of point to be plotted
%   unitDist: unit Distance with which points are to be plotted
%   color: color of the line
% Output:
%   scatter plot. Nothing returned

%% form the line in a form of f(x)
% -- get slope
slope = -line.a/line.b;
slopeth = atan(slope);
% -- declare storage
pp = 5;
xPoints = zeros(2,1);
yPoints = zeros(2,1);
idx = 1;
% -- get the points
step = unitDist * pp;
xStep = step*cos(slopeth);
xj = x0 + xStep;
yj = (-line.a*xj - line.c)/line.b;
xPoints(1,1) = xj;
yPoints(1,1) = yj;
xj = x0 - xStep;
yj = (-line.a*xj - line.c)/line.b;
xPoints(2,1) = xj;
yPoints(2,1) = yj;

lineSpec = strcat(color,'-');

%% line plot
plot(xPoints, yPoints,lineSpec);
end