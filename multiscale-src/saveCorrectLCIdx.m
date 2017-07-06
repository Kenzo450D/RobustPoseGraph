function saveCorrectLCIdx(initMatFileName,incorrectLcIdx, outputG2oFileName)

%% init
load(initMatFileName);

%% delete the incorrectLcIdx
edges(incorrectLcIdx) = [];

%% export the file
export2DTNFileG2o(vertices, edges, outputG2oFileName, [],[]);

end