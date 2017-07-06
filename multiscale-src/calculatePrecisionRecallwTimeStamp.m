function [precision, recall] = calculatePrecisionRecallwTimeStamp(gtFileName, initFileName, outFileName, gtMapAutPose)
    %% Initialize
    precision = 0;
    recall = 0;
    % -- get mat fileName
    [gtMatFileName,gtG2oFileName] = getMATFileName(gtFileName);
    [initMatFileName,initG2oFileName] = getMATFileName(initFileName);
    [outMatFileName,outG2oFileName] = getMATFileName(outFileName);
    % -- For GT file
    if (~checkMatFileExists(gtMatFileName))
        if (~checkg2oFileExists(gtG2oFileName))
            fprintf(1,'Ground Truth File Not found');
            return;
        end
        readg2oFile(gtG2oFileName,'fc.txt',1);
    end
    % -- for init File
    if (~checkMatFileExists(initMatFileName))
        if (~checkg2oFileExists(initG2oFileName))
            fprintf(1,'Init File Not found');
            return;
        end
        readg2oFile(initG2oFileName,'fc.txt',1);
    end
    % -- for out File
    if (~checkMatFileExists(outMatFileName))
        if (~checkg2oFileExists(outG2oFileName))
            fprintf(1,'Out File Not found');
            return;
        end
        readg2oFile(outG2oFileName,'fc.txt',1);
    end
    % As we cannot get a threshold from the ground truth this time, we have to 
    % consider a threshold as a distance of 10 odometry steps, and the loop 
    % closures should not be between non-consecutive steps to avoid calling
    % local loop closures. This is just an approximation, hope it works.
    
    %% get Threshold from ground Truth
    [avgOdomDist] = getAverageOdometryDistance(initMatFileName);
    threshold = avgOdomDist * 20;
    
    %% get correct loop closures in initFile
    % correctLC: less than threshold; not to be deleted
    % incorrectLC: more than threshold; to be deleted
    [correctLcIdx, incorrectLcIdx] = checkLCinitFilewTS(initMatFileName, threshold, gtMatFileName, gtMapAutPose);
    
    %% for debug, save the correctLcIdx, we can plot and see them
%     saveCorrectLCIdx(initMatFileName,incorrectLcIdx,'test.g2o');
    %export2DTNFileG2o(vertices, edges, fileName, zeroVertexMat, zeroEdgeMat)
    
    %% compare and get loop closures deleted in outFile
    [precision, recall] = getPR(outMatFileName, correctLcIdx, incorrectLcIdx, initMatFileName);
    
    
end