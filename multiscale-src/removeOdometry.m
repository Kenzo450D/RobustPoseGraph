function [ eData, oData ] = removeOdometry( eData )
%REMOVEODOMETRY removed odometry edges

%   eData :: loop closure data
%   oData :: odometry data
    oData = zeros(size(eData));
    idx = 1;
    i = 1;
    while(i <= size(eData,2))
%         fprintf('RemoveOdometry :: i=%d\tlength(eData)=%d\n',i,size(eData,2));
        diff = eData(2,i) - eData(1,i);
        if diff == 1
            oData(:,idx) = eData(:,i);
            idx = idx+ 1;
            eData(:,i) = [];
        else
            i = i+1;
        end
    end
    oData = oData(:,1:(idx-1));
%     fprintf('length(odometryData): %d\n',size(oData,2));
%     fprintf('length(loopClosData): %d\n',size(eData,2));
end

