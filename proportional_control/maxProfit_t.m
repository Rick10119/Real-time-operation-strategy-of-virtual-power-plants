%% 计算下一时段投标问题中，电池电量的影子价格，用于当前时段进行分配

% 用于：更新下一时段投标量、更新拉格朗日乘子

% 输入：各时段能量、调频市场价格；电动汽车到达、离开的时段、电量；当前时段时刻t_cap; 当前时段的投标量
% 输入：当前各电池电量；
% 初值： 上一时段投标时，各时段的投标量。
% 输出:  未来各时段投标量、电池电量。未来一个时段L乘子


%% 参数设定

% 更多：见 data_prepare.m

% 当前时段编号 CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800);% 2s一个，除以1800向上取整，为当前时段编号
% 剩下时段数量
REST_SLOTS = NOFSLOTS - CUR_SLOT;

% 当前时段的中标量
Bid_R_cur = result.Bid_R_rev(CUR_SLOT);
Bid_P_cur = result.Bid_P_rev(CUR_SLOT);
E_cur = result.E_cur ;
P_DER_cur = result.P_DER_rev(:, CUR_SLOT);
R_DER_cur = result.R_DER_rev(:, CUR_SLOT);
result.P_DER_cur = result.P_DER_rev(:, CUR_SLOT);
result.R_DER_cur = result.R_DER_rev(:, CUR_SLOT);


%% 变量
% 投标容量：能量、调频(MW), 从t + 1到T, 其中t + 1为第一个entry
Bid_P = sdpvar(REST_SLOTS, 1, 'full');
Bid_R = sdpvar(REST_SLOTS, 1, 'full');
R_DER = sdpvar(NOFDER, REST_SLOTS, 'full');% 分配到各资源的调频容量
P_DER = sdpvar(NOFDER, REST_SLOTS, 'full');% 分配到各资源的基准出力

% 辅助变量
P_dis = sdpvar(NOFDER, REST_SLOTS + 1, NOFSCEN, 'full'); % DER在各场景放电功率(kW),当前时段剩下时间仍然要分配，因此多一个时段维度
P_ch = sdpvar(NOFDER, REST_SLOTS + 1, NOFSCEN, 'full'); % DER在各场景充电功率(kW),当前时段剩下时间仍然要分配，因此多一个时段维度
E = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % DER在各时段之初的电池能量(kWh)。包括当前时刻、离开时刻，因此多2个维度
delta_E1 = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % 用于计算罚项
delta_E2 = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % 用于计算罚项
delta_E3 = sdpvar(NOFDER, REST_SLOTS, 'full'); % 用于计算罚项
delta_E4 = sdpvar(NOFDER, REST_SLOTS, 'full'); % 用于计算罚项
Cost_perf = sdpvar(REST_SLOTS + 1, NOFSCEN, 'full');% 未来各时段各场景的性能成本($/h)

%% 目标函数
% 能量收益、调频容量收益、调频里程收益、部署成本、性能成本
Profit = param.price_e(CUR_SLOT + 1 : end)' * Bid_P + param.price_reg(CUR_SLOT + 1 : end, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(CUR_SLOT + 1 : end, 2) .* param.hourly_Mileage(CUR_SLOT + 1 : end))' * Bid_R * param.s_perf + ...
    ((param.hourly_Distribution(CUR_SLOT + 1 : end, :) * param.d_s) .* param.price_e(CUR_SLOT + 1 : end))' * Bid_R - ...
    sum(sum(param.hourly_Distribution(CUR_SLOT + 1 : end, :) .* Cost_perf(2 : end, :)));

% 乘以时段长度
Profit = Profit * delta_t;

%补上当前时段的成本
Profit = Profit - ((param.hourly_Distribution(CUR_SLOT, :) * param.d_s) .* param.price_e(CUR_SLOT))' * Bid_R_cur * delta_t_rest - ...
    sum(sum(param.hourly_Distribution(CUR_SLOT, :) .* Cost_perf(1, :))) * delta_t_rest;

% 能量约束的罚项
Profit = Profit - M * sum(sum(delta_E1)) - M * sum(sum(delta_E2)) ...
    - M * sum(sum(delta_E3)) - M * sum(sum(delta_E4));

%% 约束条件

Constraints = [];

% 当前电量，由此推出L乘子
Constraints = [Constraints, E_cur - E(:, 1) == 0];

% 功率响应-各场景平衡。 REST_SLOTS + 1 * NOFSCEN
temp = reshape(param.d_s, 1, 1, NOFSCEN);
Constraints = [Constraints, P_dis(:, 2 : end, :) - P_ch(:, 2 : end, :) == repmat(P_DER, 1, 1, NOFSCEN) ...
    + repmat(R_DER, 1, 1, NOFSCEN) .* repmat(temp, NOFDER, REST_SLOTS, 1)];% 未来各时段
Constraints = [Constraints, P_dis(:, 1, :) - P_ch(:, 1, :) == repmat(P_DER_cur, 1, 1, NOFSCEN) ...
    + repmat(R_DER_cur, 1, 1, NOFSCEN) .* repmat(temp, NOFDER, 1, 1)];% 当前时段


Constraints = [Constraints, Bid_P == sum(P_DER)'];
Constraints = [Constraints, Bid_R == sum(R_DER)'];

% 功率上下限(kW)。 NOFDER * REST_SLOTS * NOFSCEN
Constraints = [Constraints, repmat(param_std.power_dis_lower_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN) <= P_dis];
Constraints = [Constraints, repmat(param_std.power_ch_lower_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN) <= P_ch];
Constraints = [Constraints, P_dis <= repmat(param_std.power_dis_upper_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch <= repmat(param_std.power_ch_upper_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN)];

% 放电老化($) REST_SLOTS + 1 * NOFSCEN
temp = permute(sum(repmat(param_std.pr_dis, 1, REST_SLOTS + 1, NOFSCEN) .* P_dis + ...
    repmat(param_std.pr_ch, 1, REST_SLOTS + 1, NOFSCEN) .* P_ch), [2, 3, 1]);% 把DER的功率聚合, 交换行列
temp = reshape(temp, REST_SLOTS + 1, NOFSCEN);

Constraints = [Constraints, Cost_perf == temp];

% 时段间能量关联(kWh)
% 能量上下限
% 能量在最大、最小之间 NOFDER * REST_SLOTS + 1
Constraints = [Constraints, param_std.energy_lower_limit(:, CUR_SLOT : end) <= E(:, 2 : end) + delta_E1(:, 2 : end)];
Constraints = [Constraints, E(:, 2 : end) - delta_E2(:, 2 : end) <= param_std.energy_upper_limit(:, CUR_SLOT : end)];
Constraints = [Constraints, 0 <= delta_E1];
Constraints = [Constraints, 0 <= delta_E2];

% 调频投标的连续出力(持续时间)约束 REST_SLOTS
delta_t_req = 0.5;
% 放电（d_s = 1），最后一个调频场景
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, REST_SLOTS) ...
    .* E(:, 2 : end - 1) - delta_t_req * param_std.eta_dis * P_dis(:, 2 : end, end) ...
    + delta_t_req * param_std.wOmiga(:, CUR_SLOT + 1 : end) >= param_std.energy_lower_limit(:, CUR_SLOT : end - 1) - delta_E3];

% 充电（d_s = -1），第一个调频场景
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, REST_SLOTS) ...
    .* E(:, 2 : end - 1) - delta_t_req * param_std.eta_ch * P_ch(:, 2 : end, 1) ...
    + delta_t_req * param_std.wOmiga(:, CUR_SLOT + 1 : end) <= param_std.energy_upper_limit(:, CUR_SLOT : end - 1) + delta_E4];
Constraints = [Constraints, 0 <= delta_E3];
Constraints = [Constraints, 0 <= delta_E4];

% 前后时段衔接 NOFDER * (REST_SLOTS + 1,)
temp = repmat(param.hourly_Distribution(CUR_SLOT : end, :)', 1, NOFDER);
% 分布重复为 SCEN * (SLOTS * DER)
temp_ch = permute(P_ch, [3, 2, 1]);% 交换行列
temp_ch = reshape(temp_ch, NOFSCEN, (REST_SLOTS + 1) * NOFDER);% 功率铺平为 SCEN * (SLOTS * DER)
temp_ch = sum(temp_ch .* temp);% 相乘，并按概率加权相加
temp_ch = reshape(temp_ch, (REST_SLOTS + 1), NOFDER)';% 重新写为 SLOTS * DER,并转置为DER * SLOTS

temp_dis = permute(P_dis, [3, 2, 1]);% 交换行列
temp_dis = reshape(temp_dis, NOFSCEN, (REST_SLOTS + 1) * NOFDER);% 功率铺平为 SCEN * (SLOTS * DER)
temp_dis = sum(temp_dis .* temp);% 相乘，并按概率加权相加
temp_dis = reshape(temp_dis, (REST_SLOTS + 1), NOFDER)';% 重新写为 SLOTS * DER,并转置为DER * SLOTS

Constraints = [Constraints, E(:, 3 : end) == repmat(param_std.theta, 1, REST_SLOTS) .* E(:, 2 : end - 1) ...
    + param_std.eta_ch * temp_ch(:, 2 : end) * delta_t ...
    - param_std.eta_dis * temp_dis(:, 2 : end) * delta_t ...
    + param_std.wOmiga(:, CUR_SLOT + 1 : end) * delta_t];% 未来时段

Constraints = [Constraints, E(:, 2) == (ones(NOFDER, 1) - delta_t_rest * (ones(NOFDER, 1) - param_std.theta)) .* E(:, 1) ...
    + param_std.eta_ch * temp_ch(:, 1) * delta_t_rest ...
    - param_std.eta_dis * temp_dis(:, 1) * delta_t_rest ...
    + param_std.wOmiga(:, CUR_SLOT) * delta_t_rest];% 当前时段

% 不参加调频资源的限制
Constraints = [Constraints, R_DER(param.index_none_reg, :) == zeros(5, REST_SLOTS)];



%% 求解solve
ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);

sol = optimize(Constraints, - Profit, ops);

%% 记录
if sol.problem == 0 || sol.problem == 4% 求解成功
    disp("时段" + (CUR_SLOT) + " :更新投标完成。时刻：" + t_cap)
    % 记录,更新投标
    result.Bid_R_rev(CUR_SLOT+1 : end) = value(Bid_R);
    result.Bid_P_rev(CUR_SLOT+1 : end) = value(Bid_P);
    result.P_DER_rev(:, CUR_SLOT+1 : end) = value(P_DER);
    result.R_DER_rev(:, CUR_SLOT+1 : end) = value(R_DER);
    % 非调频资源出力
    result.p_none_reg = value(value(P_ch(param.index_none_reg, 1, 1)));

else
    disp("时段" + (CUR_SLOT) + " :投标优化失败。时刻：" + t_cap)
end


