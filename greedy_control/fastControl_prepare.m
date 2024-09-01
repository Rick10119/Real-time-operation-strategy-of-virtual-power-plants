%% 接收到调频信号后，快速决定各DER的出力

%% 参数处理
% 各资源状态的影子价格
lambda = 0 * sol.solveroutput.lambda.eqlin(1 : NOFDER);

% 随机小数，避免成本相同时总是按照编号优先分配。
lambda = rand(NOFDER, 1);

% 当前时段编号 CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800);% 2s一个，除以1800向上取整，为当前时段编号

% 当前时段的中标量
Bid_R_cur = result.Bid_R_cur;
Bid_P_cur = result.Bid_P_cur;
E_cur = result.E_cur;


%% 变量代换

param_std.seg_parameter = [];

% 构造参数矩阵：(index, flag_ch, c_k, p_lower, p_upper)
for idx = 1 : NOFDER
    % 放电段
    % 如果能量状态不达标
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        param_std.seg_parameter = [param_std.seg_parameter; idx, 0, ...
            param_std.pr_dis(idx) - param_std.eta_dis(idx, :) * lambda, ...
            param_std.power_dis_lower_limit(idx, CUR_SLOT), ...
            param_std.power_dis_lower_limit(idx, CUR_SLOT)];% 仅允许最低放电出力
    else
        param_std.seg_parameter = [param_std.seg_parameter; idx, 0, ...
            param_std.pr_dis(idx) - param_std.eta_dis(idx, :) * lambda, ...
            param_std.power_dis_lower_limit(idx, CUR_SLOT), ...
            param_std.power_dis_upper_limit(idx, CUR_SLOT)];
    end
    
    % 充电段
    % 如果能量状态超标
    if E_cur(idx) > param_std.energy_upper_limit(idx, CUR_SLOT)
        param_std.seg_parameter = [param_std.seg_parameter; idx, 1, ...
            - param_std.pr_ch(idx) - param_std.eta_ch(idx, :) * lambda, ...
            - param_std.power_ch_lower_limit(idx, CUR_SLOT), ...
            - param_std.power_ch_lower_limit(idx, CUR_SLOT)];% 仅允许最低充电出力
    else
        param_std.seg_parameter = [param_std.seg_parameter; idx, 1, ...
            - param_std.pr_ch(idx) - param_std.eta_ch(idx, :) * lambda, ...
            - param_std.power_ch_upper_limit(idx, CUR_SLOT), ...
            - param_std.power_ch_lower_limit(idx, CUR_SLOT)];
    end
    
end

% 为了保证EV达到状态
for idx = 1 : NOFDER
    % 放电段
    % 如果能量状态不达标
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        param_std.seg_parameter(2 * idx, 5) = - param_std.power_ch_upper_limit(idx, CUR_SLOT);
        % 仅允许最大充电出力
    end
end

% 不参加调频的资源
param_std.seg_parameter(2 * param.index_none_reg, 4) = - result.p_none_reg;
param_std.seg_parameter(2 * param.index_none_reg, 5) = - result.p_none_reg;

% 工业负荷存在前后状态耦合，单独考虑。
% 如果环节i没有物料了，那么后面的环节不应该继续生产
for idx = NOFDER - NOFIPP + 1 : NOFDER - 1
    % 放电段
    % 如果能量状态不达标
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        param_std.seg_parameter(2 * (idx + 1), 4) = ...
            - param_std.power_ch_lower_limit(idx + 1, CUR_SLOT);% 仅允许最低充电出力
  
    end
end
%% 按照成本排序

param_std.seg_parameter = sortrows(param_std.seg_parameter, 3);
