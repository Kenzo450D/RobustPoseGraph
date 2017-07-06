function mainCodeFnWeights( inputFileNameBasis, t_scale, outputFileNameBasis, testFlag, gtFile, prFileName,O_EDGE_DIST_MEAN,LC_EDGE_DIST_MEAN,OLC_EDGE_DIST_MEAN)

% MAINCODEFNWP One shot algorithm to read a g2o corrupted with noise, and use 
% spectral heat embedding to prune the outlier edges
% ------------------------------------------------------------------------------
% Input:
%   inputFileName: input of corrupted g2o mat file containing:
%       vertices
%       edges
%       vCount
%       eCount
%       zeroEdge
%       zeroVertex
%   testFlag: 1: Do testing, 0: Skip Testing
%       1: Require:
%           matFile of gtFile (ground truth MAT file)
%       0: skip the rest
%   outputFileNameBasis: output fileName without extension.
%       The .g2o and .mat files would be made from this string.
%   gtFile: Ground truth .mat file for testing
%   prFileName: fileName to save precision and recall
% ------------------------------------------------------------------------------
% Output:
%   Only as file outputs
% ------------------------------------------------------------------------------
% Author: Sayantan Datta < sayantan dot datta at research dot iiit dot ac
%                          dot in>
%
% Robotics Research Center
% International Institute of Information Technology, Hyderabad
% ------------------------------------------------------------------------------



%% Initialization

% -- Fix up input file names
inputFileName = [inputFileNameBasis,'.mat'];
inputG2oFileName = [inputFileNameBasis,'.g2o'];

% -- Print parameters
% fprintf('Input File Name     : %s\n',inputFileName);
% fprintf('t_scale             : %d\n',t_scale);
% fprintf('Out File Name       : %s\n',outputFileName);

% -- get initial edgeCount
load(gtFile);
initECount = eCount;
initEdges  = edges;

% -- Distance Mapping Parameters
% O_EDGE_DIST_VARIANCE = 0.05;
% LC_EDGE_DIST_VARIANCE = 0.05;
O_EDGE_DIST_MEAN = 0.92;
LC_EDGE_DIST_MEAN = 0.2;
OLC_EDGE_DIST_MEAN = 0.4;

% -- Read the mat file
load(inputFileName);
% fprintf('Data contains: %d vertices & %d Edges\n',vCount,eCount);

% -- Set output file names
outputMATFileName = strcat(outputFileNameBasis, '.mat');
outputg2oFileName = strcat(outputFileNameBasis, '.g2o');

% -- To plot the graph
% plot_graph(vertices,edges, [],'k',0); % Plot only the graph 


%% Identify LC & Plot
% -- DEBUG :: Generates a list of edge indexes which are not odometry edges
% lcEdgeList = identifyLC(edges);
% fprintf('Identified Loop Closures: %d\n',(length((lcEdgeList)')));

% plot_graph(vertices,edges, lcEdgeList,'g',0);
% pause;

%% Heat embedding

% -- Incidence Matrix with weights
A            = getIncidenceMatrixFromDCS(inputFileNameBasis, O_EDGE_DIST_MEAN, ...
               LC_EDGE_DIST_MEAN, vCount, []);
% A            = getIncidenceMatrix(edges, vertices, O_EDGE_DIST_MEAN, ...
%                LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, initECount, []);

% -- Laplacian Matrix
L            = A*A';

% --  Euclidean distance in spectral embedding
dist         = heatEmbedding(L,edges,t_scale);

% -- Threshold using just odometry edge
% distOdom     = dist(1:(vCount - 1));
% mean_dist    = mean(distOdom);
% var_dist     = std(distOdom);
% threshold    = mean_dist+6*var_dist;

% -- Threshold using all of the edges
 mean_dist    = mean(dist);
 var_dist     = std(dist);
 threshold    = mean_dist+0.5*var_dist;

% -- Identifying bad loop closures
temp         = find(dist>threshold);
bad_LC_index = temp(find(temp>vCount));

% -- DEBUG :: Plot the graph identifying the bad edges
% plot_graph(vertices,edges,bad_LC_index,'k',1);

%% Output and Testing

% -- Output as G2O file
prunedEdges = pruneEdges(edges, bad_LC_index);
badEdges = edges(bad_LC_index);
edges=prunedEdges;
save(outputMATFileName, 'vertices','edges','eCount','vCount','zeroVertex', ...
    'zeroEdge');
export2DTNFileG2o(vertices, prunedEdges, outputg2oFileName, zeroVertex, ...
                  zeroEdge);

% -- testing and performance of output
if ( testFlag == 1)
    const = 2;
    [precisionAllLC, recallAllLC, precisionOrgLC, recallOrgLC, precisionSynLC, ...
    recallSynLC] = calculatePerformance(inputFileName, gtFile, bad_LC_index, const);
    % -- output data to prFile
    prFile = fopen(prFileName,'at');
    fprintf(prFile,'%s\n',outputg2oFileName);
    fprintf(prFile,'Precision allLC: %f\n',precisionAllLC);
    fprintf(prFile,'Recall allLC %f\n',recallAllLC);
    fprintf(prFile,'Precision orgLC %f\n',precisionOrgLC);
    fprintf(prFile,'Recall orgLC %f\n',recallOrgLC);
    fprintf(prFile,'Precision synLC %f\n',precisionSynLC);
    fprintf(prFile,'Recall synLC %f\n',recallSynLC);
    fclose(prFile);
end

%% plot distance
% lcDistFileName = sprintf('Intel-Dist-lc%d-K%d.fig',extra_edges,t_scale);
% figure,plot(dist);
% savefig(lcDistFileName);

end

