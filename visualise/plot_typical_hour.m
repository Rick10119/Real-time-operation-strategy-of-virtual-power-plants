close;
% new_main;
hour = 11;
allocate = {};
% 统计现有机制的数据
% 找一个signal = 0的情况
signal_hour = Signal_day((hour - 1) * 1800 + 1 : hour * 1800);
temp = find(abs(signal_hour)<9 * 1e-3);% 信号为0
temp= temp(1);
% 出力情况 新能源、EV、ES
allocate.P_ver = result.P_alloc(1, (hour-1) * 1800 + 1 : hour * 1800) - result.P_alloc(1, (hour-1) * 1800 + temp);

allocate.P_es = result.P_alloc(2, (hour-1) * 1800 + 1 : hour * 1800) - result.P_alloc(2, (hour-1) * 1800 + temp);

allocate.P_ev = result.P_alloc(3 : 122, (hour-1) * 1800 + 1 : hour * 1800);
allocate.P_ev = sum(allocate.P_ev - repmat(result.P_alloc(3 : 122, (hour-1) * 1800 +  temp), 1, 1800));

allocate.P_tcl =result.P_alloc(123 : 125, (hour-1) * 1800 + 1 : hour * 1800);
allocate.P_tcl = sum(allocate.P_tcl - repmat(result.P_alloc(123 : 125, (hour-1) * 1800 + temp), 1, 1800));

allocate.P_ipp =result.P_alloc(126 : 135, (hour-1) * 1800 + 1 : hour * 1800);
allocate.P_ipp = sum(allocate.P_ipp - repmat(result.P_alloc(126 : 135, (hour-1) * 1800 + temp), 1, 1800));


allocate.ttp = sum([allocate.P_ver; allocate.P_es; allocate.P_ev; allocate.P_tcl; ...
    allocate.P_ipp]);



% x = (allocate.P_dn((hour-1) * 1800 + 1 : hour * 1800, 4:5)) * ones(2, 1);
% plot(x);
%%
linewidth = 1.5;
plot(allocate.P_ver(901 : end), '-b', 'linewidth', linewidth);hold on;
plot(allocate.P_es(901 : end), '-m', 'linewidth', linewidth);
plot(allocate.P_ev(901 : end), '-r', 'linewidth', linewidth);
plot(allocate.P_tcl(901 : end), 'linewidth', linewidth);
plot(allocate.P_ipp(901 : end), 'linewidth', linewidth);
plot(allocate.ttp(901 : end), '--', 'linewidth', linewidth);
x1 = xlabel('Time','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');          %轴标题可以用tex解释
y1 = ylabel('Adjusted Output (MW)','FontSize',13.5,'FontName', 'Times New Roman','FontWeight','bold');
ax = gca;
% ax.YTick = [-50 : 25 : 50];
ax.XTick = [0 : 150 : 900];
% 画右轴
ax.YLim = [-8, 8];     
ax = gca;
ax.YColor = 'black';


legend('PV','ES','EV', ...
'TCL', 'IPP', ...
    'Total Response', ...
    'fontsize',13.5, ...
    'Location','NorthOutside', ...
'Orientation','horizontal', ...
'FontName', 'Times New Roman'); 
set(gca, "YGrid", "on");
set(gca, "ylim", [-8, 8]);
% set(gca,'GridLineStyle',':');

%设置figure各个参数


m=linspace(datenum(hour - 1 + ":30",'HH:MM'),datenum(hour  + ":00",'HH:MM'),7);
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
ax.FontName = 'Times New Roman';
set(gcf, 'PaperSize', [20, 10]);

saveas(gcf,'typical_hour_prop.pdf');