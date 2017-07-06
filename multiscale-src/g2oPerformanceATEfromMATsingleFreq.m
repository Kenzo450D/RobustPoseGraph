function [ate] = g2oPerformanceATEfromMATsingleFreq(GTFileName,AUTFileName)
%G2OPERFORMANCEAUT Calculates RPE and ATE error of the AUT
%   AUT : Algorithm Under Testing
%   GT  : Ground Truth
%   ATE : Absolute Trajectory Error
%-------------------------------------------------------------------------------
%   Input:
%       GTFileName: .mat file containing vertices, edges, vCount, eCount
%       AUTFileName: .mat file containing vertices, edges, vCount, eCount
%-------------------------------------------------------------------------------
%   Output:
%       ATE  - Absolute Translation Error
%       absolute positions are used in g2o, I have changed the code.
%   Documentation on Absolute Trajectory Error can be found at:
%       http://www.rawseeds.org/rs/methods/view/9
%   Sample Input:
%       g2oPerformanceAUT('veintelGT.mat', 'veintel-AUT-lc300-tScale-200.mat');
%   Sample Output:
%       3.8978
%   Error Codes:
%       If the number of vertices in each doesn't match:
%           It is forced to be the same, consider the first number of
%           gtvertices in the autVertices
%-------------------------------------------------------------------------------
% Author:
%   Sayantan Datta <sayantan dot datta at research dot iiit dot ac dot in>
%   Siddharth Tourani <tourani dot siddharth at gmail dot com>
% Robotics Research Center
% International Institute of Information Technology, Hyderabad
%-------------------------------------------------------------------------------

% -- Read files and create vertices
% ---- Ground Truth File
load(GTFileName);
gtvCount              = vCount;

% fprintf(1,'Vertex count for GroundTruth: %d\n', gtvCount);

gtVertices            = vertices;

% ---- Algorithm Under Testing File
load(AUTFileName);
autvCount             = vCount;

% fprintf(1,'Vertex count for test: %d\n', autvCount);

autVertices           = vertices;


% % -- change pose Count
% [autVertices] = changePoseCount(autVertices, freqDiff);
% autvCount     = size(autVertices,2);

% fprintf(1,'Vertex count after reduction: %d',autvCount);

% -- Relative Pose Error

% ---- Check vCounts if equal
if (autvCount ~= gtvCount)
    % ---- consider only the first gtvCount
    idx = gtvCount + 1;
    for i = gtvCount+1 : autvCount
        autVertices(idx) = [];
    end
end

vertexId = 1:autvCount;                   %

%% ALIGN FIRST TWO POSES OF TRAJECTORY
[autVertices] = alignVertices(autVertices, gtVertices);

%% COMPUTING ABSOLUTE TRAJECTORY ERROR
% -- Initialization
vtxe = zeros(gtvCount,1);
% -- Calculate Absolute Translation Error
for i = 1:gtvCount
   % -- Find pose x and y
   vgtx = gtVertices(i).x;
   vgty = gtVertices(i).y;
%
   vautx = autVertices(i).x;
   vauty = autVertices(i).y;
   % -- Euclidean Difference between poses
   difn = sqrt((vgtx - vautx)^2 + (vgty - vauty)^2);
   vtxe(i,1) = difn;
end
ate = sum(vtxe)/gtvCount;
% fprintf(1,'Input File Name: %s\n', AUTFileName);
% fprintf(1,'ATE: %f\n',ate);
%%  END
end

