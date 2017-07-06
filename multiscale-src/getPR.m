function [precision, recall] = getPR(prunedEdgeFileName, correctLcIdx, incorrectLcIdx, initMatFileName)
%GETPR Returns Precision and Recall values for a given outFile, which in turn is
%the file with the pruned edges

%% List the correct and incorrect
doDebug = 0;
load(initMatFileName);
positiveLC = zeros(2, length(incorrectLcIdx));
negativeLC = zeros(2, length(correctLcIdx));
for i = 1:length(incorrectLcIdx)
    positiveLC(1,i) = edges(incorrectLcIdx(i)).v1;
    positiveLC(2,i) = edges(incorrectLcIdx(i)).v2;
end
for i = 1:length(correctLcIdx)
    negativeLC(1,i) = edges(correctLcIdx(i)).v1;
    negativeLC(2,i) = edges(correctLcIdx(i)).v2;
end
initlcCount = eCount - (vCount -1);

%% Load the file with pruned Edges, make the check
load(prunedEdgeFileName);
truePosCount = 0;
falsePosCount = 0;
trueNegCount = 0;
falseNegCount = 0;
% make flag 1, vertex found here
positiveLCflag = zeros(size(incorrectLcIdx));
negativeLCflag = zeros(size(correctLcIdx));
lcCounted = 0;

if (doDebug == 1)
    fprintf(1,'Number of loop closures in initFile: %d\n',(length(incorrectLcIdx) + length(correctLcIdx)));
    fprintf(1,'Number of loop closures in initFile: %d\n',initlcCount);
    fprintf(1,'Number of correct loop closures in initFile: %d\n',length(correctLcIdx));
    fprintf(1,'Number of incorrect loop closures in initFile: %d\n',length(incorrectLcIdx));
    fprintf(1,'Number of loop closures in pruned File: %d\n',(eCount - (vCount - 1)));
end

for i = vCount: eCount
    v1 = edges(i).v1;
    v2 = edges(i).v2;
    % v1 and v2 corresponds to the edge which has remained in the graph after
    % pruning. So if found in positiveLC, that would add as falseNegative. If
    % found in negativeLC it would add up to trueNegative
    % -- check in positive LC
    [v1pLC,v1Idx] = find(positiveLC(1,:) == v1);
    if ~isempty(v1pLC)
        [v2pLC] = find(positiveLC(2,v1Idx) == v2);
        if ~isempty(v2pLC)
            % -- found the vertex in positiveLC
            falseNegCount = falseNegCount + 1;
            positiveLCflag(v1Idx) = 1;
            if (doDebug == 1)
                fprintf('FalseNegCount Increased!\nfalseNegCount: %d\n',falseNegCount);
                fprintf('Index in PositiveLC: %d\n',v1Idx);
                fprintf('Vertex in PositiveLC: v1: %d\tv2: %d\n',positiveLC(1,v1Idx),positiveLC(2,v1Idx));
            end
        end
    end
    % -- check in negative LC
    [v1nLC,v1Idx] = find(negativeLC(1,:) == v1);
    if ~isempty(v1nLC)
        [v2nLC] = find(negativeLC(2,v1Idx) == v2);
        if ~isempty(v2nLC)
            % -- found the vertex in negativeLC
            trueNegCount = trueNegCount + 1;
            negativeLCflag(v1Idx) = 1;
            if (doDebug == 1)
                fprintf('trueNegCount Increased!\ntrueNegCount: %d\n',trueNegCount);
                fprintf('Index in PositiveLC: %d\n',v1Idx);
                fprintf('Vertex in PositiveLC: v1: %d\tv2: %d\n',negativeLC(1,v1Idx),negativeLC(2,v1Idx));
            end
        end
    end
    lcCounted = lcCounted + 1;
end

%% calculate precision and recall
% Precision = truePositive/(truePositive + falsePositive)
% Recall = truePositive / (truePositive + falseNegative)

% falseNegative would be the ones which
% precision =0;
% recall =0;

truePosCount = length(positiveLCflag) - sum(positiveLCflag);
falsePosCount = length(negativeLCflag) - sum(negativeLCflag);

if (doDebug == 1)
    fprintf(1,'TruePositive: %d\n',truePosCount);
    fprintf(1,'FalsePositive: %d\n',falsePosCount);
    fprintf(1,'TrueNegative: %d\n',trueNegCount);
    fprintf(1,'FalseNegative: %d\n',falseNegCount);
    fprintf(1,'Loop Closures counted: %d\n',lcCounted);
end

check1 = truePosCount + falseNegCount - length(positiveLCflag);
check2 = falsePosCount + trueNegCount - length(negativeLCflag);
if (check1 ~= 0 && check2 ~= 0)
    fprintf(1,'Error in calculating PR\n');
end
precision = truePosCount / (truePosCount + falsePosCount);
recall    = truePosCount / (truePosCount + falseNegCount);

end
