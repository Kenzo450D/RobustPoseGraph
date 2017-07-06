function [ A ] = getLineDescriptorIncidenceMatrix( edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, initECount, edgeWeightMap)
%GETLINEDESCRIPTORINCIDENCEMATRIX Returns the incidence matrix of a semi weighted graph
%   Make sure the sorting is done properly as done in "readFile.m"
%   Input:
%       edges: struct(v1,v2,dx,d,dth,covMatrix)
%       vertices: struct(id, x, y, o)
%       O_EDGE_DIST_VARIANCE: variance for the mapping of odometry edge
%       O_EDGE_DIST_MEAN: mean of the mapping of the odometry edge
%       LC_EDGE_DIST_VARIANCE: variance for the mapping of lc edge
%       LC_EDGE_DIST_MEAN: mean of the mapping of lc edge
%       edgeWeightMap: weight of each edge (optional)
%   OUTPUT:
%       A: (n x m) matrix, incidence matrix of the vertices and edges
%   Note: This doesn't include the variance in code. It just considers
%   fixed weights

vCount = length(vertices);
eCount = length(edges);
A = zeros(vCount, eCount);
debugSt = 0;

%% Distance Mapping
if isempty(edgeWeightMap)
%     fprintf('\n\nCALCULATING weights in "GetIncidenceMatrix"\n\n');
    distEdges = zeros(1,eCount);
    % Now to separately calculate mean and var of distEdges for loop closures
    % and odometry edges and make the mapping
    % -- Odometry Edges
    oDistEdges     = distEdges(1:(vCount-1)); %odometry edges
    mapODistEdges  = ones(size(oDistEdges));
    mapODistEdges  = mapODistEdges * O_EDGE_DIST_MEAN;
    
    % -- All Edge Weights
    edgeWeights = getLineDescriptorWeights(vertices, edges,debugSt);
    
    % -- Debug
    if (debugSt == 1)
        dbg_odomEdgeWeight = edgeWeights(1:(vCount -1));
        dbg_origLCEdgeWeight = edgeWeights(vCount : initECount);
        dbg_synLCEdgeWeight  = edgeWeights((initECount + 1): eCount);
        dbg_meanOEW = nanmean(dbg_odomEdgeWeight);
        dbg_meanOLC = nanmean(dbg_origLCEdgeWeight);
        dbg_meanSLC = nanmean(dbg_synLCEdgeWeight);
        fprintf(1,'Mean of Odometry: %f\n',dbg_meanOEW);
        fprintf(1,'Mean of Original Loop Closures:  %f\n', dbg_meanOLC);
        fprintf(1,'Mean of Synthetic Loop Closures: %f\n',dbg_meanSLC);
        dbg_medOEW = nanmedian(dbg_odomEdgeWeight);
        dbg_medOLC = nanmedian(dbg_origLCEdgeWeight);
        dbg_medSLC = nanmedian(dbg_synLCEdgeWeight);
        fprintf(1,'Median of Odometry: %f\n',dbg_medOEW);
        fprintf(1,'Median of Original Loop Closures:  %f\n', dbg_medOLC);
        fprintf(1,'Median of Synthetic Loop Closures: %f\n',dbg_medSLC);
    end
    
    % -- Find the edge mean and set edge weights
    ewMedian = nanmedian(edgeWeights);              %ew = edgeWeight
%     ewVar    = nanvar(edgeWeights);
    % ---- Calculate the variance of the first 98% of the edges, so as to 
    %not accomodate noise
    edgeWeightsSorted = sort(edgeWeights);
    edgeWeightsSortedPart = edgeWeightsSorted(1:0.98*size(edgeWeights,1));
    ewVar  = nanvar(edgeWeightsSortedPart);
    ewsd   = sqrt(ewVar);
    thresh = ewMedian + 3*ewsd;
    % we consider anything above 3x sd to be noise
    badEdge = find(edgeWeights > thresh);
    badlcEdge  = badEdge(badEdge > (vCount - 1));
    goodEdge = find(edgeWeights < (ewMedian - ewsd));
    goodlcEdge = goodEdge(goodEdge >= vCount);
    % rather than keeping fixed edge weights, we would vary them from 0.8 to 0.2
    % based on their value. 
    %% Add Weights between limits
    upthresh = ewMedian + 4*ewsd;
    nlcEdges = edgeWeights(vCount:end);
    %nlc : normal loop closure edges (Don't remember why 'normal')
    nanNlcEdges = isnan(nlcEdges);
    nlcEdges(nanNlcEdges) = ewMedian;
    nlcEdgeWeights = (nlcEdges / upthresh); %higher value ~ poor weight
    % ---- calculate which edgeWeights is more than one, make it one
    nlcEdgeWeightExceed = nlcEdgeWeights > 1;
    nlcEdgeWeights(nlcEdgeWeightExceed) = 1;
    % -- more weight if lower value of difference
    nlcEdgeWeights = 1 - nlcEdgeWeights;
    nlcDistEdges = nlcEdgeWeights*OLC_EDGE_DIST_MEAN;
    % -- fix lower limit
    nlcDistEdgeExceed = nlcDistEdges < LC_EDGE_DIST_MEAN;
    nlcDistEdges(nlcDistEdgeExceed) = LC_EDGE_DIST_MEAN;
    
%     nlcDistEdges = (1 - (nlcEdges / upthresh )) * OLC_EDGE_DIST_MEAN;
%     ndNlcDistEdges = nlcDistEdges > OLC_EDGE_DIST_MEAN;
%     nlcDistEdges(ndNlcDistEdges) = OLC_EDGE_DIST_MEAN;
    mapDistEdges   = [mapODistEdges, nlcDistEdges'];
    mapDistEdges(badlcEdge) =  1 * LC_EDGE_DIST_MEAN;
    mapDistEdges(goodlcEdge) = 1 * OLC_EDGE_DIST_MEAN;
    
    % -- Debug
    if (debugSt == 1)
        % -- Debug outputs
        % Calculate number of orig loop closures are considered < 0.8
        origLCWeights = mapDistEdges((vCount - 1):initECount);
        synLCWeights = mapDistEdges((initECount + 1):eCount);
        origLCWeightslt = find(origLCWeights < OLC_EDGE_DIST_MEAN);
        origLCWeightslt_weights = origLCWeights(origLCWeightslt);
        for i = 1:length(origLCWeightslt)
            fprintf(1,'Idx: %d\tWeight: %f\n',origLCWeightslt(i),origLCWeightslt_weights(i));
        end
        fprintf(1,'Share of # of original edges with weights less than %d : %f\n',...
            OLC_EDGE_DIST_MEAN,(length(origLCWeightslt)/length(origLCWeights)));
        synLCWeightslt = find(synLCWeights < OLC_EDGE_DIST_MEAN);
        synLCWeightslt_weights = synLCWeights(synLCWeightslt);
        for i = 1:length(synLCWeightslt)
            fprintf(1,'Idx: %d\tWeight: %f\n',synLCWeightslt(i),synLCWeightslt_weights(i));
        end
        fprintf(1,'Share of # of synthetic edges with weights less than %d : %f\n',...
            OLC_EDGE_DIST_MEAN,(length(synLCWeightslt)/length(synLCWeights)));
        % -- Debug plot
        figure();
        plot(mapDistEdges);
        figure('name','Plot edge Weights sorted');
        origLCWeightsSorted = sort(origLCWeights);
        synLCWeightsSorted  = sort(synLCWeights);
        plot(origLCWeightsSorted,'blue'); hold on;
        plot(synLCWeightsSorted,'red');
        legend('original LC','synthetic LC');
    end
    %pause(3);
else
%     fprintf('\n\nCOPYING weights in "GetIncidenceMatrix"\n\n');
    mapDistEdges = edgeWeightMap;
end

% -- concatenate the distance maps

% fprintf('Check for correctness:: \ntotal edges:%d\nlength(mapDistEdges):%d\n',eCount,length(mapDistEdges));
% -- Construct Adjacency Matrix
for i = 1:eCount
    A(edges(i).v1, i) = -mapDistEdges(i);
    A(edges(i).v2, i) = mapDistEdges(i);
end


end

