%% Calculate various times.

calc_time = [];

yalmip("clear");
maxProfit_1;
calc_time = [calc_time, sol.solvertime];
%% Output power of each resource and change state
% Input: output of each resource (NOFDER * 1)
% Output: state changes of each resource, cumulative cost accumulation
for t_cap_dx = 1:5
    t_cap_dx
    sol = optimize(Constraints, -Profit, ops);
    calc_time = [calc_time, sol.solvertime];
    
end

% Average calculation time
mean(calc_time)