function CSPMatrix = learnCSP(EEGSignals,classLabels)

%Input:
% EEGSignals: the training EEG signals, composed of 2 classes. 
%       x: 数据长度 x 通道数 x trial次数
%       y: 标签，1  x trial次数
%       s: 采样频率
% classLabels：类别标签[1, 2]

%Output:
%CSPMatrix: the learnt CSP filters (a [Nc*Nc] matrix with the filters as rows)
%
%See also: extractCSPFeatures

%check and initializations
Nc = size(EEGSignals.x,2);              % 通道
nbTrials = size(EEGSignals.x,3);        % 实验次数
nbClasses = length(classLabels);        % 类别

if nbClasses ~= 2
    disp('ERROR! CSP can only be used for two classes');
    return;
end


%% 为每个试验trial计算标准化的协方差矩阵
trialCov = zeros(Nc, Nc, nbTrials);
for i = 1:nbTrials
    E = EEGSignals.x(:, :, i)';   % 注意此处的转置 
    EE = E * E';
    trialCov(:, :, i) = EE ./ trace(EE);  % 计算协方差矩阵
end
clear E;
clear EE;

% 计算每一类样本数据的空间协方差之和
covMatrices = cell(nbClasses,1); % 每一类对应的协方差矩阵，协方差矩阵的大小：通道数 x 通道数
for c = 1:nbClasses 
    covMatrices{c} = mean(trialCov(:, :, EEGSignals.y == classLabels(c)),3);  %第三个维度具有选择性，选择的依据是lable与eegsignal.y是否相等
end

% 计算两类数据的空间协方差之和
covTotal = covMatrices{1} + covMatrices{2};  % 矩阵：通道数 x 通道数 Cc=C1+C2

%% 计算CSPMatrix
[Ut Dt] = eig(covTotal); % 计算特征向量Dt和特征矩阵Ut
eigenvalues = diag(Dt);
[eigenvalues egIndex] = sort(eigenvalues, 'descend');  % 特征值要降序排列
Ut = Ut(:,egIndex);
P = diag(sqrt(1./eigenvalues)) * Ut';  % 矩阵白化

% 矩阵P作用：求公共特征向量transformedCov1
transformedCov1 =  P * covMatrices{1} * P';

% 计算公共特征向量transformedCov1的特征向量和特征矩阵
[U1 D1] = eig(transformedCov1);
eigenvalues = diag(D1);
[eigenvalues egIndex] = sort(eigenvalues, 'descend'); % 降序排列
U1 = U1(:, egIndex);
CSPMatrix = U1' * P; % 计算投影矩阵W，即CSPMatrix，大小为：通道数 x 通道数
end