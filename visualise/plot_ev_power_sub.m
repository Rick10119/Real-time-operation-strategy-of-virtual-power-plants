ev_id = 100;
% ev_id = 213;

% hour = 13;
linewidth = 2;



%% 画交换电量
close;
smooth;hold on;

barwidth = 0.75;

bar(ev_ch, barwidth);
bar(ev_dis, barwidth);

% set(gca, "ylim", [-8, 4]);
% 属性
%设置figure各个参数
x1 = xlabel('Hour','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('(Dis)charged Electricity (kWh)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');



%% 画电池电量（右轴）
yyaxis right
plot(ev_e, 'g', 'linewidth', linewidth);
ax = gca;
ax.YColor = 'black';

% 扩大范围
% ax.YLim = [0 90];
% 只保留三分之一的右Y轴刻度便可
% ax.YTick = [0 : 2 : 13.5];

legend('Charged Electricity','Discharged Electricity','Battery SOC','fontsize',13.5, ...
    'Location',lc, ...
'Orientation','vertical', ...
'FontName', 'Times New Roman');


% 属性
%设置figure各个参数
x1 = xlabel('Hour','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Battery SOC (kWh)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');


% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

% 轴属性
ax = gca;
ax.XLim = [0, 17];     
ax.YLim = [0, 90];     
% 字体与大小
ax.FontName ='Times New Roman';
ax.FontSize = 12.5;

% 设置刻度
ax.XTick = [1:16];

% 调整标签
ax.XTickLabel =  {'18','19','20','21','22','23','24','1','2','3','4','5','6','7','8','9'};

set(gca, "YGrid", "on");
set(gcf, 'PaperSize', [19, 10]);


