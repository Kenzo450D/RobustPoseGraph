function [avgOdomDist] = getAverageOdometryDistance(fileName)

%% load the fileName
load(fileName);

totalOdomDist = 0;
for i = 1:(vCount-1)
    v1 = edges(i).v1;
    v2 = edges(i).v2;
    v1x = vertices(v1).x;
    v1y = vertices(v1).y;
    v2x = vertices(v2).x;
    v2y = vertices(v2).y;
    distn = sqrt((v1x - v2x)^2 + (v1y - v2y)^2);
    totalOdomDist = totalOdomDist+distn;
end
avgOdomDist = totalOdomDist / (vCount -1);
end
