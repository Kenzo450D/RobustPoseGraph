function [x,y] = getIntersectionPoint(line1, line2)
%GETINTERSECTIONPOINT Get Intersection Point of two lines
% Input:
%   lines are represented as a structure with the representative equation
%   as "ax + by + c = 0".
%   line1: first line
%   line2: second line, duh!
% Output:
%   x - x coordinate of the point of interesection
%   y - y coordinate of the point of intersection

% This is solved by manually solving a1x+ b1y + c1 = 0 and a2x + b2y + c2=0
% And multiplying a2 to the first equation, a1 to the second equation
% and negating the 2nd equation from the 1st equation
y = (line1.a*line2.c - line2.a*line1.c)/(line2.a*line1.b - line1.a*line2.b);
if (line2.a ~= 0)
    x = (-line2.c - line2.b*y)/line2.a;
else
    x = (-line1.c - line1.b*y)/line1.a;
end

% A = [line1.a,line1.b;line2.a,line2.b];
% B = [-line1.c; -line2.c];
% X = linsolve(A,B);
% x = X(1,1);
% y = X(2,1);
end