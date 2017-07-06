function [GTMatFileName,GTG2oFileName] = getGTFileName(GTFileName)
%GETGTFILENAME Returns the .g2o and .mat extension versions of the input
%filename

[pathstr,name,~] = fileparts(char(GTFileName));
if (isempty(pathstr))
    GTMatFileName = [name,'.mat'];
    GTG2oFileName = [name,'.g2o'];
else
    GTMatFileName = [pathstr,'/', name,'.mat'];
    GTG2oFileName = [pathstr,'/', name,'.g2o'];
end
end