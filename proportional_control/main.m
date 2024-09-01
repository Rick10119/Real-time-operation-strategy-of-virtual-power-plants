%% 主程序
clc;clear;
% 存储结果
yalmip("clear");
result = {};

%% 参数读取

% 默认21日数据
day_price = 21;
load("../data_prepare/param_day_" + day_price + ".mat")

% 更新步长
NOFTCAP_bid = 900;
NOFTCAP_ctrl = 30;
result.P_alloc = [];% 用于记录结果
result.actualMil = zeros(NOFSLOTS, 1);
result.actualEnergy = zeros(NOFSLOTS, 1);
result.actualCost = zeros(NOFSLOTS, 1);

%% 初始时段
warning('off')
maxProfit_1;

%% 中间时段
for t_cap = 1 : (NOFSLOTS - 1) * 1800
    if mod(t_cap, NOFTCAP_bid) == 1 % 时段初或中间初，更新乘子并分配功率，但不更新当前时段投标
        delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800;% 当前时段剩余时间
        maxProfit_t;
    end
    if  mod(t_cap, NOFTCAP_ctrl) == 1 % 分配功率，但不更新当前时段投标
        fastControl_implement;% 功率分配
    end

end

% 最后一个时段，不用再投标
for t_cap = (NOFSLOTS - 1) * 1800 + 1 : NOFSLOTS * 1800 - 1
    if mod(t_cap, NOFTCAP_ctrl) == 1 % 时段初或中间初，分配功率
        fastControl_implement;% 功率分配
    end
end

%% 市场收益
result.actualEnegyFee = param.price_e .* result.actualEnergy;
result.actualProfit =  param.price_reg(:, 1) .* result.Bid_R_rev * param.s_perf + ...
    (param.price_reg(:, 2) .* result.actualMil) * param.s_perf;
% 乘以时段长度
result.actualProfit =  result.actualProfit * delta_t;

save("../results/result_prop_ctrl_sep_.mat", "result");

% main_seperate;
