%% Calculate the shadow price of battery capacity for the next bidding problem in the next time slot

% Purpose: Update the bidding amount in the next time slot and update the Lagrange multiplier

% Inputs: Energy and frequency regulation market prices for each time slot; Arrival and departure time slots and energy for electric vehicles; Current time slot t_cap; Bidding amount in the current time slot
% Inputs: Current battery capacities
% Initial values: Bidding amounts in each time slot from the previous bidding session
% Output: Bidding amounts and battery capacities for future time slots, Lagrange multiplier for one future time slot

%% Parameter Settings

% More: see data_prepare.m

% Current time slot number CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800); % 2 seconds per slot, divided by 1800 and rounded up to get the current time slot number
% Remaining number of time slots
REST_SLOTS = NOFSLOTS - CUR_SLOT;

% Bidding amount in the current time slot
Bid_R_cur = result.Bid_R_rev(CUR_SLOT);
Bid_P_cur = result.Bid_P_rev(CUR_SLOT);
result.Bid_R_cur = result.Bid_R_rev(CUR_SLOT);
result.Bid_P_cur = result.Bid_P_rev(CUR_SLOT);
E_cur = result.E_cur;

%% Variables
% Bidding capacity: energy, frequency (MW), from t + 1 to T, where t + 1 is the first entry
Bid_P = sdpvar(REST_SLOTS, 1, 'full');
Bid_R = sdpvar(REST_SLOTS, 1, 'full');

% Auxiliary variables
P_dis = sdpvar(NOFDER, REST_SLOTS + 1, NOFSCEN, 'full'); % Power discharged by DER in each scenario (kW), one more time slot dimension as allocation continues in the current time slot
P_ch = sdpvar(NOFDER, REST_SLOTS + 1, NOFSCEN, 'full'); % Power charged by DER in each scenario (kW), one more time slot dimension as allocation continues in the current time slot
E = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % Battery energy of DER at the beginning of each time slot (kWh), including the current time and departure time slots, hence 2 extra dimensions
delta_E1 = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % Used for penalty calculation
delta_E2 = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % Used for penalty calculation
delta_E3 = sdpvar(NOFDER, REST_SLOTS, 'full'); % Used for penalty calculation
delta_E4 = sdpvar(NOFDER, REST_SLOTS, 'full'); % Used for penalty calculation
Cost_perf = sdpvar(REST_SLOTS + 1, NOFSCEN, 'full'); % Performance cost for each time slot and scenario ($/h)

%% Objective Function
% Energy profit, frequency capacity profit, frequency mileage profit, deployment cost, performance cost
Profit = param.price_e(CUR_SLOT + 1 : end)' * Bid_P + param.price_reg(CUR_SLOT + 1 : end, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(CUR_SLOT + 1 : end, 2) .* param.hourly_Mileage(CUR_SLOT + 1 : end))' * Bid_R * param.s_perf + ...
    ((param.hourly_Distribution(CUR_SLOT + 1 : end, :) * param.d_s) .* param.price_e(CUR_SLOT + 1 : end))' * Bid_R - ...
    sum(sum(param.hourly_Distribution(CUR_SLOT + 1 : end, :) .* Cost_perf(2 : end, :)));

% Multiply by time slot length
Profit = Profit * delta_t;

% Add current time slot cost
Profit = Profit - ((param.hourly_Distribution(CUR_SLOT, :) * param.d_s) .* param.price_e(CUR_SLOT))' * Bid_R_cur * delta_t_rest - ...
    sum(sum(param.hourly_Distribution(CUR_SLOT, :) .* Cost_perf(1, :))) * delta_t_rest;

% Penalty terms for energy constraints
Profit = Profit - M * sum(sum(delta_E1)) - M * sum(sum(delta_E2)) ...
    - M * sum(sum(delta_E3)) - M * sum(sum(delta_E4));

%% Constraints

Constraints = [];

% Current energy level to derive Lagrange multiplier
Constraints = [Constraints, E_cur - E(:, 1) == 0];

% Power response balance for each scenario. REST_SLOTS + 1 * NOFSCEN
temp = permute(sum(P_dis - P_ch), [2, 3, 1]); % Aggregate DER power
temp = reshape(temp, REST_SLOTS + 1, NOFSCEN);

Constraints = [Constraints, repmat(Bid_P, 1, NOFSCEN) + ...
    repmat(Bid_R, 1, NOFSCEN) .* repmat(param.d_s', REST_SLOTS, 1) - temp(2 : end, :) == 0]; % Future time slots
Constraints = [Constraints, repmat(Bid_P_cur, 1, NOFSCEN) + ...
    repmat(Bid_R_cur, 1, NOFSCEN) .* param.d_s' - temp(1, :) == 0]; % Current time slot

% Power limits (kW). NOFDER * REST_SLOTS * NOFSCEN
Constraints = [Constraints, repmat(param_std.power_dis_lower_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN) <= P_dis];
Constraints = [Constraints, repmat(param_std.power_ch_lower_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN) <= P_ch];
Constraints = [Constraints, P_dis <= repmat(param_std.power_dis_upper_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch <= repmat(param_std.power_ch_upper_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN)];

% Discharge aging ($) REST_SLOTS + 1 * NOFSCEN
temp = permute(sum(repmat(param_std.pr_dis, 1, REST_SLOTS + 1, NOFSCEN) .* P_dis + ...
    repmat(param_std.pr_ch, 1, REST_SLOTS + 1, NOFSCEN) .* P_ch), [2, 3, 1]); % Aggregate DER power, swap rows and columns
temp = reshape(temp, REST_SLOTS + 1, NOFSCEN);

Constraints = [Constraints, Cost_perf == temp];

% Energy correlation between time slots (kWh)
% Energy limits
% Energy between max and min NOFDER * REST_SLOTS + 1
Constraints = [Constraints, param_std.energy_lower_limit(:, CUR_SLOT : end) <= E(:, 2 : end) + delta_E1(:, 2 : end)];
Constraints = [Constraints, E(:, 2 : end) - delta_E2(:, 2 : end) <= param_std.energy_upper_limit(:, CUR_SLOT : end)];
Constraints = [Constraints, 0 <= delta_E1];
Constraints = [Constraints, 0 <= delta_E2];

% Continuous power (duration) constraint for frequency bidding REST_SLOTS
delta_t_req = 0.5;
% Discharge (d_s = 1), last frequency scenario
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, REST_SLOTS) ...
    .* E(:, 2 : end - 1) - delta_t_req * param_std.eta_dis * P_dis(:, 2 : end, end) ...
    + delta_t_req * param_std.wOmiga(:, CUR_SLOT + 1 : end) >= param_std.energy_lower_limit(:, CUR_SLOT : end - 1) - delta_E3];

% Charge (d_s = -1), first frequency scenario
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, REST_SLOTS) ...
    .* E(:, 2 : end - 1) - delta_t_req * param_std.eta_ch * P_ch(:, 2 : end, 1) ...
    + delta_t_req * param_std.wOmiga(:, CUR_SLOT + 1 : end) <= param_std.energy_upper_limit(:, CUR_SLOT : end - 1) + delta_E4];
Constraints = [Constraints, 0 <= delta_E3];
Constraints = [Constraints, 0 <= delta_E4];

% Connection between time slots NOFDER * (REST_SLOTS + 1,)
temp = repmat(param.hourly_Distribution(CUR_SLOT : end, :)', 1, NOFDER);
% Repeat distribution for SCEN * (SLOTS * DER)
temp_ch = permute(P_ch, [3, 2, 1]); % Swap rows and columns
temp_ch = reshape(temp_ch, NOFSCEN, (REST_SLOTS + 1) * NOFDER); % Flatten power to SCEN * (SLOTS * DER)
temp_ch = sum(temp_ch .* temp); % Multiply and sum according to probabilities
temp_ch = reshape(temp_ch, (REST_SLOTS + 1), NOFDER)'; % Rewrite as SLOTS * DER and transpose to DER * SLOTS

temp_dis = permute(P_dis, [3, 2, 1]); % Swap rows and columns
temp_dis = reshape(temp_dis, NOFSCEN, (REST_SLOTS + 1) * NOFDER); % Flatten power to SCEN * (SLOTS * DER)
temp_dis = sum(temp_dis .* temp); % Multiply and sum according to probabilities
temp_dis = reshape(temp_dis, (REST_SLOTS + 1), NOFDER)'; % Rewrite as SLOTS * DER and transpose to DER * SLOTS

Constraints = [Constraints, E(:, 3 : end) == repmat(param_std.theta, 1, REST_SLOTS) .* E(:, 2 : end - 1) ...
    + param_std.eta_ch * temp_ch(:, 2 : end) * delta_t ...
    - param_std.eta_dis * temp_dis(:, 2 : end) * delta_t ...
    + param_std.wOmiga(:, CUR_SLOT + 1 : end) * delta_t]; % Future time slots

Constraints = [Constraints, E(:, 2) == (ones(NOFDER, 1) - delta_t_rest * (ones(NOFDER, 1) - param_std.theta)) .* E(:, 1) ...
    + param_std.eta_ch * temp_ch(:, 1) * delta_t_rest ...
    - param_std.eta_dis * temp_dis(:, 1) * delta_t_rest ...
    + param_std.wOmiga(:, CUR_SLOT) * delta_t_rest]; % Current time slot

% Constraints for resources not participating in frequency regulation
% These resources have the same output in all scenarios
Constraints = [Constraints, P_dis(param.index_none_reg, :, :) == repmat(P_dis(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch(param.index_none_reg, :, :) == repmat(P_ch(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];

%% Solve the optimization problem
ops = sdpsettings('debug', 1, 'solver', 'cplex', 'savesolveroutput', 1, 'savesolverinput', 1);

sol = optimize(Constraints, -Profit, ops);

%% Record
if sol.problem == 0 || sol.problem == 4 % Successful optimization
    disp("Time slot " + (CUR_SLOT) + " : Bidding update completed. Time: " + t_cap)
    % Record, update bidding
    result.Bid_R_rev(CUR_SLOT + 1 : end) = value(Bid_R);
    result.Bid_P_rev(CUR_SLOT + 1 : end) = value(Bid_P);
    % Output of non-frequency resources
    result.p_none_reg = value(value(P_ch(param.index_none_reg, 1, 1)));

else
    disp("Time slot " + (CUR_SLOT) + " : Bidding optimization failed.")
end
