function plotetlambdaSingle(D)
%PLOTETLAMBDA plots exp(-λt) vs λ for a given t_scale
%   Input:
%       tScaleIdx: the index of the tScale being plotted
%       t_scale: values for scale of diffusion (the whole array)
%       D: list of eigenValues
%   Output:
%       graph output in figure
%       legendInfo: cell array to store the legend information

t_scale = [100,70,10,5,1,0.1,0.01,0.001];
nTscales = length(t_scale);
clr = jet(nTscales);
figure('name','plot for exp(-λt) vs λ');
lw = 4;
for i = 1:nTscales
    edt = exp(-t_scale(i)*D);
    plot(D,edt,'color',clr(i,:),'LineWidth',lw);
    hold on;
end
hold off;
%  legend(legendInfo,'Location','eastoutside');
%  title('exp(-λt) vs λ for changing tScale');
end