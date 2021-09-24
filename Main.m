% ע��matlab�±��1��ʼ
clc;
clear ;
close all;

%% ����ѵ������  
prefix = ('JKY\tr\');
d = dir([prefix,'*.mat']);
time = 4;        % ����ʶ��ʱ��
offsetTime = 0;  % ����ƫ��ʱ��
freq = 500;      % ����Ƶ��
totalFlt = [6, 30];  % �˲�Ƶ��
offlength = offsetTime * freq; 
select_channel = [1 3 4 5 6 7 8];  % ѡ���ͨ��
detrend_onoff=1;

v=[];
for j=1:length(d)  % ����ÿһ��block
        data = load([prefix, d(j).name]);    
        data=data.DataOnline;
     for k = 1:12         % ����ÿһ��trial
        % �˲�1
        select_data=data{k};
%         select_data=[1.25*select_data(1:1499,:);0.8*select_data(1500:2000,:);1.25*select_data(2001:2800,:)]
        select_data = preprocess(select_data', freq);
        % �˲�2
        [select_data] = preProccess(freq, time - offsetTime, select_data, totalFlt);
        Data(:, :, k) = select_data;  % ���ݳ��� x ͨ���� x nb_trials
     end
        a=Data;
%         cat(3,data{1}(1000:2499,:),data{2}(1000:2499,:),data{3}(1000:2499,:),data{4}(1000:2499,:),data{5}(1000:2499,:),data{6}(1000:2499,:),data{7}(1000:2499,:),data{8}(1000:2499,:),data{9}(1000:2499,:),data{10}(1000:2499,:),data{11}(1000:2499,:),data{12}(1000:2499,:));
%       v(:,:,:,i)=a;
        v=cat(3,v,a);
end 
    DATA = v;  
    load 'JKY\label'
    LABEL = label;

clear data;
clear Data;
clear select_data;

%% CSP
EEGSignals.x = DATA;  % DATA: ���ݳ��� x ͨ���� x һ�������ܵ�trials
EEGSignals.y = LABEL; % LABEL��[1, trial���ܴ���]
EEGSignals.s = freq;
% �õ��ռ��˲���
CSPMatrix = learnCSP(EEGSignals, [1 2]);
% ��������
nbFilterPairs = 3;  % CSP����ѡ�����m��CSP����Ϊ2 * m ��
% ѵ����������[trial����, 2 * nbFilterPairs + 1], ���һ����ʵû����
TRAIN = extractCSP(EEGSignals, CSPMatrix, nbFilterPairs);  
% ģ��ѵ��
SVMStruct = fitcsvm(TRAIN(:, 1:2 * nbFilterPairs), LABEL');

%% ��������
prefix = ( 'JKY\te\');
e = dir([prefix,'*.mat']);
q=[];
for i=1:length(e)  % ����ÿһ��block
        data = load([prefix, e(i).name]);    
        data=data.DataOnline;
    for k = 1:12        % ����ÿһ��trial
        % �˲�1
        select_data=data{k};
        select_data = preprocess(select_data', freq);
        % �˲�2
        [select_data] = preProccess(freq, time - offsetTime, select_data, totalFlt);
        Data(:, :, k) = select_data;  % ���ݳ��� x ͨ���� x nb_trials
    end
        b=Data;
%         cat(3,data{1}(1000:2499,:),data{2}(1000:2499,:),data{3}(1000:2499,:),data{4}(1000:2499,:),data{5}(1000:2499,:),data{6}(1000:2499,:),data{7}(1000:2499,:),data{8}(1000:2499,:),data{9}(1000:2499,:),data{10}(1000:2499,:),data{11}(1000:2499,:),data{12}(1000:2499,:));
        q=cat(3,q,b);
end 

%     test_Data(:, :, i) = q;
%     Signals.x = test_Data(:,:,i);

for k=1:size(q,3)
    Signals.x = q(:,:,k);
    Signals.y = 0;
    Signals.s = freq;
    % ��������
    features = extractCSP(Signals, CSPMatrix, nbFilterPairs);
    % ����
    Result(k) = predict(SVMStruct, features(1:2 * nbFilterPairs));
end

load 'JKY\label1'
test_label= label1;
disp('prediction, real')
[~, ok_pred] = find((test_label-Result)==0);    % ok_pred��Ԥ����ȷ������
acc = length(ok_pred) / length(test_label)
% itr = (60 / time) * (log2(2) + acc * log2(acc) + (1-acc) * log2((1-acc)/(2-1)));

% load 'D:\����\��ʿ����\��һ��\8������������_�涯���βɼ�\DataSave\DYH\label1\'
%     test_label= label1
% disp('prediction, real')
% [Result; test_labels]';
%     load 'D:\����\��ʿ����\��һ��\8������������_�涯���βɼ�\DataSave\DYH\label1\'
% [~, ok_pred] = label1;    % ok_pred��Ԥ����ȷ������
% acc = length(ok_pred) / length(test_labels);
% itr = (60 / time) * (log2(2) + acc * log2(acc) + (1-acc) * log2((1-acc)/(2-1)));
% disp(['accuracy=', num2str(acc)])
% disp(['itr=', num2str(itr)])
%% ģ�ͱ���
% trainModelPara.CSPMatrix = CSPMatrix;
% trainModelPara.nbFilterPairs = nbFilterPairs;
% trainModelPara.SVMStruct = SVMStruct;
% trainModelPara.srate = freq;
% trainModelPara.sampleTime = time - offsetTime;  % �������ڴ��������ʱ��
% trainModelPara.totalFlt = totalFlt;
% save (['modelforPerson' num2str(currentPersonId) '.mat'],'trainModelPara')

