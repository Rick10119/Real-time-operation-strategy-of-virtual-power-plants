%% Standardize all resources expressions
% 1 PV  2 ES     3-42 EV  43-45 TCL    46-55 IPP
% Except for init/end, all matrices should be 55 rows * 24 columns
NOFDER = 1 + 1 + NOFEV + NOFTCL + NOFIPP;

% Initial energy
param_std.energy_init = [1; param.energy_init_es; ...
    param.energy_init_ev * ones(NOFEV, 1); ...
    param.energy_init_tcl * ones(NOFTCL, 1); ...
    param.energy_init_ipp];

% Energy upper limit
param_std.energy_upper_limit = [2; param.energy_upper_limit_es; ...
    param.energy_upper_limit_ev * ones(NOFEV, 1); ...
    param.energy_upper_limit_tcl * ones(NOFTCL, 1); ...
    param.energy_upper_limit_ipp];
param_std.energy_upper_limit = repmat(param_std.energy_upper_limit, 1, NOFSLOTS);

% End energy lower limit
param_std.energy_end =  [0; param.energy_init_es; ...
    param.energy_end_ev * ones(NOFEV, 1); ...
    param.energy_lower_limit_tcl * ones(NOFTCL, 1); ...
    param.energy_end_ipp];

% Energy lower limit
param_std.energy_lower_limit = [0; param.energy_lower_limit_es; ...
    param.energy_lower_limit_ev * ones(NOFEV, 1); ...
    param.energy_lower_limit_tcl * ones(NOFTCL, 1); ...
    param.energy_lower_limit_ipp];
param_std.energy_lower_limit = [repmat(param_std.energy_lower_limit, 1, 23), ...
    param_std.energy_end];

% Discharge power upper limit
param_std.power_dis_upper_limit = [param.power_dis_upper_limit_pv; ...
    repmat(param.power_dis_upper_limit_es, 1, NOFSLOTS); ...
    repmat(param.power_dis_upper_limit_ev, NOFEV, NOFSLOTS) .* param.u; ...
    zeros(NOFTCL, NOFSLOTS); ...
    zeros(NOFIPP, NOFSLOTS)];
% Discharge power lower limit
param_std.power_dis_lower_limit = zeros(size(param_std.power_dis_upper_limit));
% Charge power upper limit
param_std.power_ch_upper_limit =  [zeros(1, NOFSLOTS); ...
    repmat(param.power_ch_upper_limit_es, 1, NOFSLOTS); ...
    repmat(param.power_ch_upper_limit_ev, NOFEV, NOFSLOTS) .* param.u; ...
    repmat(param.power_ch_upper_limit_tcl, 1, NOFSLOTS); ...
    repmat(param.power_ch_upper_limit_ipp, 1, NOFSLOTS)];
% Charge power lower limit
param_std.power_ch_lower_limit = zeros(size(param_std.power_ch_upper_limit));
% Retention rate
param_std.theta = [1; ones(1 + NOFEV, 1); ...
    param.theta_tcl; ...
    ones(NOFIPP, 1)];
% Discharge efficiency
param_std.eta_dis = zeros(NOFDER, NOFDER);
param_std.eta_dis(2, 2) = 1 / param.eta_dis_es;
for idx = 3 : 2 + NOFEV % Electric Vehicles
    param_std.eta_dis(idx, idx) = 1 / param.eta_dis_ev;
end

% Charge efficiency
param_std.eta_ch = zeros(NOFDER, NOFDER);
param_std.eta_ch(2, 2) = param.eta_ch_es;
for idx = 3 : 2 + NOFEV % Electric Vehicles
    param_std.eta_ch(idx, idx) = param.eta_ch_ev;
end
for idx = 3 + NOFEV : 2 + NOFEV + NOFTCL % Temperature-Controlled Loads
    param_std.eta_ch(idx, idx) = param.eta_ch_tcl(idx - 2 - NOFEV);
end
for idx = 3 + NOFEV + NOFTCL : NOFDER % Industrial Production Process
    jdx = idx - (2 + NOFEV + NOFTCL); % Relative index, starting from 1
    param_std.eta_ch(idx, idx) = param.eta_ch_ipp(jdx); % Self-production
    % Mutual consumption
    if jdx < NOFIPP
        param_std.eta_ch(idx, idx + 1) = - param.eta_ch_ipp(jdx + 1);
    end
end
% Discharge cost $/MWh
param_std.pr_dis = [0; param.pr_dis_es; ...
    repmat(param.pr_dis_ev, NOFEV, 1); ...
    zeros(NOFTCL + NOFIPP, 1)];
% Charge cost $/MWh
param_std.pr_ch = [0; param.pr_ch_es; ...
    repmat(param.pr_ch_ev, NOFEV, 1); ...
    zeros(NOFTCL + NOFIPP, 1)];

% External influences
param_std.wOmiga = [zeros(2 + NOFEV, NOFSLOTS); ...
    param.wOmiga; ...
    zeros(NOFIPP, NOFSLOTS)];

% Resource numbers that do not participate in frequency regulation
temp = 2 + NOFEV + NOFTCL;
param.index_none_reg = temp * ones(1, 5) + [1, 2, 3, 6, 7];

% The minimum energy of EV when leaving time slot should be modified
for idx = 1 : NOFEV
    for jdx = 1 : NOFSLOTS - 1
        if param.u(idx, jdx) - param.u(idx, jdx + 1) == 1 % Last time slot
            param_std.energy_lower_limit(2 + idx, jdx) = param_std.energy_end(2 + idx);
        end
    end
end

% The minimum energy of EV in the time slot before leaving time slot should be modified
for idx = 1 : NOFEV
    for jdx = 1 : NOFSLOTS - 1
        if param.u(idx, jdx) - param.u(idx, jdx + 1) == 1 % Last time slot
            param_std.energy_lower_limit(2 + idx, jdx - 1) = ...
                param_std.energy_end(2 + idx) - ...
                param_std.power_ch_upper_limit(2 + idx, jdx) * 0.9;
            param_std.energy_lower_limit(2 + idx, jdx - 2) = ...
                param_std.energy_end(2 + idx) - ...
                param_std.power_ch_upper_limit(2 + idx, jdx) * 0.9 * 2;
        end
    end
end

% The minimum energy of IPP in the time slot before leaving time slot should be modified
idx = NOFDER;
for jdx = 1 : 14
param_std.energy_lower_limit(idx, NOFSLOTS - jdx) = ...
    param_std.energy_end(idx) - ...
    param_std.power_ch_upper_limit(idx, NOFSLOTS) * param_std.eta_ch(idx, idx) * jdx;
end
