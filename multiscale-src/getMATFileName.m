function [MatFileName,G2oFileName] = getMATFileName(FileName)
%GETMATFILENAME Returns the .g2o and .mat extension versions of the input
%filename

[pathstr,name,~] = fileparts(char(FileName));
if (isempty(pathstr))
    MatFileName = [name,'.mat'];
    G2oFileName = [name,'.g2o'];
else
    MatFileName = [pathstr,'/', name,'.mat'];
    G2oFileName = [pathstr,'/', name,'.g2o'];
end
end