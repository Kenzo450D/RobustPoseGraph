function [ edges ] = add2DSynEdgeTranfNoise( vertices, edges, vCount )
%ADD2DSYNEDGETRANFNOISE Adds synthetic dx, dy, dth, covMatrix to edges not
%having them. Adds the data as the transformation between those two vertices
%plus a slight noise.
% ------------------------------------------------------------------------------
% Input:
%   vertices: structure containing vertices of the graph, x, y, th
%   edges: structure containing edges of the graph, v1, v2, dx, dy, dth, covMatrix
%   vCount: number of vertices in the graph
% ------------------------------------------------------------------------------
% Output:
%   edges: edges with added synthetic data
% ------------------------------------------------------------------------------
% Documentation:
%   Takes a mean and variance of the other loop closures and adds them
%   to the edges not having dx, dy, dth, covMatrix.
%   Follows the Constraint that covMatrix is symmetric
% ------------------------------------------------------------------------------
% Author: Sayantan Datta < sayantan dot datta at research dot iiit dot ac 
%                          dot in>
% 
% Robotics Research Center
% International Institute of Information Technology, Hyderabad
% ------------------------------------------------------------------------------

eCount = length(edges);
% find the first synthetic edge
fIdx = eCount;
flag = 0;
% disp(edges(1));
for i = 1:eCount
    if (isempty(edges(i).dx))
        flag = 1;
        fIdx = i;
        break;
    end
end
% if there needs no synthetic data to be added, we return
if flag == 0
    fprintf('No changes made!\n');
    return
end

% Generate synthetic data
% Steps:
% a.1 Declare Storage to store transformation matrices
% a.2 Make transformation matrix for all the poses in the graph
% a.3 Make relative transformation for the loop closure edges
% a.4. Add noise to these relative transformations, and save them as dx, dy and dth

% -- a.1 Declare Storage to store transformation matrices

vTr=zeros(3,3,vCount);
initT = eye(3);

% -- a.2 Make transformation matrix for all the poses
for i = 1:vCount
    % ---- read pose
    pose.x=vertices(i).x;
    pose.y=vertices(i).y;
    pose.th=wrapToPi(vertices(i).o);
    % ---- convert pose to transformation matrix
    tPose=convert2TransformationMatrix_SO2(pose);
    % ---- update tranformation wrt prev. tranformation
    initT = initT * tPose;
    % ---- store the transformation matrix
    vTr(:,:,i) = initT;
%     disp(vTr(:,:,i));
end
% fprintf('\nsize(vTr):');
% disp(size(vTr));


% add synthetic data
% Steps:
% 1. Declare storage
% 2. Populate Storage
% 3. Create Mean and s.d. of all edges after vCount
% 4. Add random data within 2 sd of mean. (Ref:
% https://en.wikipedia.org/wiki/68–95–99.7_rule)

% -- 1. Declare storage
count = fIdx - vCount;
dX = zeros(count,1);
dY = zeros(count,1);
dTh = zeros(count,1);
cm = zeros(count, 6);

% -- 2. Populate Storage
idx = 1;
for i = vCount : (vCount + count - 1);
    dX(idx) = edges(i).dx;
    dY(idx) = edges(i).dy;
    dTh(idx) = edges(i).dth;
    cm(idx, 1) = edges(i).covMatrix(1,1);
    cm(idx, 2) = edges(i).covMatrix(1,2);
    cm(idx, 3) = edges(i).covMatrix(1,3);
    cm(idx, 4) = edges(i).covMatrix(2,2);
    cm(idx, 5) = edges(i).covMatrix(2,3);
    cm(idx, 6) = edges(i).covMatrix(3,3);
    idx = idx + 1;
end

% -- 3. Create Mean and s.d. of all edges after vCount
mdX = mean(dX);
mdY = mean(dY);
mdTh = mean(dTh);
mcm = mean(cm);

vdX = var(dX).^0.5;
vdY = var(dY).^0.5;
vdTh = var(dTh).^0.5;
vcm = var(cm).^0.5;

% -- a.3 Make relative transformation for loop closure edges
for i = fIdx : eCount
    % -- Old implementation
     rdX = ((rand - 0.5)*2)*(2*vdX) + mdX;
     rdY = ((rand - 0.5)*2)*(2*vdY) + mdY;
     rdTh = ((rand - 0.5)*2)*(2*vdTh) + mdTh;
     rcm = ((rand(1,6) - 0.5)*2);
     rcm = rcm.*(2*vcm);
     rcm = rcm + mcm;
%      fprintf('Old values which were added: %f %f %f\n', rdX, rdY, rdTh);
    % -- calculate relative transformation
    ev1 = edges(i).v1;
    ev2 = edges(i).v2;
    if (ev1 > vCount || ev2 > vCount)
        fprintf('vCount: %d ev1 %d ev2 %d\n',vCount, ev1, ev2);
        fprintf('edge vertex index greater than vCount');
    end
%     fprintf('size of vTr(:,:,ev1): ');
%     disp(size(vTr(:,:,ev1)));
    trv1 = vTr(:,:,ev1);
    trv2 = vTr(:,:,ev2);
    delta_transf = inv(trv1)*trv2;
    v=convertFromTransformationMatrix(delta_transf);
    % -- a.4 Add noise to these relative transformations, and save them as dx, dy and dth
    rdX = ((rand - 0.5)*2)*(vdX) + v.x;
    rdY = ((rand - 0.5)*2)*(vdY) + v.y;
    rdTh = ((rand - 0.5)*2)*(vdTh) + v.th;
%     fprintf('Random values to be added: %f %f %f\n',rdX, rdY, rdTh);
%     fprintf('Relative transformation: %f %f %f\n', v.x, v.y, v.th);
    rcm = ((rand(1,6) - 0.5)*2);
    rcm = rcm.*(2*vcm);
    rcm = rcm + mcm;
    % fill up edges
    edges(i).dx = rdX;
    edges(i).dy = rdY;
    edges(i).dth = rdTh;
    edges(i).covMatrix(1,1) = rcm(1,1);
    edges(i).covMatrix(1,2) = rcm(1,2);
    edges(i).covMatrix(1,3) = rcm(1,3);
    edges(i).covMatrix(2,1) = rcm(1,2);
    edges(i).covMatrix(2,2) = rcm(1,4);
    edges(i).covMatrix(2,3) = rcm(1,5);
    edges(i).covMatrix(3,1) = rcm(1,3);
    edges(i).covMatrix(3,2) = rcm(1,5);
    edges(i).covMatrix(3,3) = rcm(1,6);
%    if (~issymmetric(edges(i).covMatrix))
%        fprintf('FAILED ALGO! NOOB!!\n');
%    end
end

end
function [T]=convert2TransformationMatrix_SO2(val)

    x=val.x;
    y=val.y;
    th=val.th;

    T=[cos(th) -sin(th) x;
        sin(th) cos(th) y;
        0 0 1];
end

function [v]=convertFromTransformationMatrix(T)

    v.x=T(1,3);
    v.y=T(2,3);
    v.th=(atan2(T(2,1),T(1,1)));  %   T(2,1)=sin(th), T(1,1)=cos(th). So, on the whole,

end
