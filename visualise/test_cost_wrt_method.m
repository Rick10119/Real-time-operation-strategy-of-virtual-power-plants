%% 测试第一次投标时对利润的估计

close;

M = 1e3;% 大数
diff = 0.1;

  
    cd data_prepare
    data_prepare;
    cd ..
    
    Profit_comp = [];
    Cost_comp = [];
    Bid_P_comp = [];
    Bid_R_comp = [];
    
    % 更新步长
    NOFTCAP = 900;
    
    % 所提机制
    cd my_alloc
    % 初始时段
    warning('off')
    t_cap = 0;
    maxProfit_1;
    
    
    Cost_comp = [Cost_comp, value(sum(sum(param.hourly_Distribution .* Cost_deg)))];
    Profit_comp = [Profit_comp, value(Profit) - value(sum(sum(param.hourly_Distribution .* Cost_deg)))];
    cd ..
    
    % 按比例分配
    cd proportional_alloc
    maxProfit_1;
    Cost_comp = [Cost_comp, value(sum(sum(param.hourly_Distribution .* Cost_deg)))];
    Profit_comp = [Profit_comp, value(Profit) - value(sum(sum(param.hourly_Distribution .* Cost_deg)))];
    
    cd ..
    
    
    
    % 利润
    revenue = Profit_comp - Cost_comp;
    total_revenue = revenue;
    total_profit = Profit_comp;
    total_cost = Cost_comp;
    
total_table = [total_profit; total_cost; total_revenue]'


% save("results/total_table_method.mat", "total_table","Profit_comp","Cost_comp", ...
%     "Bid_P_comp", "Bid_R_comp");
% save("results/total_table_method.mat", "Profit_wrt_day","Cost_wrt_day","Revenue_wrt_day");
%%

linewidth = 1;

% cd my_alloc_intervals;
% test;

%% 逐小时的收益

% % 最大容量
% % EV
% plot(1:16, Profit_comp, 'linewidth', linewidth);hold on;
% plot(1:16, Cost_comp, '--', 'linewidth', linewidth);
%
%
% legend('所提机制收入','比例分配收入','启发权重收入','最小老化收入','所提机制成本', ...
%     '比例分配成本','启发权重成本','最小老化成本','fontsize',12); %,'主网购电'
% % set(gca, "YGrid", "on");
% % set(gca, "XGrid", "on");
% % % set(gca,'GridLineStyle',':');
% % set(gca, "xlim", [0, 24]);
% % set(gca, "ylim", [0, 150]);
%
% %设置figure各个参数
% x1 = xlabel('hour','FontSize',15);          %轴标题可以用tex解释
% y1 = ylabel('$','FontSize',15);
%
% x1.FontName = '宋体';
% y1.FontName = '宋体';
%
% % m=linspace(datenum("-1",'HH'),datenum("24",'HH'),6);
% % % set(gca,'xtick',2:0.2:3);
% % for n=1:length(m)
% %   tm{n}=datestr(m(n),'HH:MM');
% % end
% % set(gca,'xticklabel',tm);
%
% saveas(gcf,'收入成本.jpg');
%
%% 逐小时的投标
% close;
% % 最大容量
% % EV
% plot(1:16, Bid_P_comp, 'linewidth', linewidth);hold on;
% plot(1:16, Bid_R_comp, '--', 'linewidth', linewidth);
%
%
% legend('所提机制能量','比例分配能量','启发权重能量','最小老化能量', ...
%     '所提机制调频容量','比例分配调频容量','启发权重调频容量','最小老化调频容量','fontsize',12); %,'主网购电'
% % set(gca, "YGrid", "on");
% % set(gca, "XGrid", "on");
% % % set(gca,'GridLineStyle',':');
% % set(gca, "xlim", [0, 24]);
% % set(gca, "ylim", [0, 150]);
%
% %设置figure各个参数
% x1 = xlabel('hour','FontSize',15);          %轴标题可以用tex解释
% y1 = ylabel('MW','FontSize',15);
%
% x1.FontName = '宋体';
% y1.FontName = '宋体';
%
% saveas(gcf,'投标量.jpg');
