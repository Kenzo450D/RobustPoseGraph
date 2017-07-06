function [edgeDesp] = edgeConsistancy(v1, v2, vertices, unitDist, testSimilarity)
%EDGECONSISTENCY Calculates the 

%% Get boundary limitation of vertices
% boundary conditions as in when there is not more than 5 vertices on either 
% side
vCount = size(vertices,2);
if (v1 < 6 && v2 > (vCount-6))
    edgeDesp = NaN;
    fprintf(1,'Not calculating at %f\t%f\n',v1,v2);
    return;
end
if (v2 < 6 && v2 > (vCount-6))
    edgeDesp = NaN;
    fprintf(1,'Not Calculating at %f\t%f\n',v1,v2');
    return;
elseif (v2 >= (vCount -1) || v1 >= (vCount -1))
    edgeDesp = NaN;
    fprintf(1,'Not Calculating at %f\t%f\n',v1,v2');
    return;
end

%% Take 5 to 20 unit lengths on either side
thresholdDist = 20 * unitDist;
[v1start,v2start,v1end,v2end] = getEndPoints(v1,v2, vertices, thresholdDist); 

% -- Debug
if testSimilarity == 1
    v1sx = vertices(v1start).x;
    v1sy = vertices(v1start).y;
    v1ex = vertices(v1end).x;
    v1ey = vertices(v1end).y;
    v2sx = vertices(v2start).x;
    v2sy = vertices(v2start).y;
    v2ex = vertices(v2end).x;
    v2ey = vertices(v2end).y;
    distn1 = sqrt((v1sx - v1ex)^2 + (v1sy - v1ey)^2);
    distn2 = sqrt((v2sx - v2ex)^2 + (v2sy - v2ey)^2);
    fprintf(1,'distance1 : %f\t\tdistance2: %f\n',distn1,distn2);
    fprintf(1,'v1: %d\nv1start: %d\nv1end: %d\nunitDist: %f\n',v1,v2start,v1end,unitDist);
end

%% Get distance maps

if (testSimilarity == 0)
    [distmap1, v1Idx] = getPerpendicularDistance(v1, v1start, v1end, vertices, unitDist,0);
    [distmap2, v2Idx] = getPerpendicularDistance(v2, v2start, v2end, vertices, unitDist,0);
else
    [distmap1, v1Idx] = getPerpendicularDistance(v1, v1start, v1end, vertices, unitDist,1);
    [distmap2, v2Idx] = getPerpendicularDistance(v2, v2start, v2end, vertices, unitDist,1);
end



%% Set up equal sizes for distance maps
% So that the difference can be calculated with equal number of elements
if (v1Idx < v2Idx)
    startCut = v1Idx;
else
    startCut = v2Idx;
end

rem1 = size(distmap1,1) - v1Idx;
rem2 = size(distmap2,1) - v2Idx;
if(rem1 < rem2)
    endCut = rem1;
else
    endCut = rem2;
end
sc1 = v1Idx - startCut + 1;
sc2 = v2Idx - startCut + 1;
ec1 = v1Idx + endCut;
ec2 = v2Idx + endCut;
distmap1 = distmap1(sc1:ec1);
distmap2 = distmap2(sc2:ec2);

%% Compare the distances
if (testSimilarity == 1)
    fprintf(1,'***************************************************************\n');
    fprintf(1,'v1 = %d \t v2 = %d\n',v1,v2);
    % -- Display distance maps
    fprintf(1,'Size of distmap1: ');
    disp(size(distmap1));
    fprintf(1,'Distmap1:\n');
    disp(distmap1);
    fprintf(1,'Size of distmap2: ');
    disp(size(distmap2));
    fprintf(1,'Distmap2:\n');
    disp(distmap2);
    fprintf(1,'===============================================================\n');
end

%% Report the difference
edgeDesp = distmap1 - distmap2;
edgeDesp = abs(edgeDesp);
edgeDesp = sum(edgeDesp)/size(edgeDesp,1);

end

%% 