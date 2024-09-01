%% Quickly determine the output of each DER after receiving the frequency regulation signal

%% Parameter processing
% Shadow prices of each resource state
lambda = sol.solveroutput.lambda.eqlin(1 : NOFDER);

% Current time slot number CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800); % 2 seconds each, rounded up when divided by 1800, for the current time slot number

% Current winning scalar for the time slot
Bid_R_cur = result.Bid_R_cur;
Bid_P_cur = result.Bid_P_cur;
E_cur = result.E_cur;

%% Variable substitution

param_std.seg_parameter = [];

% Construct parameter matrix: (index, flag_ch, c_k, p_lower, p_upper)
for idx = 1 : NOFDER
    % Discharge segment
    % If the energy state is below the limit
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        param_std.seg_parameter = [param_std.seg_parameter; idx, 0, ...
            param_std.pr_dis(idx) - param_std.eta_dis(idx, :) * lambda, ...
            param_std.power_dis_lower_limit(idx, CUR_SLOT), ...
            param_std.power_dis_lower_limit(idx, CUR_SLOT)]; % Only allow minimum discharge power
    else
        param_std.seg_parameter = [param_std.seg_parameter; idx, 0, ...
            param_std.pr_dis(idx) - param_std.eta_dis(idx, :) * lambda, ...
            param_std.power_dis_lower_limit(idx, CUR_SLOT), ...
            param_std.power_dis_upper_limit(idx, CUR_SLOT)];
    end

    % Charge segment
    % If the energy state is above the limit
    if E_cur(idx) > param_std.energy_upper_limit(idx, CUR_SLOT)
        param_std.seg_parameter = [param_std.seg_parameter; idx, 1, ...
            - param_std.pr_ch(idx) - param_std.eta_ch(idx, :) * lambda, ...
            - param_std.power_ch_lower_limit(idx, CUR_SLOT), ...
            - param_std.power_ch_lower_limit(idx, CUR_SLOT)]; % Only allow minimum charge power
    else
        param_std.seg_parameter = [param_std.seg_parameter; idx, 1, ...
            - param_std.pr_ch(idx) - param_std.eta_ch(idx, :) * lambda, ...
            - param_std.power_ch_upper_limit(idx, CUR_SLOT), ...
            - param_std.power_ch_lower_limit(idx, CUR_SLOT)];
    end

end

% To ensure that EV reaches the state
for idx = 1 : NOFDER
    % Discharge segment
    % If the energy state is below the limit
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        param_std.seg_parameter(2 * idx, 5) = - param_std.power_ch_upper_limit(idx, CUR_SLOT);
        % Only allow maximum charge power
    end
end

% Resources that do not participate in frequency regulation
param_std.seg_parameter(2 * param.index_none_reg, 4) = - result.p_none_reg;
param_std.seg_parameter(2 * param.index_none_reg, 5) = - result.p_none_reg;

% There is coupling between the states before and after the industrial load, considered separately.
% If link i has no materials, then the subsequent links should not continue production
for idx = NOFDER - NOFIPP + 1 : NOFDER - 1
    % Discharge segment
    % If the energy state is below the limit
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        param_std.seg_parameter(2 * (idx + 1), 4) = ...
            - param_std.power_ch_lower_limit(idx + 1, CUR_SLOT); % Only allow minimum charge power

    end
end

%% Sort by cost

param_std.seg_parameter = sortrows(param_std.seg_parameter, 3);