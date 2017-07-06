function [precision, recall] = checkIter(inputMatFileName, gtMatFileName, outputFileNameBasis, gtMapAutPose) 
%CHECKPOSSIBILITIES Check the possibilities of the graph laplacian and heat
%embedding in graph slam.

% -- check if using the iterative measure makes sense, prune at every iteration
%    update the edges and recalculate the incidence matrix, make the laplacian
%    and heat embedding.

%% Initialize

O_EDGE_DIST_MEAN = 0.92;
OLC_EDGE_DIST_MEAN = 0.7;
LC_EDGE_DIST_MEAN = 0.3;


%% Given a t-Scale and edge-weights, we want the file with marked good and bad edges

% -- load the mat file
load(inputMatFileName); 



% allT_scale = [5,10,70,100];
allT_scale = [100];
fMeasure = zeros(size(allT_scale));
nTscale = length(allT_scale);
for j= 1:nTscale
    i = nTscale + 1 - j;
    % -- DEBUG
    vCount = size(vertices,2);
    eCount = size(edges,2);
%     fprintf(1,'vCount in input MAT file: %d\n',vCount);
%     fprintf(1,'eCount in input MAT file: %d\n',eCount);
    fprintf(1,'tScale: %f\n',allT_scale(i));
%     [distn, edgeTags] = getGoodBadOracle(edges, vertices, gtMatFileName, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, allT_scale(i));
%     [distn, edgeTags] = getNoisyGoodBadOracle(edges, vertices, gtMatFileName, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, allT_scale(i));
%     [distn, edgeTags] = getChi2GoodBadOracle(edges, vertices, gtMatFileName, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, allT_scale(i));
     [distn, edgeTags] = getGoodBadEdgesTimestamp(inputMatFileName, edges, vertices, gtMatFileName, gtMapAutPose, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, allT_scale(i)); %line Descriptor

    %  -- get the correct, incorrect and odom edge tags
    correctEdges = find(edgeTags == 1);
    odomEdges = find(edgeTags == 2);
    incorrectEdges = find(edgeTags == 0)';
    % -- Extract distances for correct and incorrect Edges
    ced = distn(correctEdges);
    ced = sort(ced);
    ied = distn(incorrectEdges);
    ied = sort(ied);
    meanlcDist = mean(distn(vCount:eCount));
    sdlcDist = sqrt(var(distn(vCount:eCount)));
    % ------------------------------------------------------------------------------
    % -- declare figure
    figure('name','spectralDistances');
    % -- plot the distance in specific color
    plot(ced,'color','blue');
    hold on;
    plot(ied,'color','red');
    % -- Set legend for plot
    legendInfo{1} = ['t = ',num2str(allT_scale(i)),' CorrectLC' ];
    legendInfo{2} = ['t = ',num2str(allT_scale(i)),' IncorrectLC' ];
    % -- show legend
    legend(legendInfo,'Location','southoutside');
    % -- Set title for the graph
    titleStr = ['spectralDistance for tScale ',num2str(allT_scale(i))];
    title(titleStr);
    xlabel('Loop closures');
    ylabel('Spectral Distance');
    % -- save graph
    % ---- set graph name

    [~,edgeFileNameBasis,~]=fileparts(inputMatFileName);
    lastDash = find(edgeFileNameBasis=='-');
    lastDash = lastDash(end);
    lastDash = lastDash - 1;
    saveGraphName = edgeFileNameBasis(1:lastDash);
    saveMapName = ['Distance-Map-',saveGraphName,'tScale-',num2str(allT_scale(i)),'.eps'];
    fprintf(1,'Save GraphName: %s\n',saveMapName);            % Debug line
    % ---- save the graph
    saveas(gcf,saveMapName,'epsc');
    
    % ------------------------------------------------------------------------------
    % -- debug EdgeTag
%     debugEdgeTagFileName = ['EdgeTag-',int2str(i)','.mat'];
    
    % -- get threshold for pruning
    %{
    bestThresh = max(ced);
    if (isempty(bestThresh))
        break;
    end
    bestThresh = bestThresh(1);
    %}
    % -- ADAPTIVE THRESHOLD
    %{
    if j == 1
        bestThresh = meanlcDist;
    elseif j == 2
        bestThresh = meanlcDist + 4 * sdlcDist;
    elseif j == 3 || j == 4 || j == 5 || j == 6
        bestThresh = meanlcDist + 2.5 * sdlcDist;
    else
        bestThresh = meanlcDist + 2.2 * sdlcDist;
    end
    %}
    
    % -- prune the edges
    bestThresh = meanlcDist + 1.6 * sdlcDist;
    edgesPruned = find(distn>bestThresh);
    % -- prune only the non-odometry edges
    edgesPruned = edgesPruned(find(edgesPruned>= vCount));
    edges(edgesPruned) = [];
    
    % -- calculate precision and Recall
    eCount = size(edges,2);
    save('outFile.mat','vertices', 'edges', 'eCount','vCount','dim');
    [precision, recall] = calculatePrecisionRecallwTimeStamp(gtMatFileName, inputMatFileName, 'outFile.mat', gtMapAutPose);
    fprintf(1,'Precision: %4f\n',precision);
    fprintf(1,'Recall: %4f\n',recall);
    
    % -- debug save
%     fprintf(1,'First edge is: ');
%     disp(edges(1));
%     if (edges(1).v1 ~= 1)
%         error('First edge deleted');
%     end
%     debugFileName = ['outFile-',int2str(i),'.mat'];
%     save(debugFileName,'edgeTags','vertices', 'edges', 'eCount','vCount','dim');
%     fMeasure(i) = harmmean([precision, recall]);
%     [maxfm, maxfmId] = max(fMeasure);
%     fprintf(1, 'i= %d\tMaxId: %d\n',i,maxfmId);
    if (precision >0.97 && recall>0.97)
        break;
    else
        if (recall > 0.98)
            break;
        end
    end
    % -- loop again
end

vCount = size(vertices,2);
eCount = size(edges,2);

%% save output Graph
outputmatFileName = [outputFileNameBasis,'.mat'];
outputg2oFileName = [outputFileNameBasis,'.g2o'];
% saveOutName = ['Final-Map-',saveGraphName,'.mat'];
% save(outputmatFileName,'vertices', 'edges', 'eCount','vCount', 'dim');
export2DTNFileG2o(vertices, edges, outputg2oFileName, [],[]);
% -- Debug
fprintf(1,'G2o file output: %s\n',outputg2oFileName);


close all;

% -- Debug
fprintf(1,'vCount: %d\n',vCount);
fprintf(1,'eCount: %d\n',eCount);
fprintf(1,'---------------------------------------------------------------------\n');
end
