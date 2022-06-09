
function circularVariance = circular_variance(responses,thetas)

% circular variance (CV) (Cavanaugh et al., 2002b; Ringach et al., 2002).

%%% INPUTS
% responses: N*K matrix where M is the number of neuron and K is the 
%            number of stimulus orientations used in the experiment.
%            This matrix specifies response amplitude for each orientation 
%            (Defined by K-L divergence or similar measures)
%            *Note: by definition responses cannot be negative
% thetas: K*1 numeric vector of orientation values

% OUTPUT: circularVariance: N*1 vector of values between 0~1,
%           where 0 = not orientation selective at all,
%                 1 = exclusively activated by one orien

    sumRn=sum(responses,2);
    thetasEuler=cos(thetas)+i*sin(thetas);
    sumRnExp2Theta=sum(responses.*repmat(thetasEuler',size(responses,1),1),2);

    circularVariance = abs(sumRnExp2Theta) ./ sumRn;
    
end