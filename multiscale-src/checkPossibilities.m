function checkPossibilities(inputFilesCreated, edgeTagFile, outputPdfName, gtMatFile) 
%CHECKPOSSIBILITIES Check the possibilities of the graph laplacian and heat
%embedding in graph slam.

% -- check if using the iterative measure makes sense, prune at every iteration
%    update the edges and recalculate the incidence matrix, make the laplacian
%    and heat embedding.

%% Initialize

O_EDGE_DIST_MEAN = 0.92;
OLC_EDGE_DIST_MEAN = 0.8;
LC_EDGE_DIST_MEAN = 0.2;
% -- Read input Directory
idx       = find(inputFilesCreated == '/');
idx       = idx(end);
inputDir = inputFilesCreated(1:idx);

% -- check if edgeTagFile exists
if (exist(edgeTagFile,'file') == 2)
    load(edgeTagFile);
    % -- edgeTags is loaded from edgeTagFile
    correctEdges = find(edgeTags == 1);
    odomEdges = find(edgeTags == 2);
    incorrectEdges = find(edgeTags == 0)';
else
    fprintf(1,'Error: EdgeTagFile not found!\nEdgeTagFile: %s\n',edgeTagFile);
end

% -- check the groundTruth threshold
[ gtThreshold, ~, goodIdx ] =  getGTThresholdLCEdge(gtMatFileName);

%% Read the files
inFile  = fopen(inputFilesCreated,'r');
tline   = fgetl(inFile);
allT_scale = [0.01,0.1,1,10,100];
nTscale = length(allT_scale);
clr = jet(nTscale);
i= 1;
lw = 4; %lineWidth
fnIdx = 1;
fileNames = cell(nTscale,1);
while ischar(tline)
    fName = [inputDir,tline];               %fileName to load
    fprintf(1,'FileName: %s\n',fName);      % for debug
    fileNames{fnIdx,1} = fName;
    fnIdx = fnIdx + 1;
    % -- loop 
    tline = fgetl(inFile);
    i = i+1;
end

iterCount = 1;
while (true)

    if (iterCount == 1)
    % -- load the file with the highest scale
        load(char(fileNames{nTscale}));
    else
        % ---- make the incidence matrix
        A = getLineDescriptorIncidenceMatrix( edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, [], []);
        % ---- make the laplacian matrix
        Asp = sparse(A);
        L = Asp*Asp';
        L = full(L);
        % ---- svd
        [eigenVectors, eigenValues]=eig(L);
        eigenValues=diag(eigenValues);
        nEigenValues=length(eigenValues);
        % ---- calculate the threshold
        spectralDistn = distanceEmbedding(eigenVectors,eigenValues,nEigenValues, edges,t_scale(i),outputg2oFileName, vertices);
        % ---- find which edges are good or bad
        [correctLcIdx, incorrectLcIdx] = checkLCinitFile(initMatFileName, threshold, gtMatFileName);
        
    end
    %% plot distance
    % -- Debug
    fprintf('length(distn): %d\t#EdgeTags: %d\n',length(distn),length(edgeTags));

    % -- Extract distances for correct and incorrect Edges
    ced = distn(correctEdges);
    ced = sort(ced);
    ied = distn(incorrectEdges);
    ied = sort(ied);

    bestThesh = max(ced);
    bestThesh = bestThesh(1);

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
    titleStr = ['spectralDistance for tScale ',num2str(t_scale)];
    title(titleStr);
    % -- save graph
    % ---- set graph name
    [~,edgeFileNameBasis,~]=fileparts(edgeTagFile);
    lastDash = find(edgeFileNameBasis=='-');
    lastDash = lastDash(end);
    lastDash = lastDash - 1;
    saveGraphName = edgeFileNameBasis(1:lastDash);
    xlabel('Loop closures');
    ylabel('Spectral Distance');
    saveMapName = ['Distance-Map-',saveGraphName,'tScale-',num2str(t_scale),'.eps'];
    fprintf(1,'Save GraphName: %s\n',saveMapName);            % Debug line
    % ---- save the graph
    saveas(gcf,saveMapName,'epsc');
    % ------------------------------------------------------------------------------

    %% prune the graph
    [ced,cedIdx] = distn(correctEdges);
    [ied, iedIdx] = distn(incorrectEdges);
    edgesPruned = find(distn  bestThesh);
    edges(edgesPruned) = [];

end


fclose(inFile);
close all;


end
