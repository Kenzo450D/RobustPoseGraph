function [ dist ] = heatEmbedding( L, edges, t_scale, outputg2oFileName )
%HEATEMBEDDING Makes the heat embedding, to calculate the euclidean
%distance between vertices vertices in the spectral embedding
%   Input::
%       L: Laplacian Matrix
%       dist: 

%% eigen decomposition
[V, D]=eig(L);
D=diag(D);
K=length(D);

%% Commute Time Embedding
%Y=V(:,2:K)*diag(1./sqrt(D(2:K))); % fixed scale diffusion

%% Heat Embedding
Y=V(:,2:K)*diag(exp(-(t_scale/2)*D(2:K)));
%%Compute Distance between two nodes of each LP edge in the embedding space
dist=zeros(1,length(edges));
for i=1:size(edges,2)
    %pause(0.01)
    dist(i) = norm(Y(edges(i).v1,:)-Y(edges(i).v2,:));
    %disp(sprintf('Distance between node %d and node %d is %f',edges(i).v1,edges(i).v2,dist));
end

%% plotetlambda
%  plotetlambda(t_scale,D);

%% save the data
%  [~,name,~] = fileparts(outputg2oFileName);
%  dataFileName = [name,'-spectralDistance.mat'];
%  save(dataFileName,'t_scale','edges','dist','V','D');

end

