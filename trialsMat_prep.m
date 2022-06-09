
function [trialsMat,grid,gridLabels] = trialsMat_prep ...
                        (traces,freq,stimOnsets,stimOffsets,stimTrace, ...
                        baselineLen,postStimLen,bySec)

% generate trialsMat for a given session

%%% INPUTS
% traces:       M*N matrix, M = number of neurons, N = number of frames
% freq:         Imaging frequency, i.e. the number of frames within a second
% stimOnsets:   Vector containing the frames of stimulus onset
% stimOffsets:  Vector containing the frames of stimulus offset
% stimTrace:    Vector specifying the sequence of stimuli as they appeared in the exp
% sessionBreaks:Time points segmenting each session 
% baselineLen:  Number of baseline seconds to include IF bysec==true;
%                   OR, input the number of *frames* directly and set bySec==false
% postStimLen:  Number of post-stimulus seconds to include in the heatmap
% bySec:        See baselineLen

%%% OUTPUTS
% trialsMat:    M*X*Y matrix, M = number of neurons, X = number of trials,
%               Y = length of trial
% grid:         1*2 cell array where grid{1} = edges for each stimulus type
%               and grid{2} = edges for stimulus on/off set
% gridLabels:   1*2 cell array specifying identity of each edge in grid. 
%               gridLabels{1} contains the orientation of drifting gratings
%               and gridLabels{2} contains stimulus status.

   %% getting measurments of a trial
   
   ROUND_DIGIT=0; % -1 if round to 10
   % conversion between seconds and number of frames
   if bySec
       framesPerSec=round(freq,ROUND_DIGIT);
       baselineLen=baselineLen*framesPerSec;
       postStimLen=postStimLen*framesPerSec;
   end % how many time frames needed for baseline and post-stim conditions

   stimLen=round(max(stimOffsets-stimOnsets));
            %gap between stim onset and offset, taking the max due to fence pole effect
   windowLen=round(stimLen+baselineLen+postStimLen,ROUND_DIGIT); 
            %length of the window we're examining, round to an integer
   trialLen=max(stimOnsets(2:end)-stimOnsets(1:end-1)); 
            %gap between two onsets within a session
   
       %sanity check
       if windowLen>trialLen
            warning(['Trial windows overlapping by ' num2str(windowLen-trialLen-1) ' frames']);
       end

   %% generate start of each window
   windowOnsets=stimOnsets-baselineLen;

       %sanity checks
       if windowOnsets(1)<=0
           error(['First window exceeds array lower bound by ' num2str(abs(windowOnsets(1))) ' frames. ' ...
               'Consider decreasing the number of baseline frames.']);
       end        

       endOfTrace = size(traces,2);
       if windowOnsets(end)+windowLen-1>endOfTrace
           %if the last window overruns
           bleedLen=windowOnsets(end)+windowLen-1-endOfTrace;
           warning(['Last window exceeds maximum frame number (' num2str(bleedLen) ' frames). ' ...
                    'Filling with zeros.']);

           %%%%%%%%%%%%%%%%%%%%%%%%%%% OR DROP THE LAST TRIAL?%%%%%%%%%%%%%%

           bleed=windowOnsets(end)+windowLen-1-endOfTrace;
           traces=[traces zeros(size(traces,1),bleed)];
       end

   %% sorting indices by orientation
   % generate grid for trialsMat
   [oris,sortIdxs] = sort(stimTrace);
   [ygridLabels,ygrid,~]=unique(oris);
   ygrid=ygrid-1;
   ygrid(end+1)=length(sortIdxs);
   windowOnsets=windowOnsets(sortIdxs); 

  trialsMat = get_trialsMat(traces,windowLen,windowOnsets);

  xgrid=[0 baselineLen baselineLen+stimLen windowLen];
  xgridLabels=["start";"stim on";"stim off";"end"];
  grid{2} = xgrid; grid{1} = ygrid;
  gridLabels{2} = xgridLabels; gridLabels{1} = ygridLabels;
end


%% generate trialsMat

% reorganize a timeseries (a*1 vector) into a trials matrix (x*y)
% OR, reorganize a timeseries array (a*n matrix) into a trials matrix
% arrray (n*x*y)
% ... by cutting out a series of windows from the original timeseries

%  |-x-| (z)
%  |   | /
%  y---|/   x: heatmap trial length; y: num of trials; (z: num of neurons)   

function trialsMat = get_trialsMat(traces,zdim,zStarts)
    xdim=size(traces,1);
    ydim=length(zStarts);
    trialsMat=zeros(xdim,ydim,zdim);
    
    for ii=1:xdim
       for jj=1:ydim
                % sort trials using the sorting index
                zStart=zStarts(jj);
                %insert trial into sorted position
                trialsMat(ii,jj,:)=traces(ii,zStart:zStart+zdim-1);
        end
    end
end
