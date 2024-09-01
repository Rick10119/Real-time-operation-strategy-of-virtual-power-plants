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
for t_cap_dx = 1:10
    
    % Extract signal
    delta = Signal_day(t_cap_dx);
    
    % Required response amount
    P_req = Bid_P_cur + Bid_R_cur * delta;
    
    % Power allocation
    tic;
    for idx = 1:1e3
        param_std.seg_p_allocated = param_std.seg_parameter;
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
    end
    calc_time = [calc_time, toc];
    
end

% Average calculation time
mean(calc_time) / 1e3