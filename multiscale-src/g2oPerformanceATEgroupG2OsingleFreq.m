function g2oPerformanceATEgroupG2OsingleFreq(filesCreatedFile, inputDirPath, GTFileName, outFileName)
%G2OPERFORMANCEATEGROUPG2O Calculates the ATE from a group of g2o files and
%the ground truth.
%   Input:
%    filesCreatedFile: .txt file containing the list of files to be
%                      compares against
%    inputDirPath    : input directory path, if files are in a separate directory.
%               (Do NOT include trailing '/')(Leave as '' if not required)
%    groundTruth     : g2o file which includes the grouth truth
%                      (inputDirPath does not apply to this file)
%    outFileName     : the txt file in which the ATE results come

%% Initialize
% -- Read the filesCreatedFile
fileNames = getFileNames(inputDirPath, filesCreatedFile);
% -- Check if the corresponding mat files exist
% ---- extract fileNameBasis
[~, matFileNames] = getFileNamesBasis(fileNames);
% ---- check if the mat file exist
matfe = checkMatFileExists(matFileNames); %'mat' 'f'ile 'e'xist
% ---- check whether g2o file exists
g2ofe = checkg2oFileExists(fileNames); 
% ---- check whether ground truth mat file exists
[GTMatFileName,GTG2oFileName] = getGTFileName(GTFileName);

% -- init file
fileID = fopen(outFileName,'w');

%% calculate ate
for i = 1:length(matfe)
    AUTFileName = char(fileNames(i));
    AUTMatFileName = char(matFileNames(i));
    if (matfe(i) == 1)
        fprintf('From Mat!\n');
        ateVal = g2oPerformanceATEfromMATsingleFreq(GTMatFileName,AUTMatFileName);
    else
        fprintf('From G2o!\n');
        ateVal = g2oPerformanceATEfromG2OsingleFreq(AUTFileName, GTG2oFileName);
    end
    fprintf(fileID, '%f\n',ateVal);
    fprintf(1,'fileName: %s\n',char(fileNames(i)));
    fprintf(1,'i = %d out of %d\tATE : %f\n',i,length(matfe), ateVal);
end
fclose(fileID);
end