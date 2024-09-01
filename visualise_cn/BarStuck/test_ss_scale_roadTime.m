A = [];


%% scale = 1
Z = [];

% 最短行程时间-mtd
load('..\result\sim_steady_state_mtd.mat');
expectTime = expectRoadTime;
Z = [Z, expectTime(end-1)];

A = [A;Z];

%% scale = 3
Z = [];


% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectRoadTime;
Z = [Z, expectTime(end)];

A = [A;Z];

%% scale = 5
Z = [];

% 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectRoadTime;
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
expectTime = expectRoadTime;
Z = [Z, expectTime(10)];

A = [A;Z];

%% scale = 3
Z = [];

% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectRoadTime;
Z = [Z, expectTime(1)];

A = [A;Z];

%% scale = 5
Z = [];

% 画queryTime的9站， 最短行程时间-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectRoadTime;

Z = [Z, expectTime(1)];

A = [A;Z];

%% 画图


width = 1;
A2 = 60 * [A, A1];
bar(A2, width);
set(gca,'xticklabel',{'1 time','3 times','5 times'});
legend("\rho = 0.5",'\rho = 0.9');
 x1 = xlabel('Scale of Map','FontSize',18);          
y1 = ylabel({['Average Road Time']; ['(Seconds)']},'FontSize',18);
% set(gca, "XGrid", "on");
set(gca, "YGrid", "on");
set(gca,'linewidth',1.5,'fontsize',18);

saveas(gcf,'f4_scale_road_time.jpg');

