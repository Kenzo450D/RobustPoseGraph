function [ distn ] = se2Distance( v1,v2,vertices )
%SE2DISTANCE Calculates the SE2 distance between v1 and v2 indexes
%corresponding to vertices in vertices
% Input:
%   v1: vertex index 1
%   v2: vertex index 2
%   vertices: struct of vertices
% if ~(mod(v1,1) == 0)
%     fprintf(1,'v1: %f\n',v1);
% end
% 
% if ~(mod(v2,1) == 0)
%     fprintf(1,'v2: %f\n',v2);
% end
% fprintf(1,'v1: %f\n',v1);
v1x = vertices(v1).x;
v1y = vertices(v1).y;
v2x = vertices(v2).x;
v2y = vertices(v2).y;
distn = sqrt ( (v1x - v2x)^2 + (v1y - v2y)^2);

end

