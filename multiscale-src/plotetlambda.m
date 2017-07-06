function[legendInfo] = plotetlambda(tScaleIdx, t_scale, D)
%PLOTETLAMBDA plots exp(-λt) vs λ for a given t_scale
%   Input:
%       tScaleIdx: the index of the tScale being plotted
%       t_scale: values for scale of diffusion (the whole array)
%       D: list of eigenValues
%   Output:
%       graph output in figure
%       legendInfo: cell array to store the legend information

nTscale = length(t_scale);
clr = jet(nTscale);
figure('name','plot for exp(-λt) vs λ');
lw = 4;
edt = exp(-t_scale(tScaleIdx)*D);
plot(D,edt,'color',clr(i,:),'LineWidth',lw);
legendInfo{i} = ['t = ',num2str(t_scale(i))];
hold on;
%  legend(legendInfo,'Location','eastoutside');
%  title('exp(-λt) vs λ for changing tScale');
end