function [gtMapAutPose] = relatePosetoTimestamp(AUTtsFile, GTtsFile)
%RELATETOTIMESTAMP Relates a aut pose to a gt pose, by finding out the
%closest timestamp they match to. Best use when the timestamps are not very
%far from one another
%-------------------------------------------------------------------------------
%   Input:
%       AUTtsFile: .txt file name which has the timestamps of the AUT poses
%       GTtsFile : .txt file name which has the timestamps of the GT poses
%-------------------------------------------------------------------------------


%% Read files
% -- Read the .txt files
AUTts = getTimestampFromFile(AUTtsFile);
GTts  = getTimestampFromFile(GTtsFile);

%% Create the map
AUTtsCount = length(AUTts);
gtMapAutPose = zeros(size(AUTts));
% -- Compare the timestamps
for i = 1:AUTtsCount
    [~,index] = min(abs(GTts - AUTts(i)));
    gtMapAutPose(i) = index;
end
% N = [1990 1998 2001 2004 2001]
% V = [2000 2011 2010 2001 1998]
% 
% [c index] = min(abs(N-V(1)))
end