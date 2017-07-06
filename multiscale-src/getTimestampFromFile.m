function [tsData] = getTimestampFromFile(tsFileName)
%GETTIMESTAMPFROMFILE Get Timestamp from File. 

%% Read File
formatSpec='%f';
tsFile = fopen(tsFileName,'r');
[tsData] = fscanf(tsFile, formatSpec);
end