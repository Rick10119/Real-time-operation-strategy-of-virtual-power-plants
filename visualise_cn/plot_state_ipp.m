%% 空调
%% 找一个状态量来看看情况。最后物料
id = 135;linewidth = 1.5;

range = 60*16 : 60*24;

load("../results/result_prop_ctrl_sep_21.mat");

plot(result.E_rev(id, range), 'g', 'linewidth', linewidth); hold on

load("../results/result_tx_optimal_bid_ctrl_sep_21.mat");

plot(result.E_rev(id, range), 'b', 'linewidth', linewidth);

load("../results/result_optimal_bid_ctrl_sep_21.mat");

plot(result.E_rev(id, range), 'r', 'linewidth', linewidth); hold off


% 设置
y1 = ylabel('最终产品 (吨)','FontSize',13.5,'FontName', '宋体','FontWeight','bold');

set(gca, "YGrid", "on");

%设置figure各个参数
x1 = xlabel('小时','FontSize',13.5,'FontName', '宋体','FontWeight','bold');          %轴标题可以用tex解释


legend('比例简化','贪心算法','所提方法','fontsize',12, ...
    'Location','NorthOutside', ...
'Orientation','Horizontal', ...
'FontName', '宋体'); 

%% 图片大小
figureUnits = 'centimeters';
figureWidth = 15;
figureHeight = 10;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

%% 轴属性
ax = gca;
ax.XLim = [0, 60 * 8];     
  
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [0 : 60 : 540];

% 调整标签
ax.XTickLabel =  {'16','17','18','19','20','21','22','23','24'};
ax.FontName = '宋体';
set(gcf, 'PaperSize', [15, 10]);

saveas(gcf,'state_ipp.pdf');
