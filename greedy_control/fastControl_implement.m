%% 输出各资源出力，并改变状态
% 输入：各资源的出力（NOFDER * 1）
% 输出：各资源的状态改变、累计成本积累

result.p_dis = [];
result.p_ch = [];

delta_t_cap = NOFTCAP_ctrl / 1800;
%% 参数处理

for t_cap_dx = t_cap : t_cap + NOFTCAP_ctrl - 1
    
% 取出信号
delta = Signal_day(t_cap_dx);

% 需要的响应量
P_req = Bid_P_cur + Bid_R_cur * delta;

param_std.seg_p_allocated = param_std.seg_parameter;
% 功率分配
%% 接收到调频信号后，快速决定各DER的出力
% 输入：调频信号要求的总功率 P_req
% 输出：各资源的出力（NOFDER * 1）

%% 功率分配
% 初始化为最小值
p_allocated = param_std.seg_parameter(:, 4);
% 初始功率偏差
delta_p = P_req - sum(p_allocated);
% 编号.矩阵： (index, flag_ch, c_k, p_lower, p_upper)
kdx = 1;

while delta_p > 0
    if param_std.seg_parameter(kdx, 5) - p_allocated(kdx) < delta_p
        % 功率偏差大于功率段长度
        p_allocated(kdx) = param_std.seg_parameter(kdx, 5);% 功率段拉满
        delta_p = delta_p - param_std.seg_parameter(kdx, 5) + param_std.seg_parameter(kdx, 4);
        kdx = kdx + 1;
    else
        p_allocated(kdx) = param_std.seg_parameter(kdx, 4) + delta_p;% 功率段补齐
        delta_p = 0;
    end
    
    % 可能存在数值问题
    if kdx > 2 * NOFDER
        break;
    end
end

%% 恢复功率 
% 从k编号的p_allocated中恢复为i编号，并存储到param_std.seg_p_allocated中

param_std.seg_p_allocated = [param_std.seg_p_allocated, p_allocated];
% 第2列加到第一列，从而按照序号恢复。
param_std.seg_p_allocated(:, 1) = param_std.seg_p_allocated(:, 1) ...
    + 0.5 * param_std.seg_p_allocated(:, 2);
% 按照序号恢复
param_std.seg_p_allocated = sortrows(param_std.seg_p_allocated, 1);

% 变量代换
param_std.seg_p_allocated = reshape(param_std.seg_p_allocated(:, end), 2, NOFDER)';

% 记录充/放电功率
result.p_dis_cap = param_std.seg_p_allocated(:, 1);
result.p_ch_cap = - param_std.seg_p_allocated(:, 2);

% 记录分配结果
result.p_dis = [result.p_dis, result.p_dis_cap];
result.p_ch = [result.p_ch, result.p_ch_cap];

end

%% 更新数据
% 更新电量
result.E_cur = (ones(NOFDER, 1) - delta_t_cap * (ones(NOFDER, 1) - param_std.theta)) .* result.E_cur ...
    + param_std.eta_ch * result.p_ch * ones(NOFTCAP_ctrl, 1) / 1800 ...
    - param_std.eta_dis * result.p_dis  * ones(NOFTCAP_ctrl, 1) / 1800 ...
    + param_std.wOmiga(:, CUR_SLOT) * delta_t_cap;
E_cur = result.E_cur;
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


