
function kldivs = kldivergence(trialsMat,grid,binsize)

% calculate K-L divergence

%%% INPUTS
% trialsMat: 3D matrix A*B*C where A is the number of neurons, B is the 
% number of trials and C is the length of a single trial
% grid: a 2x1 cell array found in the output of trialsMat_prep()

% OUTPUT: 3D matrix A*M*N where M is the number of stimulus types (e.g. #orientations
%         and N is the number of tests performed between a baseline condition
%         and a non-baseline condition (e.g. no stim/stim on)

    % zero out negative values?
    trialsMat(trialsMat<0)=0;
   
    % are we processing a single neuron?
    if ndims(trialsMat)==2
        trialsMat=reshape(trialsMat,1,size(trialsMat,1),size(trialsMat,2));
    end

    % get kldivergence pools
    kldivPools=pools(trialsMat,grid);


    % baseline condition is the first row in trialsMat
    %tic
    for neuron=1:size(kldivPools,1)
        for stim=1:size(kldivPools,2)
            baseCond=kldivPools{neuron,stim,1};
            for cond=2:size(kldivPools,3)

                % get min/max value of current pool and generate bins accordingly
    
                % (the current pool contains two conditions, baseline and
                % non-baseline, for a single neuron & a single stimulus type)
                nonBaseCond=kldivPools{neuron,stim,cond};
                minedge=round(min([baseCond;nonBaseCond])-0.01,2,'TieBreaker','fromzero');
                maxedge=round(max([baseCond;nonBaseCond])+0.01,2,'TieBreaker','fromzero');
                edges=linspace(minedge,maxedge,binsize);
    
                % generate histograms and calculate probability distribution
                histBase=hist(baseCond,edges);
                histBase=histBase/sum(histBase);
                histNonBase=hist(nonBaseCond,edges);
                histNonBase=histNonBase/sum(histNonBase);
                
                %%%%%%%%%%%%%%%%%%%%%% calculate kldiv %%%%%%%%%%%%%%%%%%%%%
                kldivSum=histBase.*(log2(histBase)-log2(histNonBase));
                nonNans = kldivSum(~isinf(kldivSum)&~isnan(kldivSum));

                % If the tested distribution is completely off (non of the
                % values that appear in the tested distribution appeared in
                % baseline distribution), then kldiv is set to INF

                if isempty(nonNans)
                    kldivs(neuron,stim,cond-1)=Inf;
                    warning("Non-overlapping distribution")
                else
                    kldivs(neuron,stim,cond-1)=sum(nonNans);

            % baseline v.s. stim on v.s. stim off
                end
            end
        end
    %toc
    %length(kldivs(kldivs<0))
        
    end

   %%%%%%%%%%%%%%%%%%%%% processing of raw kldiv %%%%%%%%%%%%%%%%%%%%%%%%%%
   kldivs(kldivs<0)=0; % set negative values to 0
   %kldivsProc=max(kldivs,[],3); % most activated conditon (stim on / stim off relative to baseline)
   %kldivsProc=max(kldivsProc,[],2); % most activated type of stimulus


end
