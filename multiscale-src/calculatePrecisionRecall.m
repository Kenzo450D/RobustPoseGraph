function [precision, recall] = calculatePrecisionRecall(gtFileName, initFileName, outFileName)
    %% Initialize
    precision = 0;
    recall = 0;
    doDebug = 0;
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
    
    %% DEBUG - print the files
    if doDebug == 1
        load(gtMatFileName);
        gtEdges = edges;
        gteCount = eCount;
        load(outMatFileName);
        outEdges = edges;
        outeCount = eCount;
        load(initMatFileName);
        initEdges = edges;
        initeCount = eCount;
        idx = vCount;
        gtFlag = 0;
        initFlag = 0;
        outFlag = 0;
        fprintf(1,'Ground Truth\tInit\tPruned\n');
        while(true)
            if (idx<=gteCount)
                fprintf(1,'%d %d ',gtEdges(idx).v1,gtEdges(idx).v2);
            else
                fprintf(1,'  ');
                gtFlag = 1;
            end
            if (idx<=initeCount)
                fprintf(1,'%d %d ',initEdges(idx).v1,initEdges(idx).v2);
            else
                fprintf(1,'  ');
                initFlag = 1;
            end
            if (idx<=outeCount)
                fprintf(1,'%d %d\n',outEdges(idx).v1,outEdges(idx).v2);
            else
                fprintf(1,'  \n');
                outFlag = 1;
            end
            idx = idx + 1;
            if (gtFlag == 1 && initFlag == 1 && outFlag == 1)
                break;
            end
        end
    end
    
    %% get Threshold from ground Truth
    [ threshold, ~, goodIdx ] =  getGTThresholdLCEdge(gtMatFileName);
    
    %% get correct loop closures in initFile
    % correctLC: less than threshold; not to be deleted
    % incorrectLC: more than threshold; to be deleted
    [correctLcIdx, incorrectLcIdx] = checkLCinitFile(initMatFileName, threshold, gtMatFileName);
    
    %% compare and get loop closures deleted in outFile
    [precision, recall] = getPR(outMatFileName, correctLcIdx, incorrectLcIdx, initMatFileName);
    
    
end