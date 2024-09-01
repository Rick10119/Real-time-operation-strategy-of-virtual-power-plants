A = [];


%% scale = 1
Z = [];

% ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd.mat');
expectTime = expectRoadTime;
Z = [Z, expectTime(end-1)];

A = [A;Z];

%% scale = 3
Z = [];


% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectRoadTime;
Z = [Z, expectTime(end)];

A = [A;Z];

%% scale = 5
Z = [];

% ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectRoadTime;
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
expectTime = expectRoadTime;
Z = [Z, expectTime(10)];

A = [A;Z];

%% scale = 3
Z = [];

% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_3times.mat');
expectTime = expectRoadTime;
Z = [Z, expectTime(1)];

A = [A;Z];

%% scale = 5
Z = [];

% ��queryTime��9վ�� ����г�ʱ��-mtd
load('..\result\sim_steady_state_mtd_5times.mat');

expectTime = expectRoadTime;

Z = [Z, expectTime(1)];

A = [A;Z];

%% ��ͼ


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

