
function suite2pData_combined = combine_sessions_forKL(suite2pData_lite)

% this function serves to pool data from multiple sessions if they are 
% to be analyzed together *after running split_sessions_forKL*
    
    suite2pData_combined=cell(1,1);
    suite2pData_combined{1}.traces=[];suite2pData_combined{1}.stimTrace=[];
    suite2pData_combined{1}.stimOnsets=[];suite2pData_combined{1}.stimOffsets=[];
    for ii=1:length(suite2pData_lite)
        suite2pData_combined{1}.Idx(ii)=suite2pData_lite{ii}.Idx;
        suite2pData_combined{1}.traces = [suite2pData_combined{1}.traces suite2pData_lite{ii}.traces];
        suite2pData_combined{1}.stimTrace = [suite2pData_combined{1}.stimTrace;suite2pData_lite{ii}.stimTrace];
        suite2pData_combined{1}.startIdx(ii) = suite2pData_lite{ii}.startIdx;
        suite2pData_combined{1}.endIdx(ii) = suite2pData_lite{ii}.endIdx;
        suite2pData_combined{1}.stimStartIdx(ii) = suite2pData_lite{ii}.stimStartIdx;
        suite2pData_combined{1}.stimEndIdx(ii) = suite2pData_lite{ii}.stimEndIdx;
        if ii==1
            shift=0;
        else
            shift = suite2pData_combined{1}.startIdx(ii-1);
        end
        suite2pData_combined{1}.stimOnsets = [suite2pData_combined{1}.stimOnsets suite2pData_lite{ii}.stimOnsets+shift];
        suite2pData_combined{1}.stimOffsets = [suite2pData_combined{1}.stimOffsets suite2pData_lite{ii}.stimOffsets+shift];
    end
    suite2pData_combined{1}.freq = suite2pData_lite{1}.freq;

end

