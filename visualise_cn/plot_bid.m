%% 逐小时的收益
close; clc;
% cost_wrt_method;

linewidth = 1.3;

% 调整后调频容量
stairs([Bid_R_comp(:, 6); Bid_R_comp(end, 6)] ...
    , "-g", 'linewidth', linewidth);hold on;
stairs([Bid_R_comp(:, 12); Bid_R_comp(end, 12)] ...
    , "-b", 'linewidth', linewidth);
stairs([Bid_R_comp(:, 18); Bid_R_comp(end, 18)] ...
    , "-r", 'linewidth', linewidth);
% 实际能量

linewidth = 1.1;
temp = 1:24;
b = bar([actualEnergy_comp(:, 6), actualEnergy_comp(:, 12), actualEnergy_comp(:, 18)], linewidth);hold on;
set(b(1), 'facecolor', [[0 1 0]]);
set(b(2), 'facecolor', [[0 0 1]]);
set(b(3), 'facecolor', [[1 0 0]]);
set (b, 'edgecolor', [1,1,1])


legend('调频容量-比例简化', ...
'调频容量-贪心算法', ...
'调频容量-所提方法', ...
'购入电量-比例简化', ...
'购入电量-贪心算法', ...
'购入电量-所提方法', ...
'fontsize',13.5, ...
'Location','NorthOutside', ...
'Orientation','vertical', ...
'NumColumns', 2); 
set(gca, "YGrid", "on");

%设置figure各个参数
x1 = xlabel('小时','FontSize',13.5,'FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('投标容量 (MW)','FontSize',13.5,'FontWeight','bold');


%% 图片大小
figureUnits = 'centimeters';
figureWidth = 15;
figureHeight = 10;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

%% 轴属性
ax = gca;
ax.XLim = [0, 25];    
% ax.YLim = [-3, 3]; 
% ax.YLim = [30, 50];     
% 字体与大小

ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [1:24];
% ax.YTick = [-3:3];

% 调整标签
% ax.XTickLabel =  {'18','19','20','21','22','23','24','1','2','3','4','5','6','7','8','9'};
ax.FontName = '宋体';
% ax.FontName = 'Times New Roman';
set(gcf, 'PaperSize', [15, 10]);


saveas(gcf,'bids.pdf');