function [bandPassData] = preProccess(Fs,windowLength,rawData,totalFlt)
%PREPROCCESS Ԥ����ͨ��ѡ��ȥ����Ư�ơ���ͨ�˲���
%   INPUT:  Fs            ������
%           windowLength            ���β���ʱ��
%           rawData       ԭʼ�Ե����ݣ� ͨ���� x ���ݳ���
%           chanSelect    ͨ��ѡ��
%           totalFlt      �ܵ��˲�Ƶ��ѡ��
%   OUTPUT: bandPassData  Ԥ������Ե����ݣ� ���ݳ��� x ͨ����
trialDataNum = Fs*windowLength;
cnt = rawData';
rawData1=double(cnt);
%% ȥ����Ư��
for i = 1:size(rawData1,1)/trialDataNum%size(x,n)����x�����n��ά�ȵĳ���
    data1 = rawData1((i-1)*trialDataNum+1:i*trialDataNum,:);
    detrendData((i-1)*trialDataNum+1:i*trialDataNum,:) = detrend(data1);
end

%% ��ͨ�˲�
Wn1 = [totalFlt(1)*2 totalFlt(2)*2]/Fs;
[BB1,AA1] = butter(3,Wn1);  %6�ף�4-40Hz��ͨ
for i=1:size(detrendData,1)/trialDataNum
    data1 = detrendData((i-1)*trialDataNum+1:i*trialDataNum,:);
    bandPassData((i-1)*trialDataNum+1:i*trialDataNum,:) = filter(BB1,AA1,data1);
end

end