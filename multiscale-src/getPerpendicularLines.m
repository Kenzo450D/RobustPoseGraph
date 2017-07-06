function [perpLines,perpLinePoints] = getPerpendicularLines(slopeTh, nStartPoints,nEndPoints,unitDist,x0,y0, sign1, sign2, debugSt)
%GETPERPENDICULARLINES returns the perpendicular line and point given a
%slope, and a point; It gives the line equations of nStartPoints and
%nEndPoints


%% initialize
nPerpLinePoints = nStartPoints + nEndPoints +1;
v0Idx           = nStartPoints + 1;
perpSlopeTh    = slopeTh + (pi/2);
perpLines      = struct('a',{},'b',{},'c',{});
% fprintf(1,'nStartPoints: %d\tnEndPoints: %d\n',nStartPoints,nEndPoints);
perpLinePoints = zeros(2,nPerpLinePoints);
idx = 1;

%% loop to get points and line equations

for i = 1:(nStartPoints+1)
    j = nStartPoints - (i - 1);
    % -- calculate step size on line
    step = j * unitDist;
    % -- find point (x,y) on line
    xstep = cos(slopeTh)*step;
    ystep = sin(slopeTh)*step;
    x1 = x0 + sign1 * xstep;
    y1 = y0 + sign1 * ystep;
    perpLinePoints(1,idx) = x1;
    perpLinePoints(2,idx) = y1;
    % -- find perpendicular line of the line at point 
    perpSlope = tan(perpSlopeTh);
    if (isnan(perpSlope) || perpSlope == inf || perpSlope == -inf)
        perpLines(idx).a = 1;
        perpLines(idx).b = 0;
        perpLines(idx).c = x1;
    else
        perpLines(idx).a = perpSlope;
        perpLines(idx).b = -1;
        perpLines(idx).c = -(perpSlope*x1 - y1);
    end
    if(debugSt == 1)
        plotaLine_plot(perpLines(idx),x1,y1,unitDist,'cyan');
    end
    idx = idx + 1;
end
for i = 1:nEndPoints
    j = i;
    % -- calculate step size on line
    step = j * unitDist;
    % -- find point (x,y) on line
    xstep = cos(slopeTh)*step;
    ystep = sin(slopeTh)*step;
    x1 = x0 + sign2 * xstep;
    y1 = y0 + sign2 * ystep;
    perpLinePoints(1,idx) = x1;
    perpLinePoints(2,idx) = y1;
    % -- find perpendicular line of the line at point 
    perpSlope = tan(perpSlopeTh);
    if (isnan(perpSlope) || perpSlope == inf || perpSlope == -inf)
        perpLines(idx).a = 1;
        perpLines(idx).b = 0;
        perpLines(idx).c = x1;
    else
        perpLines(idx).a = perpSlope;
        perpLines(idx).b = -1;
        perpLines(idx).c = -(perpSlope*x1 - y1);
    end
    if (debugSt == 1)
        plotaLine_plot(perpLines(idx),x1,y1,unitDist,'cyan');
    end
    idx = idx + 1;
end