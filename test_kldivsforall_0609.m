% script to run K-L divergence 
% 6-9-2022 S.L.

clear

%% run for all files

%%%%%%%%%%%%%%%%%%%%%% ADD MICE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mouseDirs = {'C:\Users\selinali\lab\Mice\T01';
                'C:\Users\selinali\lab\Mice\T02';
                'C:\Users\selinali\lab\laptop\2022-2-18\Sut3_data';};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for mouse=1:length(mouseDirs)
    files = dir([mouseDirs{mouse} '\*_Suite2p_*.mat']);
    for file=1:length(files)

        if file==13 && mouse==1 %%%%%%%%%%% missing half of oritrace
            continue;
        end

        disp([num2str(file) ': ' files(file).name]);
        load([files(file).folder '/' files(file).name]);

        data = split_sessions_forKL(suite2pData);
        %data = combine_sessions_forKL(data); 
        %%%%%%%% ^un-comment the above line to combine both sessions for analysis
        
        for session=1:length(data)
            %%%%%%%%%%%% MODIFY CONFIG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            baselineLen     =3;
            postStimLen     =3;
            bySec           =true;
            binsize         = 20;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            [trialsMat, grid, gridLabels] = trialsMat_prep( ...
                data{session}.traces, ...
                data{session}.freq, ...
                data{session}.stimOnsets, ...
                data{session}.stimOffsets, ...
                data{session}.stimTrace, ...
                baselineLen,postStimLen,bySec ...
                );

            kldivs = kldivergence(trialsMat,grid,binsize);
    
            kldivsAll{mouse,file,session} = kldivs;
    
            cv{mouse,file,session} = circular_variance(kldivs(:,:,1),gridLabels{1});

        end
    end
end

%% save
%%%%%%%%%%%% MODIFY SAVE DIR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('6-8 kldivs and cv for TO1, TO2 & Sut3.m',"kldivsAll","cv");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kldivsAllProc = cellfun(@(x) max(max(x,[],3),[],2), kldivsAll,'UniformOutput', false);
kldivAboveThres = cellfun(@(x) length(x(x>0.7)), kldivsAllProc);



%% plotting
% plot tmice
for tmouse=1:2
    hold on
    plot(kldivAboveThres(tmouse,1:16,1))
    plot(kldivAboveThres(tmouse,1:16,2))
    title(['TO' num2str(tmouse) ' - Number of neurons with significant KL divergence across days (thres=0.7)'])
    xticks(1:16)
    xline(8,'--r','suture','LineWidth',LINEWIDTH)
    xline(13,'--r','unsuture''LineWidth',LINEWIDTH)
    legend('session2','session4')
    filename=['C:\Users\selinali\lab\RDE20141\2022-6-7-code\TO' num2str(tmouse) ' across days.jpg'];
    print(filename,'-dpng','-r200'); 
end

% plot sut mice
    hold on
    plot(kldivAboveThres(3,1:29,1))
    plot(kldivAboveThres(3,1:29,2))
    title(['Sut3 - Number of neurons with significant KL divergence across days (thres=0.7)'])
    xticks(1:29)
    xline(8,'--r','suture','LineWidth',LINEWIDTH)
    xline(15,'--r','unsuture','LineWidth',LINEWIDTH)
    xline(25,'--r','resuture','LineWidth',LINEWIDTH)
    legend('session2 monocular','session3 binocular')

