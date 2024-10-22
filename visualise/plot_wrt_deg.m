%% 不同老化因子下，各方法对应的聚合商收益情况

A = [];
B = [];
% 按比例分配
load("../results/result_prop_ctrl_sep_deg.mat");
A = [A; result.ProfitCompare + result.actualCostCompare];
B = [B; result.actualCostCompare];

% 按当下最小老化成本分配
load("../results/result_tx_optimal_bid_ctrl_sep_deg.mat");
A = [A; result.ProfitCompare + result.actualCostCompare];
B = [B; result.actualCostCompare];

% 所提机制
load("../results/result_optimal_bid_ctrl_deg.mat");
A = [A; result.ProfitCompare + result.actualCostCompare];
B = [B; result.actualCostCompare];

% 但是这里是累加的，需要修改


%%

close;
linewidth = 1;
% 利润
plot(1:5, A(1, :), "-og", 'linewidth', linewidth);hold on;
plot(1:5, A(2, :), "-xb", 'linewidth', linewidth);
plot(1:5, A(3, :), "-<r", 'linewidth', linewidth);

% 成本
plot(1:5, B(1, :), "--og", 'linewidth', linewidth);
plot(1:5, B(2, :), "--xb", 'linewidth', linewidth);
plot(1:5, B(3, :), "--<r", 'linewidth', linewidth);

legend('Income-Proportional', ...
'Income-Greedy', ...
'Income-Optimal', ...
'Cost-Proportional', ...
'Cost-Greedy', ...
'Cost-Optimal', ...
'fontsize',13.5, ...
'Location','NorthOutside', ...
'Orientation','horizontal', ...
'NumColumns', 3, ...
'FontName', 'Times New Roman'); 

%% 属性
%设置figure各个参数
x1 = xlabel('Ratio of Degradation Price','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Market Income / Operational Cost ($)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');


%% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2.35 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

%% 轴属性
ax = gca;
ax.XLim = [0.5, 5.5];     
% ax.YLim = [30, 50];     
% 字体与大小

ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [1 : 5];

% 调整标签
ax.XTickLabel =  {'0.25 Times','0.5 Times','Defualt Value','2 Times','4 Times'};
ax.FontName = 'Times New Roman';

set(gca, "YGrid", "on");
% set(gca, "ylim", [-10, 10]);
set(gcf, 'PaperSize', [18.5, 12]);


saveas(gcf,'wtr_deg.pdf');

