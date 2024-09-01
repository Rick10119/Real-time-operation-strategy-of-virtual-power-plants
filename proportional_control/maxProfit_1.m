%% 拉通投标，从时段1开始

% 用于：1、初值产生；2、计算拉格朗日乘子

% 输入：各时段能量、调频市场价格；电动汽车到达、离开的时段、电量；
% 输出：各时段投标量、电池电量

%% 参数设定

% 见 data_prepare_main.m



%% 变量定义
% 投标容量：能量、调频(MW)
Bid_P = sdpvar(NOFSLOTS, 1, 'full'); 
Bid_R = sdpvar(NOFSLOTS, 1, 'full'); 
R_DER = sdpvar(NOFDER, NOFSLOTS, 'full');% 分配到各资源的调频容量
P_DER = sdpvar(NOFDER, NOFSLOTS, 'full');% 分配到各资源的基准出力

% 辅助变量
P_dis = sdpvar(NOFDER, NOFSLOTS, NOFSCEN, 'full'); % DER在各场景放电功率(kW)
P_ch = sdpvar(NOFDER, NOFSLOTS, NOFSCEN, 'full'); % DER在各场景充电功率(kW)
E = sdpvar(NOFDER, NOFSLOTS + 1, 'full'); % DER在各时段之初的电池能量(kWh)。包括离开时刻(时段初)，因此多一个维度
Cost_deg = sdpvar(NOFSLOTS, NOFSCEN, 'full');% 各时段各场景的老化成本($)


%% 目标函数
% 能量收益、调频容量收益、调频里程收益、部署成本、性能成本
Profit = param.price_e' * Bid_P + param.price_reg(:, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(:, 2) .* param.hourly_Mileage)' * Bid_R * param.s_perf + ...
     ((param.hourly_Distribution * param.d_s) .* param.price_e)' * Bid_R - ...
     sum(sum(param.hourly_Distribution .* Cost_deg));
% 乘以时段长度
Profit = Profit * delta_t;

%% 约束条件

Constraints = [];

% 最初为达到时的电量(第四列) NOFDER
Constraints = [Constraints, param_std.energy_init - E(:, 1) == 0];

% 功率响应-各场景平衡 NOFSLOTS * NOFSCEN
% 比例分配的约束
% 这些资源在各个场景出力成比例
temp = reshape(param.d_s, 1, 1, NOFSCEN);
Constraints = [Constraints, P_dis - P_ch == repmat(P_DER, 1, 1, NOFSCEN) ...
    + repmat(R_DER, 1, 1, NOFSCEN) .* repmat(temp, NOFDER, NOFSLOTS, 1)];

Constraints = [Constraints, Bid_P == sum(P_DER)'];
Constraints = [Constraints, Bid_R == sum(R_DER)'];
    
% 功率上下限(MW)。 NOFDER * NOFSLOTS * NOFSCEN
Constraints = [Constraints, repmat(param_std.power_dis_lower_limit, 1, 1, NOFSCEN) <= P_dis];
Constraints = [Constraints, repmat(param_std.power_ch_lower_limit, 1, 1, NOFSCEN) <= P_ch];
Constraints = [Constraints, P_dis <=repmat(param_std.power_dis_upper_limit, 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch <= repmat(param_std.power_ch_upper_limit, 1, 1, NOFSCEN)];

% 功率带来的成本 NOFSLOTS * NOFSCEN
temp = permute(sum(repmat(param_std.pr_dis, 1, NOFSLOTS, NOFSCEN) .* P_dis + ...
    repmat(param_std.pr_ch, 1, NOFSLOTS, NOFSCEN) .* P_ch), [2, 3, 1]);% 把DER的功率聚合, 交换行列 
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, Cost_deg == temp];

% 时段间能量关联(MWh)
% 能量上下限
% 中间时段的能量在最大、最小之间 NOFDER * NOFSLOTS
Constraints = [Constraints, param_std.energy_lower_limit <= E(:, 2 : end)];
Constraints = [Constraints, E(:, 2 : end) <= param_std.energy_upper_limit];

% 调频投标的连续出力(持续时间)约束 NOFSLOTS
% 放电（d_s = 1），最后一个调频场景
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, NOFSLOTS) ...
    .* E(:, 1 : end - 1) - delta_t_req * param_std.eta_dis * P_dis(:, :, end) ...
    + delta_t_req * param_std.wOmiga >= param_std.energy_lower_limit(:, [1, 1 : end - 1])];

% 充电（d_s = -1），第一个调频场景
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, NOFSLOTS) ...
    .* E(:, 1 : end - 1) - delta_t_req * param_std.eta_ch * P_ch(:, :, 1) ...
    + delta_t_req * param_std.wOmiga <= param_std.energy_upper_limit(:, [1, 1 : end - 1])];

% 前后时段衔接 NOFDER * NOFSLOTS
temp = repmat(param.hourly_Distribution', 1, NOFDER);
% 分布重复为 SCEN * (SLOTS * DER)
temp_ch = permute(P_ch, [3, 2, 1]);% 交换行列
temp_ch = reshape(temp_ch, NOFSCEN, NOFSLOTS * NOFDER);% 功率铺平为 SCEN * (SLOTS * DER)
temp_ch = sum(temp_ch .* temp);% 相乘，并按概率加权相加
temp_ch = reshape(temp_ch, NOFSLOTS, NOFDER)';% 重新写为 SLOTS * DER,并转置为DER * SLOTS

temp_dis = permute(P_dis, [3, 2, 1]);% 交换行列
temp_dis = reshape(temp_dis, NOFSCEN, NOFSLOTS * NOFDER);% 功率铺平为 SCEN * (SLOTS * DER)
temp_dis = sum(temp_dis .* temp);% 相乘，并按概率加权相加
temp_dis = reshape(temp_dis, NOFSLOTS, NOFDER)';% 重新写为 SLOTS * DER,并转置为DER * SLOTS

Constraints = [Constraints, E(:, 2 : end) == repmat(param_std.theta, 1, NOFSLOTS) .* E(:, 1 : end - 1) ...
    + param_std.eta_ch * temp_ch * delta_t ...
    - param_std.eta_dis * temp_dis * delta_t ...
    + param_std.wOmiga * delta_t];

% 不参加调频资源的限制
Constraints = [Constraints, R_DER(param.index_none_reg, :) == zeros(5, NOFSLOTS)];


%% 求解solve
ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);

sol = optimize(Constraints, - Profit, ops);

if sol.problem == 0 % 求解成功
    disp("时段1 :投标完成。")
else 
    disp("时段1 :投标失败。")
end



%% 记录
result.Bid_R_init = value(Bid_R);
result.Bid_P_init = value(Bid_P);
result.E_init = value(E);
result.Bid_R_cur = value(Bid_R(1));
result.Bid_P_cur = value(Bid_P(1));
result.E_cur = value(E(:, 1));
result.P_DER_cur = value(P_DER(:, 1));
result.R_DER_cur = value(R_DER(:, 1));




% 用于后续的记录
result.Bid_R_rev = value(Bid_R);
result.Bid_P_rev = value(Bid_P);
result.P_DER_rev = value(P_DER);
result.R_DER_rev = value(R_DER);
result.E_rev = result.E_cur;


