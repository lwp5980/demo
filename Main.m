% 注：matlab下标从1开始
clc;
clear ;
close all;

%% 读入训练数据  
prefix = ('JKY\tr\');
d = dir([prefix,'*.mat']);
time = 4;        % 单次识别时长
offsetTime = 0;  % 计算偏移时间
freq = 500;      % 采样频率
totalFlt = [6, 30];  % 滤波频带
offlength = offsetTime * freq; 
select_channel = [1 3 4 5 6 7 8];  % 选择的通道
detrend_onoff=1;

v=[];
for j=1:length(d)  % 遍历每一个block
        data = load([prefix, d(j).name]);    
        data=data.DataOnline;
     for k = 1:12         % 遍历每一个trial
        % 滤波1
        select_data=data{k};
%         select_data=[1.25*select_data(1:1499,:);0.8*select_data(1500:2000,:);1.25*select_data(2001:2800,:)]
        select_data = preprocess(select_data', freq);
        % 滤波2
        [select_data] = preProccess(freq, time - offsetTime, select_data, totalFlt);
        Data(:, :, k) = select_data;  % 数据长度 x 通道数 x nb_trials
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
EEGSignals.x = DATA;  % DATA: 数据长度 x 通道数 x 一个被试总的trials
EEGSignals.y = LABEL; % LABEL：[1, trial的总次数]
EEGSignals.s = freq;
% 得到空间滤波器
CSPMatrix = learnCSP(EEGSignals, [1 2]);
% 计算特征
nbFilterPairs = 3;  % CSP特征选择参数m，CSP特征为2 * m 个
% 训练集特征：[trial总数, 2 * nbFilterPairs + 1], 最后一列其实没有用
TRAIN = extractCSP(EEGSignals, CSPMatrix, nbFilterPairs);  
% 模型训练
SVMStruct = fitcsvm(TRAIN(:, 1:2 * nbFilterPairs), LABEL');

%% 测试数据
prefix = ( 'JKY\te\');
e = dir([prefix,'*.mat']);
q=[];
for i=1:length(e)  % 遍历每一个block
        data = load([prefix, e(i).name]);    
        data=data.DataOnline;
    for k = 1:12        % 遍历每一个trial
        % 滤波1
        select_data=data{k};
        select_data = preprocess(select_data', freq);
        % 滤波2
        [select_data] = preProccess(freq, time - offsetTime, select_data, totalFlt);
        Data(:, :, k) = select_data;  % 数据长度 x 通道数 x nb_trials
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
    % 计算特征
    features = extractCSP(Signals, CSPMatrix, nbFilterPairs);
    % 分类
    Result(k) = predict(SVMStruct, features(1:2 * nbFilterPairs));
end

load 'JKY\label1'
test_label= label1;
disp('prediction, real')
[~, ok_pred] = find((test_label-Result)==0);    % ok_pred：预测正确的索引
acc = length(ok_pred) / length(test_label)
% itr = (60 / time) * (log2(2) + acc * log2(acc) + (1-acc) * log2((1-acc)/(2-1)));

% load 'D:\材料\博士论文\第一章\8导联博瑞康无线_随动座椅采集\DataSave\DYH\label1\'
%     test_label= label1
% disp('prediction, real')
% [Result; test_labels]';
%     load 'D:\材料\博士论文\第一章\8导联博瑞康无线_随动座椅采集\DataSave\DYH\label1\'
% [~, ok_pred] = label1;    % ok_pred：预测正确的索引
% acc = length(ok_pred) / length(test_labels);
% itr = (60 / time) * (log2(2) + acc * log2(acc) + (1-acc) * log2((1-acc)/(2-1)));
% disp(['accuracy=', num2str(acc)])
% disp(['itr=', num2str(itr)])
%% 模型保存
% trainModelPara.CSPMatrix = CSPMatrix;
% trainModelPara.nbFilterPairs = nbFilterPairs;
% trainModelPara.SVMStruct = SVMStruct;
% trainModelPara.srate = freq;
% trainModelPara.sampleTime = time - offsetTime;  % 真正用于处理的数据时长
% trainModelPara.totalFlt = totalFlt;
% save (['modelforPerson' num2str(currentPersonId) '.mat'],'trainModelPara')

