function [distanceMap, v0Idx] = getPerpendicularDistance(v1, v1start,v1end,vertices,unitDist, debugSt)
%GETPERPENDICULARDISTANCE Get perpendicular distance from line path
%corresponding to poses.
% Input
%   debugSt: 1: to get debug statements, pauses and plots
%            0: Skip debug statements, pauses and plots

%% initialize

% -- make line
if (debugSt == 1)
    fprintf(1,'vStart: %d\n',v1start);
    fprintf(1,'X: %f\tY: %f\n',vertices(v1start).x, vertices(v1start).y);
    fprintf(1,'vEnd  : %d\n',v1end);
    fprintf(1,'X: %f\tY: %f\n',vertices(v1end).x, vertices(v1end).y);
end
line = getLine2D(v1start, v1end, v1, vertices);
% fprintf(1,'After shift:\n');
% fprintf(1,'line Created:\na=%f\tb=%f\tc=%f\n',line.a,line.b,line.c);

% -- debug show Point
% if (debugSt == 1)
%     scatter(vertices(v1).x,vertices(v1).y,50,'red','filled');
% %     pause;
% end

% -- calculate slope
slope = -line.a/line.b;
slopeTh = atan(slope);

% -- map points on line
[mappedPoints] = mapPosesOnLine(line,v1start,v1end,vertices);
nMappedPoints = v1end - v1start + 1;

% -- Debug: Plot on line
% ---- plot the line
if (debugSt == 1)
    figure();
    hold on;
    c = jet(v1end - v1start + 1);
    a= 25;
    fprintf(1,'Filled Points: vertices on the path\n');
    idx = 1;
    for i = v1start:v1end
        scatter(vertices(i).x,vertices(i).y,a,c(idx,:),'filled');
        idx = idx + 1;
        if(rem(idx,2) == 0)
            a = a+1;
        end
    end
    fprintf(1,'Hollow Points: Mapped points\n');
    for i = 1:nMappedPoints
        scatter(mappedPoints(1,i),mappedPoints(2,i),50);
    end
%     pause;
end
% -- calculate number of steps
x0 = vertices(v1).x;
y0 = vertices(v1).y;
v0Idx = v1-v1start + 1;
[startIdx, endIdx] = getStartEndIdx(mappedPoints, v0Idx);
% fprintf(1,'startIdx: %d\tendIdx: %d\n',startIdx, endIdx);
if (debugSt == 1)
    fprintf(1,'Start Index (YELLOW): %d\n',startIdx);
    fprintf(1,'        Mapped Points(start Index): X: %f\t Y: %f\n',mappedPoints(1,startIdx),mappedPoints(2,startIdx));
    fprintf(1,'End   Index (BLACK) : %d\n',endIdx);
    fprintf(1,'        Mapped Points(end Index)  : X: %f\t Y: %f\n',mappedPoints(1,endIdx),mappedPoints(2,endIdx));
    fprintf(1,'v0Idx Index (RED)   : %d\n',v0Idx);
    fprintf(1,'        Mapped Points(v0Idx Index): X: %f\t Y: %f\n',mappedPoints(1,v0Idx),mappedPoints(2,v0Idx));
    scatter(mappedPoints(1,v0Idx),mappedPoints(2,v0Idx),200,'r','filled');
    scatter(mappedPoints(1,startIdx), mappedPoints(2,startIdx), 200, 'y','filled');
    scatter(mappedPoints(1,endIdx), mappedPoints(2,endIdx), 200, 'k','filled');
end

startDist = sqrt((mappedPoints(1,startIdx) -x0)^2 + (mappedPoints(2,startIdx) - y0)^2);
endDist   = sqrt((mappedPoints(1,endIdx) -x0)^2 + (mappedPoints(2,endIdx) - y0)^2);

% fprintf('startDist: %f\tendDist: %f\n',startDist, endDist);

nStartPoints = floor(startDist/unitDist);
nEndPoints   = floor(endDist/unitDist);

% -- declare storage
nPerpLinePoints = nStartPoints + nEndPoints +1;
v0IdxBkp        = v0Idx;
v0Idx           = nStartPoints + 1;

%% find points on the line at unit distances
% perpSlopeTh    = slopeTh + (pi/2);
% perpLines      = struct('a',{},'b',{},'c',{});
% perpLinePoints = zeros(2,nPerpLinePoints);
% idx = 1;

% -- get sign for step
% fprintf(1,'v0Idx : %d\n',v0Idx);
% fprintf(1,'nStartPoints: %d\tnEndPoints:%d\n',nStartPoints,nEndPoints);
% disp(size(mappedPoints));
[sign1, sign2] = getSign(slopeTh, startIdx, endIdx, v0IdxBkp, mappedPoints, debugSt);

[perpLines,perpLinePoints] = getPerpendicularLines(slopeTh, nStartPoints,nEndPoints,unitDist,x0,y0, sign1, sign2, debugSt);


% -- Debug the points
if (debugSt == 1)
    fprintf(1,'Perpendicular line points are :');
    for i = 1:nPerpLinePoints
        fprintf(1, 'x:%f\t,y: %f\n',perpLinePoints(1,i),perpLinePoints(2,i));
        if (perpLinePoints(1,i) == Inf || perpLinePoints(2,i) == Inf)
            fprintf(1,'+_+_+_+_+_+_+_+_+_+ERROR FOUND HERE!!!+_+_+_+_+_+_+_+_+_+\n');
        end
        if ( i > 1)
            pose1x = perpLinePoints(1,i-1);
            pose1y = perpLinePoints(2,i-1);
            pose2x = perpLinePoints(1,i);
            pose2y = perpLinePoints(2,i);
            p2pdistn = sqrt((pose2x - pose1x)^2 + (pose2y- pose1y)^2);
            fprintf(1,'Distance from previous point: %f\n',p2pdistn);
        end
    end
end

% -- Debug: scatter plot the perpendicular intersection points
if (debugSt == 1)
    fprintf(1,'perpendicular line points marked as red stars:\n');
    for i = 1:nPerpLinePoints
        scatter(perpLinePoints(1,i),perpLinePoints(2,i),50,'red','*');
    end
    fprintf(1,'Next is calculating intersection points:\n');
    pause;
end
%% find intersections
% -- find among which two mapped points are the perpLinePoints are in
idx = 1;
vIdx = v1start;
perpPointDistn = zeros(size(perpLinePoints,2),1);

% -- debug: new plot
% hold off;
% figure();
% hold on;
% scatter(perpLinePoints(1,:),perpLinePoints(2,:),20,'red','*');
% scatter(mappedPoints(1,:),mappedPoints(2,:),20,'blue','filled');

i = 2;
while (i<=nMappedPoints && idx<=nPerpLinePoints)
    % -- find among which two mapped points are the perpLinePoints are in
    ipFlag = 0; % flag for 'intersection point'
    p1x = mappedPoints(1,i -1);
    p1y = mappedPoints(2,i -1);
    p2x = mappedPoints(1,i);
    p2y = mappedPoints(2,i);
    distmp1 = sqrt((p1x - x0)^2 + (p1y - y0)^2);
    distmp2 = sqrt((p2x - x0)^2 + (p2y - y0)^2);
    distpp  = sqrt((perpLinePoints(1,idx) - x0)^2 + (perpLinePoints(2,idx) - y0)^2);
    %{
%     fprintf(1,'Positions\t\t\t\t\t\t\tDistance\n');
%     fprintf(1,'MapPoint1: %f\t%f\tDistance: %f\n',p1x,p1y,distmp1);
%     fprintf(1,'MapPoint2: %f\t%f\tDistance: %f\n',p2x,p2y,distmp2);
%     fprintf(1,'PerpPoint: %f\t%f\tDistance: %f\n', perpLinePoints(1,idx), perpLinePoints(2,idx),distpp);
%     fprintf(1,'index for PerpLinePoint: %d\n',idx);
%     fprintf(1,'Distance:\tMappedPoint1: %f\tMappedPoint2: %f\tPerpLinePoint: %f\n',distmp1,distmp2,distpp);
%     pause(1);
%     pause;
    %}
    if ( distpp < distmp1 && distpp >= distmp2 )
%         fprintf(1,'Less than point 1, greater than or equal to point 2\n');
        ipFlag = 1;
    elseif ( distpp >= distmp1 && distpp < distmp2 ) 
%         fprintf(1,'Greater than point 1, less than or equal to point 2\n');
        ipFlag = 1;
    elseif (distpp == 0)
%         fprintf(1,'Distance is 0\n');
        ipFlag = 1;
    end
    if (ipFlag == 1) 
        % ---- get line equation of the points 
        linemp = getLine2D((vIdx+i-2),(vIdx+i-1),(vIdx+i-1),vertices);
        
        % -- debug lines:
        if (debugSt == 1)
            fprintf(1,'lines Created in vertices:\n');
            disp(linemp);
        end
        
        % -- Plot the lines:
        if (debugSt == 1)
            plotaLine_plot(linemp, vertices(vIdx+i-2).x, vertices(vIdx+i-2).y, unitDist,'red');
            plotaLine_plot(perpLines(idx),perpLinePoints(1,idx), perpLinePoints(2,idx),unitDist,'blue');
        end
        % -- DEBUG: show the lines
%         disp(linemp);
%         disp(perpLines(idx));
        
        % ---- get intersection point
        [xi,yi] = getIntersectionPoint(perpLines(idx),linemp);
        
        if (debugSt == 1)
            fprintf('Intersection Point: x: %f\t%f\n',xi,yi);
            scatter(xi,yi,50,'blue','filled');
            % -- DEBUG: print the points
%         fprintf(1,'point1: %f\t%f\n',xi,yi);
%         fprintf(1,'point2: %f\t%f\n',perpLinePoints(1,idx),perpLinePoints(2,idx));
        end
        
        % ---- get distance between perpLinePoint and intersection point
        distn = sqrt((perpLinePoints(1,idx) - xi)^2 + (perpLinePoints(2,idx) - yi)^2);
        
        % ---- check which side of the line does the point lie
        lSide = line.a*xi + line.b*yi + line.c;
        if (lSide < 0)
            perpPointDistn(idx) = -distn;
        else
            perpPointDistn(idx) = distn;
        end
        
        if (debugSt == 1)
            fprintf(1,'Distance: %f\n',distn);
        end
        % -- iterate values
        idx = idx + 1;
        i= i -1; %as two points can fall between an average unit distance map
        % A better explanation of the above line: More than a perpendicular
        % interesection point can lie between two mapped points.
    end
    i = i +1;
end
distanceMap = perpPointDistn;
end