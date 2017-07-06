function [matfe] = checkMatFileExists(matFileName)
%CHECKMATFILEEXISTS Checks if mat files exist
%   Input:
%       matFileNames: cell array of the matFilesNames
%   Output:
%       matfe: array of size matFilesNames, 1 or 0 in them defines whether
%       that particular mat file exists or not

if (exist(matFileName, 'file') == 2)
    matfe = 1;
else
    matfe = 0;
end
end