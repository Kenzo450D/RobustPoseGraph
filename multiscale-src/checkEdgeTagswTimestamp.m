function [edgeTags] = checkEdgeTagswTimestamp(initVertices, initEdges, threshold, gtMatFileName, gtMapAutPose)

%% Init- load the files
doDebug = 0;

% -- GT file
load(gtMatFileName);
gtVertices = vertices;
if (doDebug == 1)
    gtEdges = edges;
    gtvCount = vCount;
    gteCount = eCount;
    gtlcEdges = zeros(2,eCount - (vCount - 1));
    gtlcEdgeCount = eCount - (vCount - 1);
    base = vCount -1;
    for i= 1:gtlcEdgeCount
        gtlcEdges(1,i) = edges(base+i).v1;
        gtlcEdges(2,i) = edges(base+i).v2;
    end
end
% -- init Mat file
% load(initMatFileName);
vertices = initVertices;
edges = initEdges;
vCount = size(vertices,2);
eCount = size(edges,2);

%% Check loop closures in initMatFileName

% we initialize correctLcIdx and incorrectLcIdx with all the loop closures which
% are correct and incorrect respectively by comparing their euclidean distance
% over in the ground truth. This is only in consideration that the number of
% vertices in the ground truth and the number of vertices in the odometry is the
% same.

correctLcIdx = [];
incorrectLcIdx = [];
encounteredgtlcEdges = 0;
for i = vCount:eCount
    v1 = edges(i).v1;
    v2 = edges(i).v2;
    gtv1x = gtVertices(gtMapAutPose(v1)).x;
    gtv1y = gtVertices(gtMapAutPose(v1)).y;
    gtv2x = gtVertices(gtMapAutPose(v2)).x;
    gtv2y = gtVertices(gtMapAutPose(v2)).y;
    distn = sqrt((gtv1x - gtv2x)^2 + (gtv1y - gtv2y)^2);
%     fprintf('%d %d\n',v1,v2);
%     fprintf('theshold: %f\tdistn: %f\n',threshold,distn)
    % -- Debug
    if (distn < threshold && (v1 - v2)>10)
        correctLcIdx = [correctLcIdx,i];
        %fprintf(1,'Added %d to correctLcIdx\n',i);
    else
        incorrectLcIdx = [incorrectLcIdx,i];
        %fprintf(1,'Added %d to incorrectLcIdx\n',i);
    end
   
end

if (doDebug == 1)
    fprintf('Original number of lc in ground truth: %d\n',gtlcEdgeCount);
    fprintf('Encountered loop closures in odom: %d\n',encounteredgtlcEdges);
end


%{
% -- get the list of good loop closures from gtMatFile
gtlcEdges = zeros(2,length(goodIdx));
for i= 1:length(goodIdx)
    gtlcEdges(1,i) = gtMatFileName(goodIdx(i)).v1;
    gtlcEdges(2,i) = gtMatFileName(goodIdx(i)).v2;
end

% -- get the list of loop closures from initMatFile
initlcEdges = zeros(2, (eCount - (vCount -1)));
base = (vCount -1);
for i = 1:length(initlcEdges)
    idx = base + i;
    initlcEdges(1,i) = edges(idx).v1;
    initlcEdges(2,i) = edges(idx).v2;
end

% -- check which of the loop closures in initlcEdges lie among gtlcEdges
gtEdgeGoodIdx = [];
for  i = 1:length(goodIdx)
    gtv1 = gtlcEdges(1,i);
    gtv2 = gtlcEdges(2,i);
    v1Pos = find(initlcEdges(1,:) == gtv1);
    if ( ~isempty(v1Pos))
        v2Pos = find(initlcEdges(2,v1Pos) == gtv2);
        if ~isempty(v2Pos)
            gtEdgeGoodIdx = [gtEdgeGoodIdx,v2Pos];
        end
    end
end
%}

%% Save tags to a file
% [~,name,~] = fileparts(initMatFileName);
% saveTagFileName = [name,'-EdgeTags.mat'];
edgeTags = zeros(1,eCount);
for i = 1:(vCount - 1)
    edgeTags(i) = 2;
end
for i = vCount:eCount
    foundIdx = find(correctLcIdx == i);
    if ~isempty(foundIdx)
        edgeTags(i) = 1;
    else
        edgeTags(i) = 0;
    end
end
% save(saveTagFileName,'edgeTags');

% -- function End
end