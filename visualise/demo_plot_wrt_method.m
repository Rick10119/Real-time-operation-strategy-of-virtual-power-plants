% 虚拟电厂收益可视化
% 假设数据
purchaseCost = [15 12 18]; % 购电成本
frequencyRevenue = [8 6 9]; % 调频收益
responseCost = [4 2 5]; % 响应成本

% 计算总收益
totalRevenue = purchaseCost + frequencyRevenue - responseCost;

% 绘制收益组成部分的条形图
figure;
bar([frequencyRevenue; purchaseCost; -responseCost]', 0.4, 'stacked');
x1 = xlabel('Methods','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Income/Cost ($)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');
hold on;


ax = gca;
% ax.XLim = [0, 5];     
% ax.YLim = [-10000, 20000];

%% 右轴
yyaxis right
linewidth = 2;
ax = gca;
ax.YColor = 'black';
% 绘制总收益曲线
plot(totalRevenue, "-*g", 'LineWidth', 2);
legend('Income for Regulation', 'Energy Purchase Cost', 'Operational Cost',"VPP Profit",'fontsize',13.5, ...
   'Location','northwest', ...
'NumColumns', 2, ...
'FontName', 'Times New Roman'); 

% 可根据需要添加其他绘图设置和自定义内容
% 属性
%设置figure各个参数
x1 = xlabel('Methods','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('VPP Profit($)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');

% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

% 轴属性
ax = gca;
ax.XLim = [0.5, 3.5];     
% ax.YLim = [-2000, 4000];     
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
% ax.XTick = [1:16];

% 调整标签
ax.XTickLabel =  {'Proportional','Greedy','Optimal'};

% 调整图片整体截取的大小
set(gcf, 'PaperSize', [20, 10]);

% 

saveas(gcf, "profit_com_demo.pdf")
