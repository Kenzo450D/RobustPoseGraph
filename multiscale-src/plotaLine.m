function plotaLine(line, x0,y0, unitDist,color)
%PLOTALINE plots a few points of the line, using scatter plot
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
pp = 50;
ptp = pp*2 + 1;
xPoints = zeros(ptp,1);
yPoints = zeros(ptp,1);
idx = 1;
% -- get the points
for i = 0:pp
    j = pp-i;
    step = unitDist*j;
    xStep = step*cos(slopeth);
    yStep = step*sin(slopeth);
    xj = x0 + xStep;
    yj = (-line.a*xj - line.c)/line.b;
%     yj = y0 + yStep;
    xPoints(idx,1) = xj;
    yPoints(idx,1) = yj;
    idx = idx + 1;
end
for i = 1:pp
    step = unitDist*i;
    xStep = step*cos(slopeth);
    yStep = step*sin(slopeth);
    xj = x0 - xStep;
    yj = (-line.a*xj - line.c)/line.b;
%     yj = y0 - yStep;
    xPoints(idx,1) = xj;
    yPoints(idx,1) = yj;
    idx = idx + 1;
end
%% scatter plot
scatter(xPoints,yPoints,30,color,'filled');
end