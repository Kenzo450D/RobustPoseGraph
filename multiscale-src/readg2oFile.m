function[vertices,vCount,edges,eCount, zeroVertex, zeroEdge, dim] =  readg2oFile(g2oFileName, filesCreated, saveFileFlag)
%READFILEG2O reads a g2o file into constituent vertices, edges, eCount,
%vCount.
% -------------------------------------------------------------------------
%   Input:
%       g2oFileName : fileName of the g2o file
%       filesCreated : fileName to store the files Created if any
%       saveFileFlag : (1/0)
%           1 - save (vCount, eCount, vertices, edges, zeroVertex, zeroEdge, dim)
%           0 - do not save files
% -------------------------------------------------------------------------
%   Output:
%       vertices  : set of vertices
%       vCount    : number of vertices
%       edges     : set of edges
%       eCount    : number of edges
%       zeroVertex: Vertex having id as zero
%       zeroEdge  : Edges with the zero vertex
%       dim       : dimension of the g2o file
% -------------------------------------------------------------------------
% Author: Sayantan Datta < sayantan dot datta at research dot iiit dot ac
%                          dot in>
%
% Robotics Research Center
% International Institute of Information Technology, Hyderabad
% -------------------------------------------------------------------------

% close all;
% clear all;
% clc;
% g2oFileName='intel.g2o';
% g2oFileName='manhattanOlson3500.g2o';
% g2oFileName='parking-garage.g2o';
% filesCreated='filesCreated.txt';
% saveFileFlag=0;
% outFile='ve-intel.mat';
% vZeroFile='intelzeroVertex.mat';
% eZeroFile='intelzeroEdge.mat';

%% Initialization

% t = cputime;
% -- set output file Names
idx=find(g2oFileName == '.');
idx=idx(end);
idx=idx-1;
fileNameBasis=g2oFileName(1:idx);
outFile=sprintf('%s.mat',fileNameBasis);

% -- get dimensionality of g2o file
masterFileData=fopen(g2oFileName,'r');
tline = fgetl(masterFileData);
while ischar(tline)
    elems=strsplit(tline, ' ');
    elem1=char(elems(1));
    if ( strcmp(elem1,'VERTEX_SE2') )
        dim=2;
        break;
    elseif (strcmp(elem1,'VERTEX_SE3:QUAT'))
        dim=3;
        break;
    elseif (strcmp(elem1,'EDGE_SE2'))
        dim=2;
        break;
    elseif (strcmp(elem1,'EDGE_SE3:QUAT'))
        dim=3;
        break;
    end
    tline = fgetl(masterFileData);
end
fclose(masterFileData);

%% Read the g2o file

% -- Make system call to cpp code to split file into Vertices and Edges
% ---- Initialize file Names
vFileName = strcat(fileNameBasis,'Vertices.txt');
eFileName = strcat(fileNameBasis,'Edges.txt');
% ---- Make system call
command=['./separateG2O.o',' ',g2oFileName];
% disp(command);
system(command);
% ---- Fix edge file (for input from SC)
% command=['./fix2DSCEdgeFile.o',' ',eFileName];
% system(command);
% ---- New eFileName
% eFileName = strcat(fileNameBasis,'EdgesFixed.txt');

% -- Read the vertex and the edge file
if dim == 2
    % ---- Read vertex File
    origVertexFile = fopen(vFileName,'r');
    formatSpec='%d %f %f %f';
    [vData,vCount] = fscanf(origVertexFile, formatSpec);
    vCount = vCount / 4; %as there are 4 data in each line
    vData = reshape(vData,4,vCount);
    % ---- Read edge File
    origEdgeFile    = fopen(eFileName,'r');
    formatSpec      ='%d %d %f %f %f %f %f %f %f %f %f ';
    %                  1  2  3  4  5  6  7  8  9 10 11
    [eData, eCount] = fscanf(origEdgeFile, formatSpec);
    eCount          = eCount / 11;
    eData           = reshape(eData,11,eCount);
    fclose(origVertexFile);
    fclose(origEdgeFile);
else    %dim = 3
    % ---- Read vertex file
    origVertexFile = fopen(vFileName,'r');
    formatSpec='%d %f %f %f %f %f %f %f';
    [vData,vCount] = fscanf(origVertexFile, formatSpec);
    vCount = vCount / 8; %as there are 8 data in each line
    vData = reshape(vData,8,vCount);
    % ---- Read edge file
    origEdgeFile = fopen(eFileName,'r');
    formatSpec='%d %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
    %            1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
    [eData, eCount] = fscanf(origEdgeFile, formatSpec);
    eCount = eCount / 30;
    eData = reshape(eData,30,eCount);
    fclose(origVertexFile);
    fclose(origEdgeFile);
end

%% Handle Vertices
% -- rather than removing the first vertex, we increment each vertex id by 1
% ---- increment the vertexId in vData

% check whats the minimum vertexId, if it's 0, then increment, else, let it be
minId = min(vData(1,:));
if (minId == 0)
    vData(1,:) = vData(1,:) + 1;
end


% -- sort the data
[tmp,idx] = sort(vData(1,:));
vData = vData(:,idx);

% -- convert vData to structure
if (dim == 2)
%     fprintf(1,'Size of vData:');
%     disp(size(vData));
    for i = 1:vCount
        vertices(i).id=vData(1,i);
        vertices(i).x=vData(2,i);
        vertices(i).y=vData(3,i);
        vertices(i).o=vData(4,i);
    end
elseif (dim == 3)
%     fprintf(1,'Size of vData: ');
%     disp(size(vData));
    for i = 1:vCount
        vertices(i).id=vData(1,i);
        vertices(i).x=vData(2,i);
        vertices(i).y=vData(3,i);
        vertices(i).z=vData(4,i);
        ornt = vData(5:8,i);
        vertices(i).o = ornt;
    end
end

%% Handle Edges
% -- increment the vertexId in eData
if (minId == 0)
    eData(1,:) = eData(1,:) + 1;
    eData(2,:) = eData(2,:) + 1;
end
% -- sort the edge data

% ---- group the odometry edges
[eData,lcEdges] = groupOdometryEdge(eData);
[tmp,idx]       = sort(eData(1,:));
eData           = eData(:,idx);
[tmp,idx]       = sort(lcEdges(1,:));
lcEdges         = lcEdges(:,idx);

% ---- join the loop closures and edge data together
eData = [eData,lcEdges];

% ---- convert eData to structure
if (dim == 2)
    for i = 1:eCount
        edges(i).v1   = eData(1,i);
        edges(i).v2   = eData(2,i);
        edges(i).dx   = eData(3,i);
        edges(i).dy   = eData(4,i);
        edges(i).dth  = eData(5,i);
        %fill Covariance Matrix
        covMatrix          = zeros(3);
        covMatrix(1,1)     = eData(6,i);
        covMatrix(1,2)     = eData(7,i);
        covMatrix(2,1)     = eData(7,i);
        covMatrix(1,3)     = eData(8,i);
        covMatrix(3,1)     = eData(8,i);
        covMatrix(2,2)     = eData(9,i);
        covMatrix(2,3)     = eData(10,i);
        covMatrix(3,2)     = eData(10,i);
        covMatrix(3,3)     = eData(11,i);
        edges(i).covMatrix = covMatrix;
    end
elseif (dim == 3)
    for i = 1:eCount
        edges(i).v1=eData(1,i);
        edges(i).v2=eData(2,i);
        edges(i).dx=eData(3,i);
        edges(i).dy=eData(4,i);
        edges(i).dz=eData(5,i);
        edges(i).dth=eData(6:9,i);
        covMatrix = make6x6CovMatrix(eData(10:30,i));
        edges(i).covMatrix = covMatrix;
    end
end

%%  save data of vertices, edges in mat file

if (saveFileFlag == 1)
    save(outFile,'vertices','vCount','edges','eCount', 'dim');
end


%% add files to filesAdded file

if (saveFileFlag > 0 && ~isempty(filesCreated))
    fc=fopen(filesCreated,'at');
    fprintf(fc,'%s\n',outFile);
    fprintf(fc,'%s\n%s\n',vFileName, eFileName);
    fclose(fc);
end

% e = cputime - t;
% fprintf('Time Taken: %f\n',e);
end
