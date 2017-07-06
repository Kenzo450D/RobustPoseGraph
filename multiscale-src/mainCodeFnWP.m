function mainCodeFnWP( inputFileName, t_scale, outputFileNameBasis, testFlag, gtFile, prFileName, ateFileName, prRRRFileName)
% MAINCODEFNWP One shot algorithm to read a g2o corrupted with noise, and use 
% spectral heat embedding to prune the outlier edges
% ------------------------------------------------------------------------------
% Input:
%   inputFileName: input of corrupted g2o mat file containing:
%       vertices
%       edges
%       vCount
%       eCount
%       zeroEdge
%       zeroVertex
%   testFlag: 1: Do testing, 0: Skip Testing
%       1: Require:
%           matFile of gtFile (ground truth MAT file)
%       0: skip the rest
%   outputFileNameBasis: output fileName without extension.
%       The .g2o and .mat files would be made from this string.
%   gtFile: Ground truth .mat file for testing
%   prFileName: fileName to save precision and recall
% ------------------------------------------------------------------------------
% Output:
%   Only as file outputs
% ------------------------------------------------------------------------------
% Author: Sayantan Datta < sayantan dot datta at research dot iiit dot ac
%                          dot in>
%
% Robotics Research Center
% International Institute of Information Technology, Hyderabad
% ------------------------------------------------------------------------------



%% Initialization

% -- Print parameters
% fprintf('Input File Name     : %s\n',inputFileName);
% fprintf('t_scale             : %d\n',t_scale);
% fprintf('Out File Name       : %s\n',outputFileName);

% -- tests Check
dcsCheck = 1;
tukeyCheck = 0;
cauchyCheck = 0;
huberCheck = 0;
pHuberCheck = 0;
rrrCheckPR = 0;
rrrDcs = 0;


% -- get initial edgeCount
load(gtFile);
initECount = eCount;
initEdges  = edges;

% -- Distance Mapping Parameters
% O_EDGE_DIST_VARIANCE = 0.05;
% LC_EDGE_DIST_VARIANCE = 0.05;
O_EDGE_DIST_MEAN = 0.92;
LC_EDGE_DIST_MEAN = 0.2;
OLC_EDGE_DIST_MEAN = 0.8;

% -- Read the mat file
load(inputFileName);
% fprintf('Data contains: %d vertices & %d Edges\n',vCount,eCount);


% -- To plot the graph
% plot_graph(vertices,edges, [],'k',0); % Plot only the graph 


%% Identify LC & Plot
% -- DEBUG :: Generates a list of edge indexes which are not odometry edges
% lcEdgeList = identifyLC(edges);
% fprintf('Identified Loop Closures: %d\n',(length((lcEdgeList)')));

% plot_graph(vertices,edges, lcEdgeList,'g',0);
% pause;

%% Heat embedding

% -- Incidence Matrix with weights
tic;
A  = getLineDescriptorIncidenceMatrix(edges, vertices, O_EDGE_DIST_MEAN, LC_EDGE_DIST_MEAN, OLC_EDGE_DIST_MEAN, initECount, []);
timeTaken = toc;
fprintf(1,'Time taken to get incidence Matrix: ');
disp(timeTaken);
Asp = sparse(A);

% -- Laplacian Matrix
L = Asp*Asp';
L = full(L);

% -- eigen Decomposition of the laplacian Matrix
[eigenVectors, eigenValues]=eig(L);
eigenValues=diag(eigenValues);
nEigenValues=length(eigenValues);

% --  Euclidean distance in spectral embedding
ntScales = length(t_scale);

for i= 1:ntScales
    
    % -- reset input values
    load(inputFileName);
    
    % -- Set output file names
    outputMATFileName = strcat(outputFileNameBasis, 'tScale-',num2str(t_scale(i)), '.mat');
    outputg2oFileName = strcat(outputFileNameBasis, 'tScale-',num2str(t_scale(i)), '.g2o');

    spectralDistn     = distanceEmbedding(eigenVectors,eigenValues,nEigenValues, edges,t_scale(i),outputg2oFileName, vertices);
    

    % -- Threshold using just odometry edge
    % distOdom     = dist(1:(vCount - 1));
    % mean_dist    = mean(distOdom);
    % var_dist     = std(distOdom);
    % threshold    = mean_dist+6*var_dist;

    % -- Threshold using all of the edges
     mean_dist    = mean(spectralDistn);
     var_dist     = std(spectralDistn);
     threshold    = mean_dist+0.5*var_dist;

    % -- Identifying bad loop closures
    temp         = find(spectralDistn>threshold);
    bad_LC_index = temp(find(temp>vCount));

    % -- DEBUG :: Plot the graph identifying the bad edges
    % plot_graph(vertices,edges,bad_LC_index,'k',1);

    %% Output and Testing

    % -- Output as G2O file
    prunedEdges = pruneEdges(edges, bad_LC_index);
    badEdges = edges(bad_LC_index);
    edges=prunedEdges;

    % save(outputMATFileName, 'vertices','edges','eCount','vCount','zeroVertex', ...
    %     'zeroEdge');
    export2DTNFileG2o(vertices, prunedEdges, outputg2oFileName, [],[]);

    fileID = fopen(prFileName,'a+');
    % -- testing and performance of output
    if ( testFlag == 1)
        tic;
        % -- output data to prFile
        [precision, recall] = calculatePrecisionRecall(gtFile, inputFileName, outputg2oFileName);
        fprintf(1,'Precision: %.4f\n',precision);
        fprintf(1,'Recall: %.4f\n',recall);
        fprintf(1,'Time taken to test the File: ');
        timeTaken= toc;
        disp(timeTaken);
        fprintf(fileID,'%f %f\n',precision, recall);
    end
    fclose(fileID);

    %% GetATE
    dotIdx = find(inputFileName == '.');
    dotIdx = dotIdx(end);
    inputFileNameBasis = inputFileName(1:(dotIdx-1));
    inputg2oFile = [inputFileNameBasis,'.g2o'];

    % -- Optimise via DCS
    ate = zeros(12,1);
    ateEndIdx = 0;
    if (dcsCheck == 1)
        kernelWidthDCS = 20;
        outputDCSg2oFile = [inputFileNameBasis,'-DCS',int2str(kernelWidthDCS),'.g2o'];
        outputAUTDCSg2oFile = [inputFileNameBasis,'-AUT-DCS.g2o'];
        % ---- Optimise inital file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel DCS -robustKernelWidth ',int2str(kernelWidthDCS),' -o ', outputDCSg2oFile, ' ',inputg2oFile];
        fprintf(1,'DCS optimisation Command: %s\n',command);
        system(command);
        fprintf(1,'g2oPerformanceATEfromG2OsingleFreq(''%s'',''%s'',gtMapAutPose);\n',outputDCSg2oFile,gtFile);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputDCSg2oFile, gtFile);
        fprintf(1,'ATE of initial file Optimised by DCS: %f\n',ate(1,1));
        % ---- Optimise AUT file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel DCS -robustKernelWidth ',int2str(kernelWidthDCS),' -o ', outputAUTDCSg2oFile, ' ',outputg2oFileName];
        fprintf(1,'AUT-DCS optimisation Command: %s\n',command);
        system(command);
        fprintf(1,'g2oPerformanceATEfromG2OsingleFreq(''%s'',''%s'');\n',outputAUTDCSg2oFile,gtFile);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputAUTDCSg2oFile, gtFile );
        fprintf(1,'ATE of AUT file Optimised by DCS: %f\n',ate(2,1));
    end
    % -- Optimise via Tukey
    if (tukeyCheck == 1)
        outputTukeyg2oFile = [inputFileNameBasis,'-Tukey.g2o'];
        outputAUTTukeyg2oFile = [inputFileNameBasis,'-AUT-Tukey.g2o'];
        % ---- Optimise inital file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel Tukey -o ', outputTukeyg2oFile, ' ',inputg2oFile];
        fprintf(1,'Tukey optimisation Command: %s\n',command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputTukeyg2oFile, gtFile );
        fprintf(1,'ATE of initial file Optimised by Tukey: %f\n',ate(3,1));
        % ---- Optimise AUT file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel Tukey -o ', outputAUTTukeyg2oFile, ' ',outputg2oFileName];
        fprintf(1,'AUT-Tukey optimisation Command: %s\n',command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputAUTTukeyg2oFile, gtFile );
        fprintf(1,'ATE of AUT file Optimised by Tukey: %f\n',ate(4,1));
    end
    
    % -- Optimise via Cauchy
    if (cauchyCheck == 1)
        outputCauchyg2oFile = [inputFileNameBasis,'-Cauchy.g2o'];
        outputAUTCauchyg2oFile = [inputFileNameBasis,'-AUT-Cauchy.g2o'];
        % ---- Optimise the initial file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel Cauchy -o ',outputCauchyg2oFile,' ',inputg2oFile];
        fprintf(1,'Cauchy Optimisation Command: %s\n', command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputCauchyg2oFile, gtFile );
        fprintf(1,'ATE of initial file Optimised by Cauchy: %f',ate(5,1));
        % ---- Optmise the AUT file
        command =  ['~/software/g2o/bin/g2o -i 30 -robustKernel Cauchy -o ',outputAUTCauchyg2oFile,' ', outputg2oFileName];
        fprintf(1,'AUT-Cauchy Optimisation Command: %s\n', command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputAUTCauchyg2oFile, gtFile );
        fprintf(1,'ATE of AUT file optimised by Cauchy: %f\n',ate(6,1));
    end

    % -- Optimise via Huber
    if (huberCheck == 1)
        outputHuberg2oFile = [inputFileNameBasis,'-Huber.g2o'];
        outputAUTHuberg2oFile = [inputFileNameBasis,'-AUT-Huber.g2o'];
        % ---- Optimise the initial f ile
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel Huber -o ',outputHuberg2oFile, ' ',inputg2oFile];
        fprintf(1,'Huber Optimisation Command: %s\n',command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputHuberg2oFile,gtFile );
        fprintf(1,'ATE of intial file optimised by Huber: %f\n',ate(7,1));
        % ---- Optimise the AUT file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel Huber -o ',outputAUTHuberg2oFile,' ',outputg2oFileName];
        fprintf(1,'AUT-Huber Optimisation Command: %s\n',command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputAUTHuberg2oFile,gtFile );
        fprintf(1,'ATE of AUT file optimised by Huber: %f\n',ate(8,1));
    end
    % -- Optimise via Pseudo-Huber
    if (pHuberCheck == 1)
        outputPseudoHuberg2oFile = [inputFileNameBasis,'-PseudoHuber.g2o'];
        outputAUTPseudoHuberg2oFile = [inputFileNameBasis,'-AUT-PseudoHuber.g2o'];
        % ---- Optimise the initial f ile
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel PseudoHuber -o ',outputPseudoHuberg2oFile, ' ',inputg2oFile];
        fprintf(1,'PseudoHuber Optimisation Command: %s\n',command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputPseudoHuberg2oFile,gtFile );
        fprintf(1,'ATE of intial file optimised by PseudoHuber: %f\n',ate(7,1));
        % ---- Optimise the AUT file
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel PseudoHuber -o ',outputAUTPseudoHuberg2oFile,' ',outputg2oFileName];
        fprintf(1,'AUT-PseudoHuber Optimisation Command: %s\n',command);
        system(command);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputAUTPseudoHuberg2oFile,gtFile );
        fprintf(1,'ATE of AUT file optimised by PseudoHuber: %f\n',ate(8,1));
    end
    % -- Optimise via RRR
    if (rrrCheckPR == 1)
        rrrPath='~/software/rrr/build/examples/RRR_2D_optimizer_g2o';
        outputRRRg2oFile = [inputFileNameBasis,'-RRR.g2o'];
        % outputAUTRRRg2oFile = [inputFileNameBasis,'-AUT-RRR.g2o'];
        % ---- Optimise the initial file
        command1 = [rrrPath, ' ',inputg2oFile];
        command2 = ['mv rrr-solved.g2o ',outputRRRg2oFile];
        fprintf(1,'RRR Optimisation command:\n%s\n%s\n',command1,command2);
        system(command1);
        c2out = system(command2);
        if (c2out == 0)
            ateEndIdx = ateEndIdx + 1;
            [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputRRRg2oFile,gtFile );
            fprintf(1,'ATE of initial file optimised by RRR: %f\n',ate(11,1));
        else
            ateEndIdx = ateEndIdx + 1;
            [ate(ateEndIdx,1)] = NaN;
            fprintf(1,'ERROR: ***** : ATE of initial file optimised by RRR failed!!!!!\n');
        end
    end
    % ---- Optimise RRR file with DCS
    if (rrrCheckPR == 1 && rrrDcs == 1 && c2out == 1)
        outputRRRDCSg2oFile = [inputFileNameBasis,'-RRR-DCS.g2o'];
        command = ['~/software/g2o/bin/g2o -i 30 -robustKernel DCS -robustKernelWidth ',int2str(kernelWidthDCS),' -o ', outputRRRDCSg2oFile, ' ',outputRRRg2oFile];
        fprintf(1,'RRR-DCS optimisation Command: %s\n',command);
        system(command);
        fprintf(1,'g2oPerformanceATEfromG2OsingleFreq(''%s'',''%s'');\n',outputRRRDCSg2oFile,gtFile);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OsingleFreq(outputRRRDCSg2oFile, gtFile );
        fprintf(1,'ATE of RRR file Optimised by DCS: %f\n',ate(12,1));
        %% Precision and Recall of RRR
        [precisionRRR, recallRRR] = calculatePrecisionRecall(gtFile, inputFileName, outputRRRg2oFile);
        fprintf(1,'Precision RRR: %.4f\n',precisionRRR);
        fprintf(1,'Recall RRR: %.4f\n',recallRRR);
        prRRRid = fopen(prRRRFileName,'a+');
        fprintf(prRRRid,'%f %f\n',precisionRRR,recallRRR);
        fclose(prRRRid);

    end
    %% Output ATE Results in ATE file
    ateID = fopen(ateFileName,'a+');
    for i = 1:ateEndIdx
        fprintf(ateID,'%f ',ate(i,1));
    end
    fprintf(ateID,'\n');
    fclose(ateID);
    
end

%% plot distance
% lcDistFileName = sprintf('Intel-Dist-lc%d-K%d.fig',extra_edges,t_scale);
% figure,plot(dist);
% savefig(lcDistFileName);


end

