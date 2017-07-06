function [g2ofe] = checkg2oFileExists(fileName)
%CHECKMATFILEEXISTS Checks if g2o files exist
%   Input:
%       fileNames: cell array of the g2o filenames
%   Output:
%       matfe: array of size matFilesNames, 1 or 0 in them defines whether
%       that particular mat file exists or not

if (exist(fileName, 'file') == 2)
    g2ofe = 1;
else
    g2ofe = 0;
    fprintf(1,'Error: File Not Found!\n\tFile: %s\n',fileName);
end
end