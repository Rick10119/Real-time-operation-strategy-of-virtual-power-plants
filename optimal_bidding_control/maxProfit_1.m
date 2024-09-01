%% Bidding, starting from time slot 1

% Used for: 1. Initial value generation; 2. Calculation of Lagrange multipliers

% Input: energy of each time slot, frequency regulation market prices; time slots when electric vehicles arrive and leave, energy;
% Output: bidding amounts for each time slot, battery energy levels

%% Parameter setting

% See data_prepare_main.m

%% Variable definition
% Bidding capacity: energy, frequency regulation (MW)
Bid_P = sdpvar(NOFSLOTS, 1, 'full'); 
Bid_R = sdpvar(NOFSLOTS, 1, 'full'); 

% Auxiliary variables
P_dis = sdpvar(NOFDER, NOFSLOTS, NOFSCEN, 'full'); % DER discharge power in each scenario (kW)
P_ch = sdpvar(NOFDER, NOFSLOTS, NOFSCEN, 'full'); % DER charge power in each scenario (kW)
E = sdpvar(NOFDER, NOFSLOTS + 1, 'full'); % Initial battery energy of DER at each time slot (kWh), including departure time (beginning of the time slot), hence an extra dimension
Cost_deg = sdpvar(NOFSLOTS, NOFSCEN, 'full'); % Aging costs for each time slot and scenario ($)

%% Objective function
% Energy revenue, frequency capacity revenue, frequency mileage revenue, deployment cost, performance cost
Profit = param.price_e' * Bid_P + param.price_reg(:, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(:, 2) .* param.hourly_Mileage)' * Bid_R * param.s_perf + ...
    ((param.hourly_Distribution * param.d_s) .* param.price_e)' * Bid_R - ...
     sum(sum(param.hourly_Distribution .* Cost_deg));
% Multiply by time slot length
Profit = Profit * delta_t;

%% Constraints

Constraints = [];

% Initial energy level at the arrival time (fourth column) NOFDER
Constraints = [Constraints, param_std.energy_init - E(:, 1) == 0];

% Power response - balance in each scenario NOFSLOTS * NOFSCEN
temp = permute(sum(P_dis - P_ch), [2, 3, 1]); % Aggregate DER power
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, repmat(Bid_P, 1, NOFSCEN) + ...
    repmat(Bid_R, 1, NOFSCEN) .* repmat(param.d_s', NOFSLOTS, 1) - temp == 0];

% Power limits (MW) NOFDER * NOFSLOTS * NOFSCEN
Constraints = [Constraints, repmat(param_std.power_dis_lower_limit, 1, 1, NOFSCEN) <= P_dis];
Constraints = [Constraints, repmat(param_std.power_ch_lower_limit, 1, 1, NOFSCEN) <= P_ch];
Constraints = [Constraints, P_dis <= repmat(param_std.power_dis_upper_limit, 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch <= repmat(param_std.power_ch_upper_limit, 1, 1, NOFSCEN)];

% Cost incurred by power NOFSLOTS * NOFSCEN
temp = permute(sum(repmat(param_std.pr_dis, 1, NOFSLOTS, NOFSCEN) .* P_dis + ...
    repmat(param_std.pr_ch, 1, NOFSLOTS, NOFSCEN) .* P_ch), [2, 3, 1]); % Aggregate DER power, exchange rows and columns
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, Cost_deg == temp];

% Energy correlation between time slots (MWh)
% Energy limits
% Energy in intermediate time slots should be between the maximum and minimum NOFDER * NOFSLOTS
Constraints = [Constraints, param_std.energy_lower_limit <= E(:, 2 : end)];
Constraints = [Constraints, E(:, 2 : end) <= param_std.energy_upper_limit];

% Frequency bidding continuous power (duration) constraints NOFSLOTS
% Discharge (d_s = 1), last frequency scenario
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, NOFSLOTS) ...
    .* E(:, 1 : end - 1) - delta_t_req * param_std.eta_dis * P_dis(:, :, end) ...
    + delta_t_req * param_std.wOmiga >= param_std.energy_lower_limit(:, [1, 1 : end - 1])];

% Charge (d_s = -1), first frequency scenario
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, NOFSLOTS) ...
    .* E(:, 1 : end - 1) - delta_t_req * param_std.eta_ch * P_ch(:, :, 1) ...
    + delta_t_req * param_std.wOmiga <= param_std.energy_upper_limit(:, [1, 1 : end - 1])];

% Connection between adjacent time slots NOFDER * NOFSLOTS
temp = repmat(param.hourly_Distribution', 1, NOFDER);
% Distribution repeated for SCEN * (SLOTS * DER)
temp_ch = permute(P_ch, [3, 2, 1]); % Exchange rows and columns
temp_ch = reshape(temp_ch, NOFSCEN, NOFSLOTS * NOFDER); % Flatten power for SCEN * (SLOTS * DER)
temp_ch = sum(temp_ch .* temp); % Multiply and sum according to probability weight
temp_ch = reshape(temp_ch, NOFSLOTS, NOFDER)'; % Rewrite as SLOTS * DER, and transpose to DER * SLOTS

temp_dis = permute(P_dis, [3, 2, 1]); % Exchange rows and columns
temp_dis = reshape(temp_dis, NOFSCEN, NOFSLOTS * NOFDER); % Flatten power for SCEN * (SLOTS * DER)
temp_dis = sum(temp_dis .* temp); % Multiply and sum according to probability weight
temp_dis = reshape(temp_dis, NOFSLOTS, NOFDER)'; % Rewrite as SLOTS * DER, and transpose to DER * SLOTS

Constraints = [Constraints, E(:, 2 : end) == repmat(param_std.theta, 1, NOFSLOTS) .* E(:, 1 : end - 1) ...
    + param_std.eta_ch * temp_ch * delta_t ...
    - param_std.eta_dis * temp_dis * delta_t ...
    + param_std.wOmiga * delta_t];

% Constraints for resources not participating in frequency regulation
% These resources have the same output in all scenarios
Constraints = [Constraints, P_dis(param.index_none_reg, :, :) == repmat(P_dis(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch(param.index_none_reg, :, :) == repmat(P_ch(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];

%% Solve the problem

ops = sdpsettings('debug', 1, 'solver', 'cplex', 'savesolveroutput', 1, 'savesolverinput', 1);

sol = optimize(Constraints, -Profit, ops);

if sol.problem == 0 % Successful optimization
    disp("Time slot 1: Bidding successful.")
else 
    disp("Time slot 1: Bidding failed.")
end

%% Recording
result.Bid_R_init = value(Bid_R);
result.Bid_P_init = value(Bid_P);
result.E_init = value(E);
result.Bid_R_cur = value(Bid_R(1));
result.Bid_P_cur = value(Bid_P(1));
result.E_cur = value(E(:, 1));

% For future reference
result.Bid_R_rev = value(Bid_R);
result.Bid_P_rev = value(Bid_P);
result.E_rev = result.E_cur;