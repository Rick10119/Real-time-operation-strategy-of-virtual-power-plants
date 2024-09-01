
close;

EnergyFee_comp =[];
Profit_comp = [];
Cost_comp = [];
Bid_P_comp = [];
Bid_R_comp = [];
actualEnergy_comp = [];
P_unbal_comp = [];
% load("../data_prepare/param.mat")

% 比例分配
for resource_idx = 1 : 6 % 6是总共的

% 资源名字
temp = ["pv", "es", "ev", "tcl", "ipp", ""];
resource_name = temp(resource_idx);

for day_price = 15 : 28

load("../results/result_prop_ctrl_sep_" + resource_name + day_price + ".mat", "result");

EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
Profit_comp = [Profit_comp, result.actualProfit];
Cost_comp = [Cost_comp, result.actualCost];
Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
% P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end

end

% 贪心算法

for resource_idx = 1 : 6 % 6是总共的

% 资源名字
temp = ["pv", "es", "ev", "tcl", "ipp", ""];
resource_name = temp(resource_idx);

for day_price = 15 : 28
load("../results/result_tx_optimal_bid_ctrl_sep_" + resource_name + day_price + ".mat", "result");
EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
Profit_comp = [Profit_comp, result.actualProfit];
Cost_comp = [Cost_comp, result.actualCost];
Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
% P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end

end

% 所提方法

for resource_idx = 1 : 6 % 6是总共的

% 资源名字
temp = ["pv", "es", "ev", "tcl", "ipp", ""];
resource_name = temp(resource_idx);

for day_price = 15 : 28
load("../results/result_optimal_bid_ctrl_sep_" + resource_name + day_price + ".mat", "result");
EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
Profit_comp = [Profit_comp, result.actualProfit];
Cost_comp = [Cost_comp, result.actualCost];
Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
% P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end
end


% 利润
revenue = Profit_comp - Cost_comp + EnergyFee_comp;

total_revenue = sum(revenue);
total_EnergyFee = sum(EnergyFee_comp);
total_profit = sum(Profit_comp);
total_cost = sum(Cost_comp);

total_table_days = [total_EnergyFee; total_profit; total_cost; total_revenue]';

% 按照类型把每天的收益加起来
temp = total_table_days';
nofdays = 14;
for idx = nofdays : nofdays : length(temp)
    
temp(:, idx) = temp(:, idx - nofdays + 1: idx)*ones(nofdays, 1);

total_table = temp(:, nofdays : nofdays : length(temp))';

total_table = [repmat(1:6, 1, 3)', total_table];

end
% total_table = total_table([5, 11, 17], :);% 工厂

% total_table = total_table([4, 10, 16], :);% 空调

% P_unbal_comp = P_unbal_comp' / 1800;% 换算到kWh
total_table = total_table / 14; %平均到每天
total_table = total_table(:, 2:end);
total_table(:, 1) = total_table(:, 1)-total_table(:, 3);
total_table = total_table(:, 1 : 2);

%% 画出各类别的分别收益。

X = reshape(total_table', 1, 36);
X = rand(4,3) - 0.5;
Xneg = X;
Xneg(Xneg>0) = 0;
Xpos = X;
Xpos(Xpos<0) = 0;
hold on
bar(Xneg,'stack')
bar(Xpos,'stack')
hold off




