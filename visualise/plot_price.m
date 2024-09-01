%% 逐小时的价格
close;
diff = 0.1;

%%
linewidth = 2;

% 实际能量
plot(param.price_e, "-r", 'linewidth', linewidth);hold on;

y1 = ylabel('Energy Price ($/MWh)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');
% ax.YLim = [0, 90];     
% 画电池电量（右轴）
yyaxis right


% ax.YLim = [0, 90];     
plot(param.price_reg(:, 1), "--g", 'linewidth', linewidth);
plot(param.price_reg(:, 2) * 50, "--b", 'linewidth', linewidth);

ax = gca;
ax.YColor = 'black';

legend('Energy','Regulation Capacity','Regulation Mileage(×50)','fontsize',13.5, ...
    'Location','NorthOutside', ...
'Orientation','vertical', ...
'NumColumns', 2, ...
'FontName', 'Times New Roman'); 
set(gca, "YGrid", "on");

%设置figure各个参数
x1 = xlabel('Hour','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Regulation Price ($/MW)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');



%% 图片大小
figureUnits = 'centimeters';
figureWidth = 15;
figureHeight = 10;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

%% 轴属性
ax = gca;
ax.XLim = [0, 25];     
  
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [1:24];

% 调整标签
% ax.XTickLabel =  {'18','19','20','21','22','23','24','1','2','3','4','5','6','7','8','9'};
ax.FontName = 'Times New Roman';
set(gcf, 'PaperSize', [15, 10]);

saveas(gcf,'price.pdf');