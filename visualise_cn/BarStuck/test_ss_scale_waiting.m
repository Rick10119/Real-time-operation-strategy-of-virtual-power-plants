A = [];
A0 = [];
A3 = [];

%% 理论时间
sigma2a = 0.974;
sigma2c = 0.148;
nofSlots = 6;
mu = 4;
tau = 30 * 60;
load('..\result\sim_steady_state_statistics_mtd.mat');
mean(sigmaArrivalTime);% 统计的充电时间相对方差
mean(sigmaChargingTime);% 统计的充电时间相对方差

for nofStations = [10 90 250]
    
    
    c = nofSlots * nofStations; % Slots
    
    
    w_GGc = [];
    
    for rho = [0.5 0.9]
        w_GGc = [w_GGc, tau * (rho/c/(1-rho)) * (sigma2a + sigma2c)/2];
    end
    
    A0 = [A0; w_GGc(end) - w_GGc(1)];
    
    
end


% 这个和上面的对的上吗？
    
%%



%% 先统计 rho = 0.5

%% scale = 1
Z = [];

% 最短行程时间-mtd
load('..\result\sim_steady_state_mtd.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(end-1)];

A = [A;Z];

%% scale = 3
Z = [];


% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(end)];

A = [A;Z];

%% scale = 5
Z = [];

% 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectWaitingTime;
Z = [Z, expectTime(end)];

A = [A;Z];



%% 寄存

width = 1;

A1 = A;

A = [];


%% scale = 1
Z = [];

% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(10)];

A = [A;Z];

%% scale = 3
Z = [];

% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectWaitingTime;
Z = [Z, expectTime(1)];

A = [A;Z];

%% scale = 5
Z = [];

% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectWaitingTime;

Z = [Z, expectTime(1)];

A = [A;Z];

A3 = 60 * [A1 - A];% 排队时间的增加

%% 调用roadTime,不过需要关掉图片
test_ss_scale_roadTime;
close;
A2 = 60 * [A1 - A];
A3 = [A0, A3, A2];
%% 画图

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
