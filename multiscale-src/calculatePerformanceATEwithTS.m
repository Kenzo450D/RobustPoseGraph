function calculatePerformanceATEwithTS(outputFileNameBasis, inputg2oFileBasis, groundTruth, dcsTests, cauchyTests, rrrTests, ateFileName, prRRRFileName, gtMapAutPose)
%CALCULATEPERFORMANCEATEATE Calculate ATE of two g2o files after optimisation
%with DCS, Cauchy and RRR
%% Initialization
outputg2oFileName= [outputFileNameBasis,'.g2o'];
inputg2oFile = [inputg2oFileBasis,'.g2o'];


% -- set output file path for the init files
[outputDir,~,~] = fileparts(outputFileNameBasis);
% -- get inFileName
slashIdx = find(inputg2oFileBasis == '/');
slashIdx = slashIdx(end) + 1;
inFileName = inputg2oFileBasis(slashIdx:end);

if isempty(outputDir)
    outputInG2oBasis = [inFileName];
    outputInG2oFile = [inFileName,'.g2o'];
else
    outputInG2oBasis = [outputDir,'/',inFileName];
    outputInG2oFile = [outputDir,'/',inFileName,'.g2o'];
end

% -- for server
% g2oPath = '~/software/g2o/bin/g2o';
% rrrPath = '~/software/rrr/build/examples/RRR_2D_optimizer_g2o';

% -- for desktop
g2oPath = 'g2o';
rrrPath = '~/Work/InitRRR/build/examples/RRR_2D_optimizer_g2o';

ate = zeros(10,1);
ateEndIdx = 0;
%% DCS ATE

if (dcsTests == 1)
    kernelWidthDCS = 20;
    outputDCSg2oFile = [outputInG2oBasis,'-DCS',int2str(kernelWidthDCS),'.g2o'];
    outputAUTDCSg2oFile = [outputFileNameBasis,'-DCS.g2o'];
    % ---- Optimise inital file
    command = [g2oPath, ' -i 30 -robustKernel DCS -robustKernelWidth ',int2str(kernelWidthDCS),' -o ', outputDCSg2oFile, ' ',inputg2oFile];
    fprintf(1,'DCS optimisation Command: \n%s\n',command);
    system(command);
    ateEndIdx = ateEndIdx + 1;
    [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OtimeStamp(outputDCSg2oFile, groundTruth, gtMapAutPose);
    fprintf(1,'ATE of initial file Optimised by DCS: %f\n',ate(ateEndIdx,1));
    % ---- Optimise AUT file
    command = [g2oPath, ' -i 30 -robustKernel DCS -robustKernelWidth ',int2str(kernelWidthDCS),' -o ', outputAUTDCSg2oFile, ' ',outputg2oFileName];
    fprintf(1,'AUT-DCS optimisation Command: \n%s\n',command);
    system(command);
    ateEndIdx = ateEndIdx + 1;
    [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OtimeStamp(outputAUTDCSg2oFile, groundTruth, gtMapAutPose );
    if isnan(ate(ateEndIdx,1))
        fprintf(1,'Output g2o file: %s\n',outputAUTDCSg2oFile);
        error('This file is the bad one!');
    end
    fprintf(1,'ATE of AUT file Optimised by DCS: %f\n',ate(ateEndIdx,1));
end

%% CAUCHY ATE
if (cauchyTests == 1)
    outputCauchyg2oFile = [outputInG2oBasis,'-Cauchy.g2o'];
    outputAUTCauchyg2oFile = [outputFileNameBasis,'-Cauchy.g2o'];
    % ---- Optimise the initial file
    command = [g2oPath, ' -i 30 -robustKernel Cauchy -o ',outputCauchyg2oFile,' ',inputg2oFile];
    fprintf(1,'Cauchy Optimisation Command: %s\n', command);
    system(command);
    ateEndIdx = ateEndIdx + 1;
    [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OtimeStamp(outputCauchyg2oFile, groundTruth, gtMapAutPose );
    fprintf(1,'ATE of initial file Optimised by Cauchy: %f',ate(ateEndIdx,1));
    % ---- Optmise the AUT file
    command =  [g2oPath, ' -i 30 -robustKernel Cauchy -o ',outputAUTCauchyg2oFile,' ', outputg2oFileName];
    fprintf(1,'AUT-Cauchy Optimisation Command: %s\n', command);
    system(command);
    ateEndIdx = ateEndIdx + 1;
    [ate(ateEndIdx,1)] =g2oPerformanceATEfromG2OtimeStamp(outputAUTCauchyg2oFile, groundTruth, gtMapAutPose );
    fprintf(1,'ATE of AUT file optimised by Cauchy: %f\n',ate(ateEndIdx,1));
end

%% RRR ATE
if (rrrTests == 1)
    outputRRRg2oFile = [outputInG2oBasis,'-RRR.g2o'];
    % outputAUTRRRg2oFile = [inputFileNameBasis,'-AUT-RRR.g2o'];
    % ---- Optimise the initial file
    command1 = [rrrPath, ' ',inputg2oFile];
    command2 = ['mv rrr-solved.g2o ',outputRRRg2oFile];
    fprintf(1,'RRR Optimisation command:\n%s\n%s\n',command1,command2);
    system(command1);
    c2out = system(command2);
    if (c2out == 0)
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OtimeStamp(outputRRRg2oFile,groundTruth, gtMapAutPose );
        fprintf(1,'ATE of initial file optimised by RRR: %f\n',ate(ateEndIdx,1));
        %% Optimise RRR file with DCS
        outputRRRDCSg2oFile = [outputFileNameBasis,'-RRR-DCS.g2o'];
        command = [g2oPath, ' -i 30 -solver gn_var_cholmod -robustKernel DCS -robustKernelWidth ',int2str(kernelWidthDCS),' -o ', outputRRRDCSg2oFile, ' ',outputRRRg2oFile];
        fprintf(1,'RRR-DCS optimisation Command: %s\n',command);
        system(command);
        fprintf(1,'g2oPerformanceATEfromG2OsingleFreq(''%s'',''%s'');\n',outputRRRDCSg2oFile,groundTruth);
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = g2oPerformanceATEfromG2OtimeStamp(outputRRRDCSg2oFile, groundTruth, gtMapAutPose );
        fprintf(1,'ATE of RRR file Optimised by DCS: %f\n',ate(ateEndIdx,1));
        %% Precision and Recall of RRR
        [precisionRRR, recallRRR] =calculatePrecisionRecallwTimeStamp(groundTruth, inputg2oFile, outputRRRg2oFile, gtMapAutPose);
        fprintf(1,'Precision RRR: %.4f\n',precisionRRR);
        fprintf(1,'Recall RRR: %.4f\n',recallRRR);
        prRRRid = fopen(prRRRFileName,'a+');
        fprintf(prRRRid,'%f %f\n',precisionRRR,recallRRR);
        fclose(prRRRid);
    else
        ateEndIdx = ateEndIdx + 1;
        [ate(ateEndIdx,1)] = NaN;
        fprintf(1,'ERROR: ***** : ATE of initial file optimised by RRR failed!!!!!\n');
    end
end

%% Output ATE Results in ATE file
ateID = fopen(ateFileName,'a+');
for i = 1:ateEndIdx
    if ~isnan(ate(i,1))
        fprintf(ateID,'%f ',ate(i,1));
    else
        fprintf(ateID,' ');
    end
end
fprintf(ateID,'\n');
fclose(ateID);
    
end