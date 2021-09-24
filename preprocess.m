function data = preprocess(data, srate)
% 输入：data，通道数 x 数据长度
%       srate，采样频率
% 返回：data，通道数 x 数据长度

%% 从比赛主程序中AlgorithmImplement.m中提取的preprocessFilter函数
Fo = 50;
Q = 35;
BW = (Fo / (srate / 2)) / Q;
[preprocessFilter.B,preprocessFilter.A] = iircomb(srate / Fo, BW, 'notch');   

%% 从比赛主程序中AlgorithmImplement.m中提取的preprocess函数
data = filtfilt(preprocessFilter.B, preprocessFilter.A, data.');
data = data.';

end