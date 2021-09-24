function features = extractCSP(EEGSignals, CSPMatrix, nbFilterPairs)
%
%extract features from an EEG data set using the Common Spatial Patterns (CSP) algorithm
%
%Input:
%EEGSignals: the EEGSignals from which extracting the CSP features. These signals
%are a structure such that:
%   EEGSignals.x: 数据长度 x 通道数 x 总的trial次数
%              y：标签，1 x 总的trial次数
%              s：采样频率
%   CSPMatrix: the CSP projection matrix, learnt previously (see function learnCSP)
%   nbFilterPairs: number of pairs of CSP filters to be used. The number of
%   features extracted will be twice the value of this parameter. The
%   filters selected are the one corresponding to the lowest and highest
%   eigenvalues
%
%Output:
%features: the features extracted from this EEG data set 
%   as a [nbTrials * (nbFilterPairs*2 + 1)] matrix, with the class labels as the
%   last column   
%
% initializations

nbTrials = size(EEGSignals.x,3);
features = zeros(nbTrials, 2 * nbFilterPairs +1);%应该是不用加1
Filter = CSPMatrix([1:nbFilterPairs (end - nbFilterPairs + 1):end],:);

% extracting the CSP features from each trial
for t=1:nbTrials    
    %projecting the data onto the CSP filters    
    projectedTrial = Filter * EEGSignals.x(:, :, t)'; % [2 * nbFilterPairs, 数据长度]
    
    %generating the features as the log variance of the projectedsignals
    variances = var(projectedTrial,0, 2);  % [2 * nbFilterPairs, 1]
    
    for f = 1:length(variances)
        %features(t,f) = log(1+variances(f));
        % features(t,f) = log(variances(f));
         features(t, f) = log(variances(f) / sum(variances));
        
    end
end
end