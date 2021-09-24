function data = preprocess(data, srate)
% ���룺data��ͨ���� x ���ݳ���
%       srate������Ƶ��
% ���أ�data��ͨ���� x ���ݳ���

%% �ӱ�����������AlgorithmImplement.m����ȡ��preprocessFilter����
Fo = 50;
Q = 35;
BW = (Fo / (srate / 2)) / Q;
[preprocessFilter.B,preprocessFilter.A] = iircomb(srate / Fo, BW, 'notch');   

%% �ӱ�����������AlgorithmImplement.m����ȡ��preprocess����
data = filtfilt(preprocessFilter.B, preprocessFilter.A, data.');
data = data.';

end