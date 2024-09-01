

%%

plot(P_alloc(:, 1:3));hold on;
plot(P_alloc * ones(5, 1));
legend('EV1','EV2','EV3','总调整量','fontsize',9); %,'主网购电'
% set(gca, "YGrid", "on");
% set(gca, "XGrid", "on");
% set(gca, "ylim", [-100, 100]);
% set(gca,'GridLineStyle',':');

%设置figure各个参数
x1 = xlabel('时间','FontSize',15);          %轴标题可以用tex解释
y1 = ylabel('功率分配','FontSize',15);

x1.FontName = '宋体';
y1.FontName = '宋体';

hour = 19;
m=linspace(datenum(hour - 1 + ":00",'HH:MM'),datenum(hour  + ":00",'HH:MM'),10);
% set(gca,'xtick',2:0.2:3);
for n=1:length(m)
    tm{n}=datestr(m(n),'HH:MM');
end
set(gca,'xticklabel',tm);









