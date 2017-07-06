function [edgeTags] = checkEdgeTags(initVertices, initEdges, threshold, gtMatFileName)

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
    gtv1x = gtVertices(v1).x;
    gtv1y = gtVertices(v1).y;
    gtv2x = gtVertices(v2).x;
    gtv2y = gtVertices(v2).y;
    distn = sqrt((gtv1x - gtv2x)^2 + (gtv1y - gtv2y)^2);
%     fprintf('%d %d\n',v1,v2);
%     fprintf('theshold: %f\tdistn: %f\n',threshold,distn)
    % -- Debug
    if (doDebug == 1)
        fprintf('v1: %d\tv2: %d\n',v1,v2);
        fprintf('theshold: %f\tdistn: %f\n',threshold,distn);
        % ---- check if edge is a part of ground truth

        % ---- search from 1st vertex as v1
        [v1gtIdx,v1gtIdxPos] = find(gtlcEdges(1,:) == v1);
        fprintf('Searching for the first index as v1 in ground truth: ');
        if ~isempty(v1gtIdx)
            fprintf('found!');
            disp(v1gtIdx);
            v2gtIdx = find(gtlcEdges(2,v1gtIdx) == v2);
            if ~isempty(v2gtIdx)
    %             fprintf('Found this edge in Ground Truth!\n');
                fprintf('Pose in matrix: %d, v1: %d, v2: %d\n',v1gtIdxPos,gtlcEdges(1,v1gtIdxPos),gtlcEdges(2,v1gtIdxPos));
                gtIdx = base + v1gtIdxPos;
                fprintf('Ground Truth Index: %d\n', gtIdx);
    %             disp(gtEdges(gtIdx));
                encounteredgtlcEdges = encounteredgtlcEdges + 1;
            end
        else
            fprintf('Not Found!\n');
        end
        % ---- search from 1st vertex as v2
        [v1gtIdx,v1gtIdxPos] = find(gtlcEdges(1,:) == v2);
        fprintf('Searching for the first index as v2 in ground truth: ');
        if ~isempty(v1gtIdx)
            fprintf('found!');
            disp(v1gtIdx);
            v2gtIdx = find(gtlcEdges(2,v1gtIdx) == v1);
            if ~isempty(v2gtIdx)
    %             fprintf('Found this edge in Ground Truth!\n');
                fprintf('Pose in matrix: %d, v1: %d, v2: %d\n',v1gtIdxPos,gtlcEdges(1,v1gtIdxPos),gtlcEdges(2,v1gtIdxPos));
                gtIdx = base + v1gtIdxPos;
                fprintf('Ground Truth Index: %d\n', gtIdx);
    %             disp(gtEdges(gtIdx));
                encounteredgtlcEdges = encounteredgtlcEdges + 1;
            end
        else
            fprintf('Not Found!\n');
        end
        if (distn < threshold)
            correctLcIdx = [correctLcIdx,i];
            fprintf('Added %d to correctLcIdx\n',i);
        else
            incorrectLcIdx = [incorrectLcIdx,i];
            fprintf('Added %d to incorrectLcIdx\n',i);
        end
    else
        % -- Compare distance against threshold
        if (distn < threshold)
            correctLcIdx = [correctLcIdx,i];
        else
            incorrectLcIdx = [incorrectLcIdx,i];
        end
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