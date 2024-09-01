%% 画一个图形摘要
close;
% 立即成本
p_base = [0, 1.2, 1.8, 2.8, 4, 5];
c_imm = [1.2, 1, 2, 2.5, 2.0];

% 对未来的影响
c_total = [2, 2.4, 2.8, 3.2, 3.6];

x = [p_base(1), reshape(repmat(p_base(2:end-1), 2, 1), 1, 8), p_base(end)];
y_imm = reshape(repmat(c_imm, 2, 1), 1, 10);
y_total = reshape(repmat(c_total, 2, 1), 1, 10);
% 绘制供给曲线的台阶图
figure;
hold on;

% 绘制基准供给线
area(x, [y_imm; y_total - y_imm]');

linewidth = 3;
plot(x, y_total, "-m", 'linewidth', linewidth);
% 基准功率曲线
linewidth = 2;
plot([2.5, 2.5], [0, 4.5], "--b", 'linewidth', linewidth);

% 要求调整的功率
plot([3.5, 3.5], [0, 4.5], "-g", 'linewidth', linewidth);

% 最优运行点
plot([3.5], [3.2], "og", 'linewidth', 5);

% 补上划分的线
for idx = 2 : 2 : 8
    plot([x(idx), x(idx)], [0, y_total(idx)], 'w', 'linewidth', 1.5);
end

% 图例
legend('Immediate cost','Impact on future profit','Total cost curve', ...
    'Baseline output', "Required adjustment", "Optimal operation point", ...
'fontsize',13.5, ...
    'Location','Northwest', ...
'Orientation','horizontal', ...
'NumColumns', 1, ...
'FontName', 'Times New Roman'); 

% 设置坐标轴范围
xlim([0, 5]);
ylim([0, 5]);

%设置figure各个参数
x1 = xlabel('Adjusted power of the resources','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Marginal cost for power adjustment','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');


%% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2.35 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

    
  % 轴属性
ax = gca;
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
ax.XTick = 0.5 * (p_base(1 : end - 1) + p_base(2 : end));
ax.YTick = c_total;

% 调整标签
ax.XTickLabel =  {'\Delta p_1','\Delta p_2','\Delta p_3','\Delta p_4','\Delta p_5'};
ax.YTickLabel =  {'c_1','c_2','c_3','c_4','c_5'};
ax.FontName = 'Times New Roman';
% set(gca, "ylim", [-10, 10]);
set(gcf, 'PaperSize', [18.5, 12]);

saveas(gcf,'graph_abstract.pdf');


