function [ dist ] = distanceEmbedding( V, D, K, edges, t_scale, outputg2oFileName )
%DISTANCEEMBEDDING Makes the distance embedding, to calculate the euclidean
%distance between vertices vertices in the spectral embedding,
%   Input::
%       V: Eigen vectors
%       D: Eigen Values
%       K: Number of eigen values


%% Commute Time Embedding
%Y=V(:,2:K)*diag(1./sqrt(D(2:K))); % fixed scale diffusion

%% Plot data
% plot e^-Dt vs D
nTscale = length(t_scale);
clr = jet(nTscale);
figure('name','plot for exp(-λt) vs λ');
lw = 4;
for i = 1:nTscale
    edt = exp(-t_scale(i)*D);
    plot(D,edt,'color',clr(i,:),'LineWidth',lw);
%     lw = lw / 2;
%     pause(2) ;
    legendInfo{i} = ['t = ',num2str(t_scale(i))];
    hold on;
end
legend(legendInfo,'Location','eastoutside');
title('exp(-λt) vs λ for changing tScale');
hold off;


%% Heat Embedding
Y=V(:,2:K) * diag(exp(-(t_scale/2)*D(2:K)));
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

