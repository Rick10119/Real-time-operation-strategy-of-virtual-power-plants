
load("../data_prepare/param.mat");

load('../results/result_optimal_bid_ctrl_sep_ipp.mat')

plot(result.E_rev(135,:))
hold on
load('../results/result_prop_ctrl_sep_ipp.mat')

plot(result.E_rev(135,:))

legend("opt", "prop")


%% 
load("../data_prepare/param.mat");

load('../results/result_optimal_bid_ctrl_sep_es.mat')

% plot(result.Bid_P_rev);

% plot(result.P_alloc(2, 1800 * 23 : end))
plot(result.E_rev(2, 1800 * 23/30 : end))
hold on

load('../results/result_prop_ctrl_sep_es.mat')

% plot(result.Bid_P_rev)
% plot(result.P_alloc(2, 1800 * 23 : end))
plot(result.E_rev(2, 1800 * 23/30 : end))

legend("opt", "prop")

%%






 