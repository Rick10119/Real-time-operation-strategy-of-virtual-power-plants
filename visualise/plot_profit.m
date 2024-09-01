%% 逐小时的投标
close; clc;
% cost_wrt_method;

linewidth = 1.3;


% 逐小时收益

linewidth = 1.1;
temp = 1:24;
b = bar([revenue(:, 6), revenue(:, 12), revenue(:, 18)], linewidth);hold on;
set(b(1), 'facecolor', [[0 1 0]]);
set(b(2), 'facecolor', [[0 0 1]]);
set(b(3), 'facecolor', [[1 0 0]]);
set (b, 'edgecolor', [1,1,1])


legend('Proportional', ...
'Greedy', ...
'Optimal', ...
'fontsize',13.5, ...
'Location','NorthOutside', ...
'Orientation','horizontal', ...
'FontName', 'Times New Roman'); 
set(gca, "YGrid", "on");

%设置figure各个参数
x1 = xlabel('Hour','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Hourly VPP Profits ($)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');


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
ax.FontName = 'Times New Roman';
% ax.FontName = 'Times New Roman';
set(gcf, 'PaperSize', [15, 10]);


saveas(gcf,'profits.pdf');