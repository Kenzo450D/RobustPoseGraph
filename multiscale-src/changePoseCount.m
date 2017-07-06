function [newAutVertices] = changePoseCount(autVertices, freqDiff)

vCount = size(autVertices,2);
% newVc = floor(vCount/freqDiff);
% newAutVertices = struct{'idx',{},'x',{},'y',{},'o',{}};
idx = 1;
for i = 1:vCount
    if ( rem(i,freqDiff) == 1)
        newAutVertices(:,idx) = autVertices(:,i);
        idx = idx + 1;
    end
end

end
