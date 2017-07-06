function [distn, edgeTags] = getGoodBadEdges(inputMatFileName, edges, vertices, gtMatFileName, gtMapAutPose, O_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, t_scale)

% -- get incidence matrix
tic;
A  = getLineDescriptorIncidenceMatrix(edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, [], []);
fprintf('Time taken for Line Descriptor Incidence Matrix: ');
toc;
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
%% get Threshold from ground Truth
[avgOdomDist] = getAverageOdometryDistance(inputMatFileName);
gtThreshold = avgOdomDist * 20;

% -- get the list of correct and incorrectEdges
% edgeTags = checkEdgeTags(vertices, edges, gtThreshold, gtMatFileName);
edgeTags = checkEdgeTagswTimestamp(vertices, edges, gtThreshold, gtMatFileName, gtMapAutPose);

end
