%% 计算时间统计

A = [120	0.6145	0.1252	0.0000392
600	3.7723	0.1285	0.00008469
3000	50.5771	0.1372	3.76e-04
15000	314.5616	0.1834	0.0027
];

linewidth = 1;

loglog(A(:, 1), A(:, 2), "-->g", 'linewidth', linewidth); hold on;
loglog(A(:, 1), A(:, 3), "--xb", 'linewidth', linewidth); 
loglog(A(:, 1), A(:, 4), "--or", 'linewidth', linewidth); hold off;



% 轴属性
ax = gca;
% ax.XLim = [0, 5];     
ax.YLim = [1e-5, 1e3]; 

legend('最优投标问题','最优分解问题', ...
'快速分解算法', ...    
'fontsize',13.5, ...
    'Location','NorthOutside', ...
'Orientation','Horizontal', ...
'FontName', '宋体'); 


%设置figure各个参数
x1 = xlabel('负荷侧分布式资源数量','FontSize',13.5,'FontName', '宋体','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('最优分解计算时间(秒)','FontSize',13.5,'FontName', '宋体','FontWeight','bold');


% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

    
  
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [A(:, 1)];
ax.YTick = [1e-5,1e-4,1e-3,1e-2,1e-1,1,1e1,1e2,1e3];

% 调整标签
ax.XTickLabel =  {'120','600','3000','15000'};
% ax.YTickLabel =  {'1e-5','1e-4','1e-3','1e-2','1e-1','1','1e1','1e2','1e3'};
ax.FontName = '宋体';
set(gcf, 'PaperSize', [19, 7.8]);
% set(gca, "YGrid", "on");

saveas(gcf,'calculation_time.pdf');
