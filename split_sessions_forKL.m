
function suite2pData_lite = split_sessions_forKL(suite2pData)

% packing each stim session in a run into a cell array

% INPUT: suite2p data loaded from processed .mat
% OUTPUT: 1*n (n=num of sessions) cell array containing all info required 
%         for kldivergence & circular variance calculations

    keptSessions = find(suite2pData.Stim.numVisstim~=0);
    numVisstim = suite2pData.Stim.numVisstim(suite2pData.Stim.numVisstim~=0);
    edges(1) = 0;
    for ii=1:length(numVisstim)
        edges(end+1) = sum(numVisstim(1:ii));
    end

    onsets = suite2pData.Stim.trialonsets;
    offsets = suite2pData.Stim.trialoffsets;

    suite2pData_lite=cell(1,length(keptSessions));
    for ii=1:length(keptSessions)
        ses=keptSessions(ii);
        suite2pData_lite{ii}.Idx = ses;
        suite2pData_lite{ii}.traces = suite2pData.dFF(:,suite2pData.startIdx(ses):suite2pData.endIdx(ses));
        suite2pData_lite{ii}.stimTrace = suite2pData.Stim.oriTrace(edges(ii)+1:edges(ii+1));
        suite2pData_lite{ii}.startIdx = suite2pData.startIdx(ses);
        suite2pData_lite{ii}.endIdx = suite2pData.endIdx(ses);
        suite2pData_lite{ii}.stimStartIdx = edges(ii)+1;
        suite2pData_lite{ii}.stimEndIdx = edges(ii+1);
        suite2pData_lite{ii}.stimOnsets = onsets(onsets>suite2pData.startIdx(ses)&onsets<suite2pData.endIdx(ses))-suite2pData.startIdx(ses);
        suite2pData_lite{ii}.stimOffsets = offsets(offsets>suite2pData.startIdx(ses)&offsets<suite2pData.endIdx(ses))-suite2pData.startIdx(ses);
        suite2pData_lite{ii}.freq = suite2pData.ops.fs;
    end

end

