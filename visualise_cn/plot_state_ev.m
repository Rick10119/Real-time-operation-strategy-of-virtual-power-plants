%% 找一个状态量来看看情况。电动汽车的
id = 100;linewidth = 1.5;

range = 540:60*17;

load("../results/result_prop_ctrl_sep_21.mat");

plot(1e3 * result.E_rev(id, range), 'g', 'linewidth', linewidth); hold on

load("../results/result_tx_optimal_bid_ctrl_sep_21.mat");

plot(1e3 * result.E_rev(id, range), 'b', 'linewidth', linewidth);

load("../results/result_optimal_bid_ctrl_sep_21.mat");

plot(1e3 * result.E_rev(id, range), 'r', 'linewidth', linewidth); hold off


% 设置
y1 = ylabel('电动汽车电池电量 (kWh)','FontSize',13.5,'FontName', '宋体','FontWeight','bold');

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
ax.XTickLabel =  {'9','10','11','12','13','14','15','16','17'};
ax.FontName = '宋体';
set(gcf, 'PaperSize', [15, 10]);

saveas(gcf,'state_ev.pdf');




