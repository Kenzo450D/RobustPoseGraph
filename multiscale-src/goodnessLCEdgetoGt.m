function [precisionAllLC, recallAllLC, precisionOrgLC, recallOrgLC, precisionSynLC, recallSynLC] = goodnessLCEdgetoGt(file, threshold, initvCount, initVertices, initeCount, initEdges, badInit, goodInit, bad_LC_idxAUT)
%GOODNESSLCEDGETOGT Checks if edges are good comparing them to the
%corresponding euclidean distance in the initVertices
%pruned edges consider only the bad edges
% Input:
%   bad_LC_idxAUT: bad indexes declared by heat embedding threshold.

load(file);

%% inital noise

badEdges = edges(bad_LC_idxAUT);
fprintf('Good Edges in ground truth: %d\n',length(goodInit));
fprintf('Bad Edges in ground truth : %d\n',length(badInit));

%% Precision and Recall (whole data)

badlcIdxFile = [];
goodlcIdxFile = [];
% -- Loop through all loop closures in file. find out which among them are
% bad and which among them are good.
% fprintf('file vCount: %d\nfile eCount: %d\n',vCount, eCount);
for i = (vCount - 1) : eCount
    fv1 = edges(i).v1;
    fv2 = edges(i).v2;
    %     fprintf('Edge: %d %d\n',fv1,fv2);
    % Check euclidean distance between these two vertices in initVertices
    pv1x = initVertices(fv1).x;
    pv2x = initVertices(fv2).x;
    pv1y = initVertices(fv1).y;
    pv2y = initVertices(fv2).y;
    %     fprintf('pv1x: %d, pv2x: %d, pv1y: %d, pv2y: %d\n',pv1x,pv2x,pv1y, pv2y);
    distn = sqrt((pv1x - pv2x)^2 + (pv1y - pv2y)^2);
    if (distn > threshold)
        badlcIdxFile = [badlcIdxFile;i];
    else
        goodlcIdxFile = [goodlcIdxFile;i];
    end
end
fprintf('Good Edges in file : %d\n', length(goodlcIdxFile));
fprintf('Bad Edges in file  : %d\n', length(badlcIdxFile));

% -- now to check which among pruned edges are good and bad.
% pruned edges is our set of edges classified as bad.
peCount = length(badEdges);
badlcIdxPruned = [];
goodlcIdxPruned = [];
fprintf('Number of edges classified as bad: %d\n',peCount);
for i = 1:peCount
    pv1 = badEdges(i).v1;
    pv2 = badEdges(i).v2;
    % Check euclidean distance between these two vertices in initVertices
    pv1x = initVertices(pv1).x;
    pv2x = initVertices(pv2).x;
    pv1y = initVertices(pv1).y;
    pv2y = initVertices(pv2).y;
    distn = sqrt((pv1x - pv2x)^2 + (pv1y - pv2y)^2);
    %     fprintf('Distance: %d, loop: %d\n',distn,i);
    if (distn > threshold)
        badlcIdxPruned = [badlcIdxPruned;i];
    else
        goodlcIdxPruned = [goodlcIdxPruned;i];
    end
end
fprintf('Bad Edges checked as Good: %d\n',length(goodlcIdxPruned));
fprintf('Bad Edges checked as Bad : %d\n',length(badlcIdxPruned));

% -- now to calculate precision & recall
precisionAllLC = length(badlcIdxPruned)/peCount;
recallAllLC = length(badlcIdxPruned)/length(badlcIdxFile);
fprintf('Precision allLC %f\n',precisionAllLC);
fprintf('Recall allLC %f\n',recallAllLC);

%% Precision and Recall (org and syn)
badlcIdxFileOrg = badlcIdxFile(find(badlcIdxFile <= initeCount));
goodlcIdxFileOrg = goodlcIdxFile(find(goodlcIdxFile <= initeCount));

% -- calculate which among good pruned edges are organic loop closures.

% Organic loop closures are the only ones present in the ground Truth File,
% anything beyond that is synthetic.
% -- Synthetic Edge index
firstSynEdge = initeCount + 1;
% -- first instance of synFirstIdx in badEdge declaration list from heat
% embedding
synFirstIdx = find(bad_LC_idxAUT>=firstSynEdge);
if(~ isempty(synFirstIdx))
    % -- Precision and Recall (organic loop closures)
    synFirstIdx = synFirstIdx(1);
    % fprintf('Index of first synthetic edge in pruned edges: %d\n',synFirstIdx);
    
    badlcIdxPrunedOrg = badlcIdxPruned(find(badlcIdxPruned < synFirstIdx));
    goodlcIdxPrunedOrg = goodlcIdxPruned(find(goodlcIdxPruned < synFirstIdx));
    fprintf('Correct Step: wrong Original Loop Closures in bad Edges(AUT) :%d\n',length(badlcIdxPrunedOrg));
    fprintf('Wrong Step:   good Original Loop Closures in bad Edges(AUT)  :%d\n',length(goodlcIdxPrunedOrg));
    precisionOrgLC = length(badlcIdxPrunedOrg)/(synFirstIdx-1);
    recallOrgLC    = length(badlcIdxPrunedOrg)/length(goodlcIdxFileOrg);
    fprintf('Precision orgLC %f\n',precisionOrgLC);
    fprintf('Recall orgLC %f\n',recallOrgLC);
    
    
    % -- Precision and Recall (synthetic loop closures)
    badlcIdxFileSyn = badlcIdxFile(find(badlcIdxFile > initeCount));
    goodlcIdxFileSyn = goodlcIdxFile(find(goodlcIdxFile > initeCount));
    
    badlcIdxPrunedSyn = badlcIdxPruned(find(badlcIdxPruned >= synFirstIdx));
    goodlcIdxPrunedSyn = goodlcIdxPruned(find(goodlcIdxPruned >= synFirstIdx));
    
    % ---- DEBUG : Print
    % fprintf('length(badlcIdxFileSyn) : %d\n', length(badlcIdxFileSyn));
    % fprintf('length(goodlcIdxFileSyn) : %d\n',length(goodlcIdxFileSyn));
    % fprintf('length(badlcIdxPrunedSyn) : %d\n', length(badlcIdxPrunedSyn));
    % fprintf('length(goodlcIdxPrunedSyn ) : %d\n', length(goodlcIdxPrunedSyn));
    
    truePosSynLC = length(badlcIdxPrunedSyn);
    %number of loop closure edges in pruned edges which are synthetic
    nlcepes = length(goodlcIdxPrunedSyn) + length(badlcIdxPrunedSyn);
    precisionSynLC = truePosSynLC / nlcepes;
    fprintf('Precision synLC %f\n',precisionSynLC);
    recallSynLC = truePosSynLC / length(badlcIdxFileSyn);
    fprintf('Recall synLC %f\n',recallSynLC);
else
    precisionOrgLC = nan;
    recallOrgLC = nan;
    precisionSynLC = nan;
    recallSynLC = nan;
    fprintf('Precision orgLC %f\n',precisionOrgLC);
    fprintf('Recall orgLC %f\n',recallOrgLC);
    fprintf('Precision synLC %f\n',precisionSynLC);
    fprintf('Recall synLC %f\n',recallSynLC);
end

end

