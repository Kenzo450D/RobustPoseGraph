function [ distn ] = distanceEmbedding( V, D, K, edges, t_scale, outputg2oFileName, vertices )
%DISTANCEEMBEDDING Makes the distance embedding, to calculate the euclidean
%distance between vertices vertices in the spectral embedding,
%   Input::
%       V: Eigen vectors
%       D: Eigen Values
%       K: Number of eigen values
%       A: Incidence Matrix


%% Commute Time Embedding
%Y=V(:,2:K)*diag(1./sqrt(D(2:K))); % fixed scale diffusion

%% Heat Embedding
Y=V(:,2:K) * diag(exp(-(t_scale/2)*D(2:K)));
%%Compute Distance between two nodes of each LP edge in the embedding space
distn=zeros(1,length(edges));
for i=1:size(edges,2)
    %pause(0.01)
    distn(i) = norm(Y(edges(i).v1,:)-Y(edges(i).v2,:));
    %disp(sprintf('Distance between node %d and node %d is %f',edges(i).v1,edges(i).v2,dist));
end

%% plotetlambda
% plotetlambdaSingle(D);

%% save the data
% [~,name,~] = fileparts(outputg2oFileName);
% dataFileName = [name,'-spectralDistance.mat'];
% save(dataFileName,'t_scale','edges','distn','V','D','vertices');
end

