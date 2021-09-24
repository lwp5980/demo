function CSPMatrix = learnCSP(EEGSignals,classLabels)

%Input:
% EEGSignals: the training EEG signals, composed of 2 classes. 
%       x: ���ݳ��� x ͨ���� x trial����
%       y: ��ǩ��1  x trial����
%       s: ����Ƶ��
% classLabels������ǩ[1, 2]

%Output:
%CSPMatrix: the learnt CSP filters (a [Nc*Nc] matrix with the filters as rows)
%
%See also: extractCSPFeatures

%check and initializations
Nc = size(EEGSignals.x,2);              % ͨ��
nbTrials = size(EEGSignals.x,3);        % ʵ�����
nbClasses = length(classLabels);        % ���

if nbClasses ~= 2
    disp('ERROR! CSP can only be used for two classes');
    return;
end


%% Ϊÿ������trial�����׼����Э�������
trialCov = zeros(Nc, Nc, nbTrials);
for i = 1:nbTrials
    E = EEGSignals.x(:, :, i)';   % ע��˴���ת�� 
    EE = E * E';
    trialCov(:, :, i) = EE ./ trace(EE);  % ����Э�������
end
clear E;
clear EE;

% ����ÿһ���������ݵĿռ�Э����֮��
covMatrices = cell(nbClasses,1); % ÿһ���Ӧ��Э�������Э�������Ĵ�С��ͨ���� x ͨ����
for c = 1:nbClasses 
    covMatrices{c} = mean(trialCov(:, :, EEGSignals.y == classLabels(c)),3);  %������ά�Ⱦ���ѡ���ԣ�ѡ���������lable��eegsignal.y�Ƿ����
end

% �����������ݵĿռ�Э����֮��
covTotal = covMatrices{1} + covMatrices{2};  % ����ͨ���� x ͨ���� Cc=C1+C2

%% ����CSPMatrix
[Ut Dt] = eig(covTotal); % ������������Dt����������Ut
eigenvalues = diag(Dt);
[eigenvalues egIndex] = sort(eigenvalues, 'descend');  % ����ֵҪ��������
Ut = Ut(:,egIndex);
P = diag(sqrt(1./eigenvalues)) * Ut';  % ����׻�

% ����P���ã��󹫹���������transformedCov1
transformedCov1 =  P * covMatrices{1} * P';

% ���㹫����������transformedCov1��������������������
[U1 D1] = eig(transformedCov1);
eigenvalues = diag(D1);
[eigenvalues egIndex] = sort(eigenvalues, 'descend'); % ��������
U1 = U1(:, egIndex);
CSPMatrix = U1' * P; % ����ͶӰ����W����CSPMatrix����СΪ��ͨ���� x ͨ����
end