%% Calculate various times.

%% Output power of each resource and change state
% Input: output of each resource (NOFDER * 1)
% Output: state changes of each resource, cumulative cost accumulation
calc_time = [];
result.p_dis = [];
result.p_ch = [];

delta_t_cap = NOFTCAP_ctrl / 1800;
%% Parameter processing

% t_cap + NOFTCAP_ctrl - 1
for t_cap_dx = 1:5

    % Extract signal
    delta = Signal_day(t_cap_dx);

    % Required response amount
    P_req = Bid_P_cur + Bid_R_cur * delta;

    param_std.seg_p_allocated = param_std.seg_parameter;

    param_std.seg_parameter(:, 5) = param_std.seg_parameter(:, 5) + 1;
    % Power allocation
    %% Directly solve linear programming
    yalmip("clear");

    P_der = sdpvar(NOFDER * 2, 1, 'full'); 
    % DER discharge power (kW) in each scenario, there is still time to allocate in the current time period, so there is an additional time period dimension

    %% Objective function
    % Energy revenue, frequency regulation capacity revenue, frequency regulation mileage revenue, deployment cost, performance cost
    Cost_perf = P_der' * param_std.seg_parameter(:, 3);

    %% Constraints
    Constraints = [];

    Constraints = [Constraints, P_der <= param_std.seg_parameter(:, 5)];
    Constraints = [Constraints, P_der >= param_std.seg_parameter(:, 4)];

    % Power response - balance in each scenario. REST_SLOTS + 1 * NOFSCEN
    Constraints = [Constraints, sum(P_der) == P_req];

    %% Solve
    ops = sdpsettings('debug', 1, 'solver', 'cplex', 'savesolveroutput', 1, 'savesolverinput', 1);

    sol = optimize(Constraints, Cost_perf, ops);

    %% Record
    calc_time = [calc_time, sol.solvertime];

end

% Average calculation time
mean(calc_time)