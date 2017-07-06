function calculatePrecisionRecallgroupFiles(gtFileName, initFilesCreated, prunedFileCreated,prFileName, diffRatio)
%CALCULATEPERFORMANCERECALLGROUPFILES Calculates Precision and Recall for a
%group of files
%   Input:
%       diffRatio: one initFile correspondes to diffRatio number of prunedFiles

%% Initialization

doDebug = 0;

% -- Read init files Directory
idx       = find(initFilesCreated == '/');
idx       = idx(end);
initDir  =  initFilesCreated(1:idx);
fprintf('Input Directory: %s\n',initDir);

% -- Extract pruned files Directory

idx       = find(prunedFileCreated == '/');
idx       = idx(end);
prunedDir = prunedFileCreated(1:idx);
fprintf('Output Directory: %s\n',prunedDir);

inFile  = fopen(initFilesCreated,'r');
prunedFile = fopen(prunedFileCreated,'r');
prFileID = fopen(prFileName,'w');
prunedFline = fgetl(prunedFile);
initFline   = fgetl(inFile);
fileCount = 1;
while (ischar(initFline) && ischar(prunedFline))
    initFileName = [initDir,initFline];
    prunedFileName = [prunedDir,prunedFline];
    if (doDebug == 1)
        fprintf(1,'gtFile: %s\n',gtFileName);
        fprintf(1,'initFile: %s\n',initFileName);
        fprintf(1,'prunedFile: %s\n',prunedFileName);
        fprintf(1,'calculatePrecisionRecall(''%s'', ''%s'', ''%s'');\n',gtFileName, initFileName, prunedFileName);
    end
    [precision, recall] = calculatePerformanceRecall(gtFileName, initFileName, prunedFileName);
    fprintf(prFileID,'%f %f\n',precision, recall);
    fprintf(1,'%d: %f %f\n',fileCount, precision, recall);
    fileCount = fileCount + 1;
    prunedFline = fgetl(prunedFile);
    if (rem((fileCount  -1 ),diffRatio) == 0)
        initFline   = fgetl(inFile);
    end
%     if (fileCount == 2)
%         break;
%     end
end
% -- Close the files
fclose(prFileID);
fclose(prunedFile);
fclose(inFile);

end