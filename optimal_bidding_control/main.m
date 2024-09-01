%% Main Program
clc; clear;
% Store results
yalmip("clear");
result = {};

%% Parameter Reading

% Default data for the 21st day
day_price = 21;
load("../data_prepare/param_day_" + day_price + ".mat");

% Update step size
NOFTCAP_bid = 900;
NOFTCAP_ctrl = 30;
result.P_alloc = []; % Used to record results
result.actualMil = zeros(NOFSLOTS, 1);
result.actualEnergy = zeros(NOFSLOTS, 1);
result.actualCost = zeros(NOFSLOTS, 1);

%% Initial time period
warning('off')
maxProfit_1;

%% Intermediate time periods
for t_cap = 1 : (NOFSLOTS - 1) * 1800
    if mod(t_cap, NOFTCAP_bid) == 1 % Beginning of a time slot or midway, update multipliers and allocate power, but do not update the current time slot bid
        delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800; % Remaining time in the current time slot
        maxProfit_t;
    end
    if mod(t_cap, NOFTCAP_ctrl) == 1 % Allocate power, but do not update the current time slot bid
        delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800; % Remaining time in the current time slot
        fastControl_prepare; % Update L multipliers and construct parameter matrix
        fastControl_implement; % Power allocation
    end

end

% Last time slot, no need to bid again
for t_cap = (NOFSLOTS - 1) * 1800 + 1 : NOFSLOTS * 1800 - 1
    if mod(t_cap, NOFTCAP_ctrl) == 1 % Beginning of a time slot or midway, allocate power
        sol.solveroutput.lambda.eqlin(1 : NOFDER) = zeros(NOFDER, 1); % Avoid numerical issues
        fastControl_prepare; % Update L multipliers and construct parameter matrix
        fastControl_implement; % Power allocation
    end
end

%% Market Revenue
result.actualEnegyFee = param.price_e .* result.actualEnergy;
result.actualProfit =  param.price_reg(:, 1) .* result.Bid_R_rev * param.s_perf + ...
    (param.price_reg(:, 2) .* result.actualMil) * param.s_perf;
% Multiply by the time slot length
result.actualProfit =  result.actualProfit * delta_t;

save("../results/result_optimal_bid_ctrl_sep_.mat", "result");