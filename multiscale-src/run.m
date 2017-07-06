%RUN Runs the heat embedding algo on a particular .g2o file (2D)

% Algo would check on the following 5 files
%data/intel-lc-623-type-localGrouped-n-32.g2o
%data/intel-lc-623-type-local-n-5.g2o
%data/intel-lc-623-type-randomGrouped-n-9.g2o
%data/intel-lc-623-type-random-n-12.g2o
%data/intel-lc-712-type-allRandom-n-3.g2o

% ---- Change the weights here:
OdomWeight    = 0.92;
OrigLCWeight  = 0.8;
SynthLCWeight = 0.2;

% ---- Ground truth
gt='intelSC4.mat';

% ---- mat files in consideration
files = cell(1,5);
files(1) = cellstr('data/intel-lc-623-type-localGrouped-n-32.mat');
files(2) = cellstr('data/intel-lc-623-type-local-n-5.mat');
files(3) = cellstr('data/intel-lc-623-type-randomGrouped-n-9.mat');
files(4) = cellstr('data/intel-lc-623-type-random-n-12.mat');
files(5) = cellstr('data/intel-lc-712-type-allRandom-n-3.mat');
g2oFiles = cell(1,5);
g2oFiles(1) = cellstr('data/intel-lc-623-type-localGrouped-n-32.g2o');
g2oFiles(2) = cellstr('data/intel-lc-623-type-local-n-5.g2o');
g2oFiles(3) = cellstr('data/intel-lc-623-type-randomGrouped-n-9.g2o');
g2oFiles(4) = cellstr('data/intel-lc-623-type-random-n-12.g2o');
g2oFiles(5) = cellstr('data/intel-lc-712-type-allRandom-n-3.g2o');


% ---- scale of heat embedding
tScale = 0.7*942;

% ---- redirect extensive output from running g2o
% preCmd  = ['exec 3>&1 4>&2; exec > tmpFile.txt 2&1;' ];
% postCmd = ['; exec >&3 2>&4'];
preCmd  = [''];
postCmd = [''];
% ---- data structures for proper ATE output
ateName = cell(10,1);
ateVal  = zeros(10,1);
counter = 1;

% ---- run with all types of noise
for i = 1:5
    % ---- initialization to run the code
    fileName         = char(files(i));
    idx              = find(fileName=='.');
    idx              = idx(end) - 1;
    fileNameBasis    = fileName(1:idx);
    extn             = sprintf('-tScale-%d-',tScale);
    outFileNameBasis = [fileNameBasis,extn,'AUT'];
    prFileName       = [fileNameBasis,extn,'-AUT-PR.txt'];
    % ---- call function
    mainCodeFnWeights(char(files(i)),tScale, outFileNameBasis, 1, gt, prFileName,OdomWeight, SynthLCWeight, OrigLCWeight);
    % ---- initialization for g2o
    outG2oFile       = [outFileNameBasis,'-DCS.g2o'];
    inG2oFile        = [outFileNameBasis,'.g2o'];
    % ---- call for g2o
    command          = ['g2o -i 30 -robustKernel DCS -o ',outG2oFile, ' ',inG2oFile];
    command          = [preCmd,command,postCmd];
    sysCmdOutput     = system(command);
    % ---- Get ATE error for (algo+DCS)
    readg2oFile(outG2oFile,'filesCreated.txt',1);
    outMatFile       = [outFileNameBasis,'-DCS.mat'];
    ate              = g2oPerformanceATE(gt,outMatFile);
    ateVal(counter)  = ate;
    ateName(counter) = cellstr(outMatFile);
    counter          = counter + 1;
    % ---- Get ATE for just DCS (not with our algo)
    initG2oFile      = [fileNameBasis,'.g2o'];
    outG2oInitFile   = [fileNameBasis,'-DCS.g2o'];
    outMatInitFile   = [fileNameBasis,'-DCS.mat'];
    command          = [preCmd,command,postCmd];
    command          = ['g2o -i 30 -robustKernel DCS -o ',outG2oInitFile, ' ',initG2oFile];
    sysCmdOutput     = system(command);
    % ---- Get ATE error for (DCS)
    readg2oFile(outG2oInitFile,'filesCreated.txt',1);
    g2oPerformanceATE(gt,outMatInitFile);
    ate              = g2oPerformanceATE(gt,outMatInitFile);
    ateVal(counter)  = ate;
    ateName(counter) = cellstr(outMatInitFile);
    counter          = counter + 1;
end

% ---- Output of ATE
fprintf(1,'These are the ATE values:\n');
for i = 1:10
    fprintf(1,'%s :: %f\n',char(ateName(i)),ateVal(i));
end

% ---- run with single file
% fileName = '<YOUR FILENAME GOES HERE>';

% readg2oFile(filename,'filesCreated.txt',1);
% idx              = find(fileName=='.');
% idx              = idx(end) - 1;
% fileNameBasis    = fileName(1:idx);
% extn             = sprintf('-tScale-%d-',tScale);
% outFileNameBasis = [fileNameBasis,extn,'AUT'];
% prFileName       = [fileNameBasis,extn,'-AUT-PR.txt'];
% mainCodeFnWP(fileName,tScale,outFileNameBasis,1,gt,prFileName);
