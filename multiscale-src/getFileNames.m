function [files] = getFileNames(dirPath, filesCreatedFile)
%GETFILENAMES get file names to work on
% Input:
%   path: the directory path containing the files
%   filesCreatedFile: txt file containing all the name of the files

%% Initialize
% create full path for the files and add it in cell.

% fcFile = fopen(filesCreatedFile,'r');
text = fileread(filesCreatedFile);
files = strsplit(text);

while(true)
    if (isempty(char(files(end))))
        files(end) = [];
    else
        break;
    end
end
%% append path to files
if ( ~ isempty(dirPath))
    for i = 1:size(files,2)
        fileTmp = char(files(i));
        if (isempty(fileTmp))
            files(i) = [];
            i = i -1;
        end
        tmp = [dirPath,'/',char(files(i))];
        files(i) = cellstr(tmp);
    end
end

end