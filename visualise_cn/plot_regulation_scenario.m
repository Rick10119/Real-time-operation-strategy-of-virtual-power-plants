%% 某小时的调频信号场景分布
close;

test_forecast;% 找到预测最好的那个时段

% diff = 0.1;
% if ~exist('param')
% cd ../data_prepare
% data_prepare;
% cd ../results
% end

%%
barwidth = 1;

% 实际
A = [hourly_Distribution(hour, :)', param.hourly_Distribution(hour, :)'];
bar(A, barwidth);



legend('实际出现频次比率','预测概率','fontsize',13.5, ...
    'Location','NorthWest', ...
'Orientation','vertical', ...
'FontName', '宋体'); 
set(gca, "YGrid", "on");

%设置figure各个参数
x1 = xlabel('调频信号场景','FontSize',13.5,'FontName', '宋体','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('预测概率/出现频率','FontSize',13.5,'FontName', '宋体','FontWeight','bold');



%% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

%% 轴属性
ax = gca;
ax.XLim = [0.5, 22.5];     
  
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [1:22];

% 调整标签
ax.XTickLabel =  {'-1','(-1, -0.9]','(-0.9,0.8]','(-0.8,0.7]','(-0.7,0.6]','(-0.6,0.5]','(-0.5,0.4]','(-0.4,0.3]','(-0.3,0.2]','(-0.2,0.1]','(-0.1,0.0)', ...
    '[0.0,0.1)','[0.1,0.2)','[0.2,0.3)','[0.3,0.4)','[0.4,0.5)','[0.5,0.6)','[0.6,0.7)','[0.7,0.8)','[0.8,0.9)','[0.9,1)','1'};
ax.FontName = '宋体';
set(gcf, 'PaperSize', [20, 10]);



saveas(gcf,'scenario.pdf');

%% 直接画出调频信号的样子
hour = 11;

plot(signals((hour - 0.5) * 1800 + 1 : hour * 1800), LineWidth=1.5);

x1 = xlabel('时间','FontSize',13.5,'FontName', '宋体','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('调频信号取值','FontSize',13.5,'FontName', '宋体','FontWeight','bold');
ax = gca;
ax.YTick = [-1 : 0.1 : 1];
ax.XTick = [0 : 300 : 1800];


% legend('风电+光伏','EV','ES','总调整量','边际价格(向上)','边际价格(向下)','fontsize',12); %,'主网购电'

set(gca, "YGrid", "on");
% set(gca, "ylim", [-100, 100]);
% set(gca,'GridLineStyle',':');

m=linspace(datenum(hour - 1 + ":30",'HH:MM'),datenum(hour  + ":00",'HH:MM'), 4);
% set(gca,'xtick',2:0.2:3);
for n=1:length(m)
    tm{n}=datestr(m(n),'HH:MM');
end
set(gca,'xticklabel',tm);

% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

% 调整标签
% ax.XTickLabel =  {'18','19','20','21','22','23','24','1','2','3','4','5','6','7','8','9'};
ax.FontName = '宋体';
set(gcf, 'PaperSize', [20, 10]);

saveas(gcf,'signal.pdf');

