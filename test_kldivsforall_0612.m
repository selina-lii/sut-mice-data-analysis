% script to run K-L divergence 
% 6-9-2022 S.L.

clear

%% run for all files

%%%%%%%%%%%%%%%%%%%%%% ADD MICE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
miceDirs = {'C:\Users\selinali\lab\Mice\T01';
                'C:\Users\selinali\lab\Mice\T02';
                'C:\Users\selinali\lab\laptop\2022-2-18\Sut3_data';};
mice={'TO1';'TO2';'Sut3'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for mouse=1:length(miceDirs)
    files = dir([miceDirs{mouse} '\*_Suite2p_*.mat']);
    for file=1:length(files)

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
            
            if mouse==1 && file==13 && session==2 %%%%%%%%%%% missing half of oritrace
                kldivs = [];
                cv = [];
                trialsMat = [];
                grid = [];
                gridLabels = [];
            else

            [trialsMat, grid, gridLabels] = trialsMat_prep( ...
                data{session}.traces, ...
                data{session}.freq, ...
                data{session}.stimOnsets, ...
                data{session}.stimOffsets, ...
                data{session}.stimTrace, ...
                baselineLen,postStimLen,bySec ...
                );

                kldivs = kldivergence(trialsMat,grid,binsize);
                cv = circular_variance(kldivs(:,:,1),gridLabels{1});
            end

            % save in one data structure
            suite2pDataOut{file,session}.cv = cv;
            suite2pDataOut{file,session}.kldivs= kldivs;
            suite2pDataOut{file,session}.trialsMat = trialsMat;
            suite2pDataOut{file,session}.grid = grid;
            suite2pDataOut{file,session}.gridLabels = gridLabels;

        end
        save(['6-10_kldivs-cv-trialsMat_' mice{mouse} '.mat'],"suite2pDataOut",'-v7.3');
    end
end


%% save

for i=1:3
%%%%%%%%%%%% MODIFY SAVE DIR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data=reshape(suite2pDataOut(i,:,:),size(suite2pDataOut(i,:,:),2),size(suite2pDataOut(i,:,:),3));
save(['6-10_kldivs-cv-trialsMat_' mice(i,:) '.mat'],"data",'-v7.3');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

kldivsAllProc = cellfun(@(x) max(max(x.kldivs,[],3),[],2), suite2pDataOut,'UniformOutput', false);
kldivAboveThres = cellfun(@(x) length(x.cv(x.cv>0.7)), kldivsAllProc);



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

