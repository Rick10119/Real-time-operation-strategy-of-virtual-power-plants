%% Calculate VPP revenue for various methods

close;

EnergyFee_comp = [];
Profit_comp = [];
Cost_comp = [];
Bid_P_comp = [];
Bid_R_comp = [];
actualEnergy_comp = [];
P_unbal_comp = [];
load("../data_prepare/param_day_21.mat")

% Proportional allocation
for resource_idx = 1 : 6 % Total of 6 resources

    % Resource name
    temp = ["pv", "es", "ev", "tcl", "ipp", ""];
    resource_name = temp(resource_idx);

    load("../results/result_prop_ctrl_sep_" + resource_name + ".mat", "result");

    EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
    Profit_comp = [Profit_comp, result.actualProfit];
    Cost_comp = [Cost_comp, result.actualCost];
    Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
    Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
    actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
    % P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end

% Greedy algorithm
for resource_idx = 1 : 6 % Total of 6 resources

    % Resource name
    temp = ["pv", "es", "ev", "tcl", "ipp", ""];
    resource_name = temp(resource_idx);

    load("../results/result_tx_optimal_bid_ctrl_sep_" + resource_name + ".mat", "result");

    EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
    Profit_comp = [Profit_comp, result.actualProfit];
    Cost_comp = [Cost_comp, result.actualCost];
    Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
    Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
    actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
    % P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end

% Proposed method
for resource_idx = 1 : 6 % Total of 6 resources

    % Resource name
    temp = ["pv", "es", "ev", "tcl", "ipp", ""];
    resource_name = temp(resource_idx);

    load("../results/result_optimal_bid_ctrl_sep_" + resource_name + ".mat", "result");

    EnergyFee_comp = [EnergyFee_comp, result.actualEnegyFee];
    Profit_comp = [Profit_comp, result.actualProfit];
    Cost_comp = [Cost_comp, result.actualCost];
    Bid_P_comp = [Bid_P_comp, result.Bid_P_rev];
    Bid_R_comp = [Bid_R_comp, result.Bid_R_rev];
    actualEnergy_comp = [actualEnergy_comp, result.actualEnergy];
    % P_unbal_comp = [P_unbal_comp, sum(sum(abs(P_unbal)))];
end

% Revenue calculation
revenue = Profit_comp - Cost_comp + EnergyFee_comp;

total_revenue = sum(revenue);
total_EnergyFee = sum(EnergyFee_comp);
total_profit = sum(Profit_comp);
total_cost = sum(Cost_comp);

total_table = [total_EnergyFee; total_profit; total_cost; total_revenue]';
