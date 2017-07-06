function export2DTNFileG2o(vertices, edges, fileName, zeroVertexMat, zeroEdgeMat)
%EXPORT2DTNFILEG2O Exports a given set of 2D vertices and edges as a g2o file.
% -------------------------------------------------------------------------
% Input:
%   vertices: List of vertices
%   edges: list of edges
%   fileName: file Name to save it as
%   Code would give synthetic data to the edges that do not have added data
% -------------------------------------------------------------------------
% Author: Sayantan Datta < sayantan dot datta at research dot iiit dot ac 
%                          dot in>
% 
% Robotics Research Center
% International Institute of Information Technology, Hyderabad
% -------------------------------------------------------------------------

%% Generate Synthetic Data
vCount = length(vertices);
edges  = add2DSynEdgeTranfNoise(vertices, edges, vCount);
eCount = length(edges);

%% load zero files

if (ischar(zeroVertexMat)) % -- if fileNames are a input
    load(zeroVertexMat);
    load(zeroEdgeMat);
else % -- if zeroData are a input
    zeroVertex=zeroVertexMat;
    zeroEdge=zeroEdgeMat;
end
% disp(zeroEdge);
% disp(zeroVertex);

emptyZeroV = 1; % if 0, then we have empty zeroVertex

%% convert zeroVertices to struct of vertices
if ~isempty(zeroVertex)
    emptyZeroV = 0;
    verticesZero(1).id = zeroVertex(1);
    verticesZero(1).x  = zeroVertex(2);
    verticesZero(1).y  = zeroVertex(3);
    verticesZero(1).o  = zeroVertex(4);
    for i = 1:vCount
        verticesZero(i+1) = vertices(i);
    end
    vertices = verticesZero;
end

%% convert zeroEdge to struct of Edges
if ~isempty(zeroEdge)
    lEdges = size(zeroEdge,2);
    for i = 1:lEdges
        edgesZero(i).v1=zeroEdge(1,i);
        edgesZero(i).v2=zeroEdge(2,i);
        edgesZero(i).dx=zeroEdge(3,i);
        edgesZero(i).dy=zeroEdge(4,i);
        edgesZero(i).dth=zeroEdge(5,i);
        %fill Covariance Matrix
        covMatrix = zeros(3);
        covMatrix(1,1)=zeroEdge(6,i);
        covMatrix(1,2)=zeroEdge(7,i);
        covMatrix(2,1)=zeroEdge(7,i);
        covMatrix(1,3)=zeroEdge(8,i);
        covMatrix(3,1)=zeroEdge(8,i);
        covMatrix(2,2)=zeroEdge(9,i);
        covMatrix(2,3)=zeroEdge(10,i);
        covMatrix(3,2)=zeroEdge(10,i);
        covMatrix(3,3)=zeroEdge(11,i);
        edgesZero(i).covMatrix = covMatrix;
    end
    
    for i = 1:eCount
        edgesZero(i+lEdges) = edges(i);
    end
    edges = edgesZero;
end

%% init file
fileID = fopen(fileName,'w');

%% Add Vertices to File
for i = 1:length(vertices)
    if (emptyZeroV == 0)
        fprintf(fileID, 'VERTEX_SE2 %d %f %f %f\n', vertices(i).id, vertices(i).x, vertices(i).y, vertices(i).o);
    else
        fprintf(fileID, 'VERTEX_SE2 %d %f %f %f\n', (vertices(i).id -1), vertices(i).x, vertices(i).y, vertices(i).o);
    end
end

%% Add Edges to File
for i= 1:length(edges)
    if (emptyZeroV == 0)
        fprintf(fileID, 'EDGE_SE2 %d %d ', edges(i).v1, edges(i).v2);
    else
        fprintf(fileID, 'EDGE_SE2 %d %d ', (edges(i).v1-1), (edges(i).v2 -1));
    end
    fprintf(fileID, '%f %f %f ', edges(i).dx, edges(i).dy, edges(i).dth);
    fprintf(fileID, '%f %f %f %f %f %f', edges(i).covMatrix(1,1), edges(i).covMatrix(1,2), edges(i).covMatrix(1,3), edges(i).covMatrix(2,2), edges(i).covMatrix(2,3), edges(i).covMatrix(3,3));
    fprintf(fileID, '\n');
end

status = fclose(fileID);
end