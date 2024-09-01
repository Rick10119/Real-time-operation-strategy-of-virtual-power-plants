%% 画EV的到达、离开情况。

if ~exist('param')
    diff = 0.1;
    cd ../data_prepare
    data_prepare;
    cd ../results
end

ev_arrive = zeros(16, 3);
ev_leave = zeros(16, 3);
EV_arrive_leave = param.EV_arrive_leave;
for idx = 1 : length(EV_arrive_leave)
    switch mod(idx, 3)
        case 1
            % 到达时间
            ev_arrive(EV_arrive_leave(idx, 2), 1) = ev_arrive(EV_arrive_leave(idx, 2), 1) + 1;
            ev_leave(EV_arrive_leave(idx, 3), 1) = ev_leave(EV_arrive_leave(idx, 3), 1) + 1;
        case 2
            ev_arrive(EV_arrive_leave(idx, 2), 2) = ev_arrive(EV_arrive_leave(idx, 2), 2) + 1;
            ev_leave(EV_arrive_leave(idx, 3), 2) = ev_leave(EV_arrive_leave(idx, 3), 2) + 1;
        case 0
            ev_arrive(EV_arrive_leave(idx, 2), 3) = ev_arrive(EV_arrive_leave(idx, 2), 3) + 1;
            ev_leave(EV_arrive_leave(idx, 3), 3) = ev_leave(EV_arrive_leave(idx, 3), 3) + 1;
    end
end

%% 画图
close;
barwidth = 0.75;
bar(ev_arrive, barwidth, 'stack');hold on
bar(-ev_leave, barwidth, 'stack');

% 属性
%设置figure各个参数
x1 = xlabel('Hour','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('EVs Arriving/Leaving','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');

% 图片大小
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = figureWidth * 2 / 4;
set(gcf, 'Units', figureUnits, 'Position', [10 10 figureWidth figureHeight]);

% 轴属性
ax = gca;
ax.XLim = [0, 17];     
% ax.YLim = [0, 90];     
% 字体与大小
ax.FontSize = 13.5;

% 设置刻度
ax.XTick = [1:16];

% 调整标签
ax.XTickLabel =  {'18','19','20','21','22','23','24','1','2','3','4','5','6','7','8','9'};

set(gca, "YGrid", "on");

%% 右轴
yyaxis right
linewidth = 2;
% 插电EV总数
ev_u = sum(param.u);
plot(ev_u, 'g', 'linewidth', linewidth);
ax = gca;
ax.YColor = 'black';



legend('Arriving-Type a','Arriving-Type b','Arriving-Type c', ...
   'Leaving-Type a','Leaving-Type b','Leaving-Type c','EVs Plug-in','fontsize',13.5, ...
   'Location','South', ...
'Orientation','vertical', ...
'NumColumns', 3, ...
'FontName', 'Times New Roman'); 


% 属性
%设置figure各个参数
y1 = ylabel('EVs Plug-in','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');

set(gcf, 'PaperSize', [19.5, 10]);

saveas(gcf, "ev_arrive_leave.pdf")




