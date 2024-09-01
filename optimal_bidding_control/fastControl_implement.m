%% Output power of each resource and change state
% Input: output of each resource (NOFDER * 1)
% Output: state changes of each resource, cumulative cost accumulation

result.p_dis = [];
result.p_ch = [];

delta_t_cap = NOFTCAP_ctrl / 1800;
%% Parameter processing

for t_cap_dx = t_cap : t_cap + NOFTCAP_ctrl - 1
    
    % Extract signal
    delta = Signal_day(t_cap_dx);
    
    % Required response amount
    P_req = Bid_P_cur + Bid_R_cur * delta;

    param_std.seg_p_allocated = param_std.seg_parameter;
    % Power allocation
    %% Quickly determine the output of each DER after receiving the frequency regulation signal
    % Input: total power required by the frequency regulation signal P_req
    % Output: output of each resource (NOFDER * 1)

    %% Power allocation
    % Initialize to minimum value
    p_allocated = param_std.seg_parameter(:, 4);
    % Initial power deviation
    delta_p = P_req - sum(p_allocated);
    % Index. Matrix: (index, flag_ch, c_k, p_lower, p_upper)
    kdx = 1;

    while delta_p > 0
        if param_std.seg_parameter(kdx, 5) - p_allocated(kdx) < delta_p
            % Power deviation is greater than the length of the power segment
            p_allocated(kdx) = param_std.seg_parameter(kdx, 5); % Fill the power segment
            delta_p = delta_p - param_std.seg_parameter(kdx, 5) + param_std.seg_parameter(kdx, 4);
            kdx = kdx + 1;
        else
            p_allocated(kdx) = param_std.seg_parameter(kdx, 4) + delta_p; % Complete the power segment
            delta_p = 0;
            kdx = kdx + 1;
            break;
        end

        % There may be numerical issues
        if kdx > 2 * NOFDER
            break;
        end
    end

    %% Restore power
    % Restore from kth number in p_allocated to ith number, and store it in param_std.seg_p_allocated

    param_std.seg_p_allocated = [param_std.seg_p_allocated, p_allocated];
    % Add the second column to the first column, so as to restore according to the serial number.
    param_std.seg_p_allocated(:, 1) = param_std.seg_p_allocated(:, 1) ...
        + 0.5 * param_std.seg_p_allocated(:, 2);
    % Restore according to the serial number
    param_std.seg_p_allocated = sortrows(param_std.seg_p_allocated, 1);

    % Variable substitution
    param_std.seg_p_allocated = reshape(param_std.seg_p_allocated(:, end), 2, NOFDER)';

    % Record charging/discharging power
    result.p_dis_cap = param_std.seg_p_allocated(:, 1);
    result.p_ch_cap = -param_std.seg_p_allocated(:, 2);

    % Record allocation results
    result.p_dis = [result.p_dis, result.p_dis_cap];
    result.p_ch = [result.p_ch, result.p_ch_cap];

end

%% Update data
% Update energy
result.E_cur = (ones(NOFDER, 1) - delta_t_cap * (ones(NOFDER, 1) - param_std.theta)) .* result.E_cur ...
    + param_std.eta_ch * result.p_ch * ones(NOFTCAP_ctrl, 1) / 1800 ...
    - param_std.eta_dis * result.p_dis  * ones(NOFTCAP_ctrl, 1) / 1800 ...
    + param_std.wOmiga(:, CUR_SLOT) * delta_t_cap;
E_cur = result.E_cur;
result.E_rev = [result.E_rev, result.E_cur];

% Record power allocation results
result.P_alloc = [result.P_alloc, result.p_dis - result.p_ch];

% Record costs (only aging costs)
result.actualCost(CUR_SLOT) = result.actualCost(CUR_SLOT) ...
    + sum(param_std.pr_dis' * result.p_dis) * delta_t / 1800 ...
    + sum(param_std.pr_ch' * result.p_ch) * delta_t / 1800;

% Record mileage (MW)
P_total = sum(result.p_dis - result.p_ch)'; % Power exchanged between the cluster and the grid
result.actualMil(CUR_SLOT) = result.actualMil(CUR_SLOT) + sum(abs(P_total(2 : end) - P_total(1 : end - 1)));

% Record actual energy (WMh)
result.actualEnergy(CUR_SLOT) = result.actualEnergy(CUR_SLOT) + sum(P_total) * delta_t / 1800;