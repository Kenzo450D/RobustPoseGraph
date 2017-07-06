function [fileNamesBasis, matFileNames] = getFileNamesBasis(fileNames)
%GETFILENAMESBASIS: Get the list of filenames-basis from a struct of
%fileNames (with cellstring)

% -- initialize
fileNamesBasis = cell(size(fileNames));
matFileNames   = cell(size(fileNames));

% -- read the fileNames
for i = 1:size(fileNames,2)
    [pathstr,name,~] = fileparts(char(fileNames(i)));
    if (isempty(pathstr))
        outFileName = name;
        matFileName = [name,'.mat'];
    else
        outFileName = [pathstr,'/',name];
        matFileName = [pathstr,'/',name,'.mat'];
    end
    fileNamesBasis(i) = cellstr(outFileName);
    matFileNames(i)   = cellstr(matFileName);  
end

end