function [vertexOdom] = getOdometry2D(vertices)
%GETODOMETRY2D Get 2D odometry from the vertices, as it's easier to calculate
%orientation differences, as reading from matrix is faster than struct

vCount = size(vertices,2);
vertexOdom = zeros(1,vCount);
for i = 1:vCount
    vertexOdom(i) = vertices(i).o;
end

end