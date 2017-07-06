function [distn, edgeTags] = getNoisyGoodBadOracle(edges, vertices, gtMatFileName, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, t_scale)

% -- get incidence matrix
% A  = getLineDescriptorIncidenceMatrix(edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, [], []);
A  = getNoisyOracleIncidenceMatrix( gtMatFileName, edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN);

% -- get some Laplacian matrix
Asp = sparse(A);
L = Asp*Asp';
L = full(L);

% -- eigen decomposition of the the matrices
[eigenVectors, eigenValues]=eig(L);
eigenValues=diag(eigenValues);
nEigenValues=length(eigenValues);

% -- as well some heat embedding
[ distn ] = distanceEmbedding( eigenVectors,eigenValues,nEigenValues, edges, t_scale, [] , vertices );

% -- get the good and bad edges notion
[ gtThreshold, ~, goodIdx ] =  getGTThresholdLCEdge(gtMatFileName);

% -- get the list of correct and incorrectEdges
edgeTags = checkEdgeTags(vertices, edges, gtThreshold, gtMatFileName);

end