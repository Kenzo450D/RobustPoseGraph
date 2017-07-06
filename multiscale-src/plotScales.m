function plotScales(inputFilesCreated,edgeTagFile)


%plotScales('data/files.txt','edgeTags/kitti_06_alpha_0.00-av-lc-15-type-local-n-1-EdgeTags.mat')
%% Initialization

% -- Read input Directory
idx       = find(inputFilesCreated == '/');
idx       = idx(end);
inputDir = inputFilesCreated(1:idx);

% -- check if edgeTagFile exists
if (exist(edgeTagFile,'file') == 2)
    load(edgeTagFile);
    % -- edgeTags is loaded from edgeTagFile
    correctEdges = find(edgeTags == 1);
    odomEdges = find(edgeTags == 2);
    incorrectEdges = find(edgeTags == 0)';
else
    fprintf(1,'Error: EdgeTagFile not found!\nEdgeTagFile: %s\n',edgeTagFile);
end

%% Read the files
inFile  = fopen(inputFilesCreated,'r');
tline   = fgetl(inFile);
allT_scale = [0.01,0.1,1,10,100];
nTscale = length(allT_scale);
clr = jet(nTscale);
i= 1;
lw = 4; %lineWidth
while ischar(tline)
    fName = [inputDir,tline];               %fileName to load
    fprintf(1,'FileName: %s\n',fName);      % for debug
    load(fName);                                            %load the file
    

    
    %% plot distance
    fprintf('length(distn): %d\t#EdgeTags: %d\n',length(distn),length(edgeTags));           %debug line
    % -- Extract distances for correct and incorrect Edges
    ced = distn(correctEdges);
    ced = sort(ced);
    ied = distn(incorrectEdges);
    ied = sort(ied);
    % -- declare figure
    figure('name','spectralDistances');
    % -- plot the distance in specific color
    plot(ced,'color','blue');
    hold on;
    plot(ied,'color','red');
    % -- Set legend for plot
    legendInfo{1} = ['t = ',num2str(allT_scale(i)),' CorrectLC' ];
    legendInfo{2} = ['t = ',num2str(allT_scale(i)),' IncorrectLC' ];
    % -- show legend
    legend(legendInfo,'Location','southoutside');
    % -- Set title for the graph
    titleStr = ['spectralDistance for tScale ',num2str(t_scale)];
    title(titleStr);
    % -- save graph
    % ---- set graph name
    [~,edgeFileNameBasis,~]=fileparts(edgeTagFile);
    lastDash = find(edgeFileNameBasis=='-');
    lastDash = lastDash(end);
    lastDash = lastDash - 1;
    saveGraphName = edgeFileNameBasis(1:lastDash);
    xlabel('Loop closures');
    ylabel('Spectral Distance');
    saveMapName = ['Distance-Map-',saveGraphName,'tScale-',num2str(t_scale),'.eps'];
    fprintf(1,'Save GraphName: %s\n',saveMapName);            % Debug line
    % ---- save the graph
    saveas(gcf,saveMapName,'epsc');
    % -- loop 
    tline = fgetl(inFile);
    i = i+1;
end
hold off;

%% plot exp t- lambda
fprintf(1,'load(''%s'')\n',fName);
for i = 1:nTscale
    edt = exp(-allT_scale(i)*D);
    plot(D,edt,'color',clr(i,:),'LineWidth',lw);
    legendInfo{i} = ['t = ',num2str(allT_scale(i))];
    hold on;
end
legend(legendInfo,'Location','eastoutside');
title('exp(-λt) vs λ for changing tScale');
hold off;
% -- save the graph
xlabel('lambda');
ylabel('exp(-lambda * t)');
saveMapName = [saveGraphName, '-plot-expLambda.eps'];
saveas(gcf,saveMapName,'epsc');


fclose(inFile);
close all;

%{
% legendIdx = 1;clrIdx = 1;
% clr = jet(nTscale*2);
% figure('name','spectralDistances');
% while ischar(tline)
%     fName = [inputDir,tline];
%     fprintf(1,'FileName: %s\n',fName);
%     load(fName);
%     fprintf('length(distn): %d\n',length(distn));
% %     fprintf('correctEdges: ');
% %     disp(correctEdges');
%     ced = distn(correctEdges); 
%     ied = distn(incorrectEdges);
%     plot(ced,'color',clr(clrIdx,:));
%     hold on;
%     clrIdx = clrIdx +1;
%     plot(ied,'color',clr(clrIdx,:));
%     clrIdx = clrIdx +1;
%     fprintf(1,'i = %d size of t_Scale: %d\n',i,length(allT_scale));
%     legendInfo{legendIdx} = ['t = ',num2str(allT_scale(i)),' CorrectLC' ];
%     legendIdx = legendIdx + 1;
%     legendInfo{legendIdx} = ['t = ',num2str(allT_scale(i)),' IncorrectLC' ];
%     i = i+1;
%     legendIdx = legendIdx +1;
%     
%     tline = fgetl(inFile);
% end
% hold off;
% legend(legendInfo,'Location','eastoutside');
% title('exp(-λt) vs λ for changing tScale in kitti-06-local-15');
% fclose(inFile);
%}
end
