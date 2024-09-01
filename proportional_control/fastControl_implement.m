%% 输出各资源出力，并改变状态
% 输入：各资源的出力（NOFDER * 1）
% 输出：各资源的状态改变、累计成本积累

result.p_dis = [];
result.p_ch = [];
P_DER_cur = result.P_DER_cur;
R_DER_cur = result.R_DER_cur;
E_cur =  result.E_cur;
% 当前时段编号 CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800);% 2s一个，除以1800向上取整，为当前时段编号


delta_t_cap = NOFTCAP_ctrl / 1800;
%% 参数处理

% 取出信号
delta = Signal_day(t_cap : t_cap + NOFTCAP_ctrl - 1);

% 需要的响应量
P_req = repmat(P_DER_cur, 1, NOFTCAP_ctrl) + ...
    repmat(R_DER_cur, 1, NOFTCAP_ctrl) .* repmat(delta', NOFDER, 1);

% 记录分配结果
result.p_dis = 0.5 * (P_req + abs(P_req));
result.p_ch = 0.5 * (- P_req + abs(P_req));

for idx = 1 : NOFDER
    % 放电段
    % 如果能量状态不达标
    if E_cur(idx) < param_std.energy_lower_limit(idx, CUR_SLOT)
        result.p_dis(idx, :) = repmat(param_std.power_dis_lower_limit(idx, CUR_SLOT), 1, NOFTCAP_ctrl);% 仅允许最低放电出力
        result.p_ch(idx, :) = repmat(param_std.power_ch_upper_limit(idx, CUR_SLOT), 1, NOFTCAP_ctrl);% 仅允许最大充电出力
    end
    
    % 充电段
    % 如果能量状态超标
    if E_cur(idx) > param_std.energy_upper_limit(idx, CUR_SLOT)
        result.p_ch(idx, :) = repmat(param_std.power_ch_lower_limit(idx, CUR_SLOT), 1, NOFTCAP_ctrl);% 仅允许最低充电出力;
        result.p_dis(idx, :) = repmat(param_std.power_dis_upper_limit(idx, CUR_SLOT), 1, NOFTCAP_ctrl);% 仅允许最大放电
    end
    
end


%% 更新数据
% 更新电量
result.E_cur = (ones(NOFDER, 1) - delta_t_cap * (ones(NOFDER, 1) - param_std.theta)) .* result.E_cur ...
    + param_std.eta_ch * result.p_ch * ones(NOFTCAP_ctrl, 1) / 1800 ...
    - param_std.eta_dis * result.p_dis  * ones(NOFTCAP_ctrl, 1) / 1800 ...
    + param_std.wOmiga(:, CUR_SLOT) * delta_t_cap;
result.E_rev = [result.E_rev, result.E_cur];

% 记录功率分配结果
result.P_alloc = [result.P_alloc, result.p_dis - result.p_ch];

% 记录成本(仅有老化成本)
result.actualCost(CUR_SLOT) = result.actualCost(CUR_SLOT) ...
    + sum(param_std.pr_dis' * result.p_dis) * delta_t / 1800 ...
    + sum(param_std.pr_ch' * result.p_ch) * delta_t / 1800;

% 记录里程(MW)
P_total = sum(result.p_dis - result.p_ch)';% 集群与电网交换的功率
result.actualMil(CUR_SLOT) = result.actualMil(CUR_SLOT) + sum(abs(P_total(2 : end) - P_total(1 : end - 1)));

% 记录真实能量(WMh)
result.actualEnergy(CUR_SLOT) = result.actualEnergy(CUR_SLOT) + sum(P_total) * delta_t / 1800;


