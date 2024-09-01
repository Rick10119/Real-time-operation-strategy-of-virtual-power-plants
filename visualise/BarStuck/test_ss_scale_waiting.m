A = [];
A0 = [];
A3 = [];

%% ����ʱ��
sigma2a = 0.974;
sigma2c = 0.148;
nofSlots = 6;
mu = 4;
tau = 30 * 60;
load('..\result\sim_steady_state_statistics_mtd.mat');
mean(sigmaArrivalTime);% ͳ�Ƶĳ��ʱ����Է���
mean(sigmaChargingTime);% ͳ�Ƶĳ��ʱ����Է���

for nofStations = [10 90 250]
    
    
    c = nofSlots * nofStations; % Slots
    
    
    w_GGc = [];
    
    for rho = [0.5 0.9]
        w_GGc = [w_GGc, tau * (rho/c/(1-rho)) * (sigma2a + sigma2c)/2];
    end
    
    A0 = [A0; w_GGc(end) - w_GGc(1)];
    
    
end


% ���������ĶԵ�����
    
%%



%% ��ͳ�� rho = 0.5

%% scale = 1
Z = [];

% ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(end-1)];

A = [A;Z];

%% scale = 3
Z = [];


% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(end)];

A = [A;Z];

%% scale = 5
Z = [];

% ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectWaitingTime;
Z = [Z, expectTime(end)];

A = [A;Z];



%% �Ĵ�

width = 1;

A1 = A;

A = [];


%% scale = 1
Z = [];

% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(10)];

A = [A;Z];

%% scale = 3
Z = [];

% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(1)];

A = [A;Z];

%% scale = 5
Z = [];

% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectWaitingTime;

Z = [Z, expectTime(1)];

A = [A;Z];

A3 = 60 * [A1 - A];% �Ŷ�ʱ�������

%% ����roadTime,������Ҫ�ص�ͼƬ
test_ss_scale_roadTime;
close;
A2 = 60 * [A1 - A];
A3 = [A0, A3, A2];
%% ��ͼ

width = 1;

bar(A3, width);
set(gca,'xticklabel',{'1 time','3 times','5 times'});
set(gca, 'ylim',[0 200]);
legend("Estimated waiting time","Average waiting time",'Average travelling time');
 x1 = xlabel('Scale of Map','FontSize',18);          
y1 = ylabel({['Average Time Increase']; ['(Seconds)']},'FontSize',18);
% set(gca, "XGrid", "on");
set(gca, "YGrid", "on");
set(gca,'linewidth',1.5,'fontsize',18);

saveas(gcf,'f5_scale_waiting_time.jpg'); %
