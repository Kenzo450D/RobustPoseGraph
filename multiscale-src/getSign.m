function [sign1, sign2] = getSign(slopeTh, startIdx, endIdx, v0Idx, mappedPoints, debugSt)
%GET SIGN Get the sign (+ve or -ve) to take steps in either direction of mapped
%Points. This would help in taking steps while calculating unit sized steps on
%either side.

%% Initialize
xStart = mappedPoints(1,startIdx);
yStart = mappedPoints(2,startIdx);
xEnd   = mappedPoints(1,endIdx);
yEnd   = mappedPoints(2,endIdx);
x0     = mappedPoints(1,v0Idx);
y0     = mappedPoints(2,v0Idx);
sgn1 = 1;
sgn2 = -1;

% -- Debug
if (debugSt == 1)
    fprintf(1,'Start   Point: X: %f\tY: %f\n',xStart, yStart);
    fprintf(1,'End     Point: X: %f\tY: %f\n',xEnd, yEnd);
    fprintf(1,'Vertex0 Point: X: %f\tY: %f\n',x0, y0);
end

%% Get Euclidean Distance
dist1 = sqrt((xStart - x0)^2 + (yStart - y0)^2);
dist2 = sqrt((xEnd - x0)^2 + (yEnd - y0)^2);

% -- Debug
if (debugSt == 1)
    fprintf(1,'Distance from start to vertex0 : %f\n',dist1);
    fprintf(1,'Distance from  end  to vertex0 : %f\n',dist2);
end

%% Get sign for Start Idx
xDist1 = cos(slopeTh) * dist1;
yDist1 = sin(slopeTh) * dist1;
xPos1 = x0 - xDist1;
yPos1 = y0 - yDist1;
xPos2 = x0 + xDist1;
yPos2 = y0 + yDist1;

chkStartDist1 = sqrt((xStart - xPos1)^2 + (yStart - yPos1)^2);
chkStartDist2 = sqrt((xStart - xPos2)^2 + (yStart - yPos2)^2);

if (chkStartDist1 < chkStartDist2)
    sign1 = sgn2;
else
    sign1 = sgn1;
end

% -- Debug
if (debugSt == 1)
    fprintf(1,'For START POINT:\n');
    fprintf(1,'Pose After adding:\n');
    fprintf(1,'Pose1: X: %f\tY: %f\n',xPos1, yPos1);
    fprintf(1,'Pose2: X: %f\tY: %f\n',xPos2, yPos2);
    fprintf(1,'Check Start Distance 1: %f\n',chkStartDist1);
    fprintf(1,'Check Start Distance 2: %f\n',chkStartDist2);
    fprintf(1,'Sign Chosen: %d\n',sign1);
end

%% Get the sign for End Idx

% Approximation that other sign would be the opposite.
sign2 = -sign1;

%{
% xDist2 = cos(slopeTh) * dist2;
% yDist2 = sin(slopeTh) * dist2;
% xPos1 = x0 - xDist2;
% yPos1 = y0 - yDist2;
% xPos2 = x0 + xDist2;
% yPos2 = y0 + yDist2;
% 
% chkEndDist1 = sqrt((xEnd - xPos1)^2 + (yEnd - yPos1)^2);
% chkEndDist2 = sqrt((xEnd - xPos2)^2 + (yEnd - yPos2)^2);
% 
% if (chkEndDist1 < chkEndDist2)
%     sign2 = sgn2;
% else
%     sign2 = sgn1;
% end
% 
% if (debugSt == 1)
%     fprintf(1,'For END POINT:\n');
%     fprintf(1,'Pose After adding:\n');
%     fprintf(1,'Pose1: X: %f\tY: %f\n',xPos1, yPos1);
%     fprintf(1,'Pose2: X: %f\tY: %f\n',xPos2, yPos2);
%     fprintf(1,'Check End Distance 1: %f\n',chkEndDist1);
%     fprintf(1,'Check End Distance 2: %f\n',chkEndDist2);
%     fprintf(1,'Sign Chosen: %d\n',sign2);
% end
%}

end

