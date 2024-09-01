%% 统计各种方法下的VPP收益

close;

EnergyFee_comp =[];
Profit_comp = [];
Cost_comp = [];
Bid_P_comp = [];
Bid_R_comp = [];
actualEnergy_comp = [];
P_unbal_comp = [];
load("../data_prepare/param_day_21.mat")

% 比例分配
for resource_idx = 1 : 6 % 6是总共的

% 资源名字
temp = ["pv", "es", "ev", "tcl", "ipp", ""];
resource_name = temp(resource_idx);

load("../results/result_prop_ctrl_sep_" + resource_name + "21.mat", "result");

EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
Profit_comp = [Profit_comp, result.actualProfit];
Cost_comp = [Cost_comp, result.actualCost];
Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
% P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end


% 贪心算法
for resource_idx = 1 : 6 % 6是总共的

% 资源名字
temp = ["pv", "es", "ev", "tcl", "ipp", ""];
resource_name = temp(resource_idx);

load("../results/result_tx_optimal_bid_ctrl_sep_" + resource_name + "21.mat", "result");
EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
Profit_comp = [Profit_comp, result.actualProfit];
Cost_comp = [Cost_comp, result.actualCost];
Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
% P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end


% 所提方法
for resource_idx = 1 : 6 % 6是总共的

% 资源名字
temp = ["pv", "es", "ev", "tcl", "ipp", ""];
resource_name = temp(resource_idx);

load("../results/result_optimal_bid_ctrl_sep_" + resource_name + "21.mat", "result");
EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
Profit_comp = [Profit_comp, result.actualProfit];
Cost_comp = [Cost_comp, result.actualCost];
Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
% P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end



% 利润
revenue = Profit_comp - Cost_comp + EnergyFee_comp;

total_revenue = sum(revenue);
total_EnergyFee = sum(EnergyFee_comp);
total_profit = sum(Profit_comp);
total_cost = sum(Cost_comp);

total_table = [total_EnergyFee; total_profit; total_cost; total_revenue]';

% total_table = total_table([5, 11, 17], :);% 工厂

% total_table = total_table([4, 10, 16], :);% 空调

% P_unbal_comp = P_unbal_comp' / 1800;% 换算到kWh


%%

% linewidth = 1;

% cd my_alloc_intervals;
% test;



