%% ������(̰���㷨)
clc;clear;
% �洢���
yalmip("clear");
result = {};

%% ������ȡ

% Ĭ��21������
day_price = 21;
load(fullfile("..", "data_prepare", "param_day_" + day_price + ".mat"));

% ���²���
NOFTCAP_bid = 900;
NOFTCAP_ctrl = 30;
result.P_alloc = [];% ���ڼ�¼���
result.actualMil = zeros(NOFSLOTS, 1);
result.actualEnergy = zeros(NOFSLOTS, 1);
result.actualCost = zeros(NOFSLOTS, 1);

%% ��ʼʱ��
warning('off')
maxProfit_1;

%% �м�ʱ��
for t_cap = 1 : (NOFSLOTS - 1) * 1800
    if mod(t_cap, NOFTCAP_bid) == 1 % ʱ�γ����м�������³��Ӳ����书�ʣ��������µ�ǰʱ��Ͷ��
        delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800;% ��ǰʱ��ʣ��ʱ��
        maxProfit_t;
    end
    if  mod(t_cap, NOFTCAP_ctrl) == 1 % ���书�ʣ��������µ�ǰʱ��Ͷ��
        delta_t_rest = delta_t - mod(t_cap - 1, 1800) / 1800;% ��ǰʱ��ʣ��ʱ��
        fastControl_prepare;% ����L���Ӳ������������
        fastControl_implement;% ���ʷ���
    end

end

% ���һ��ʱ�Σ�������Ͷ��
for t_cap = (NOFSLOTS - 1) * 1800 + 1 : NOFSLOTS * 1800 - 1
    if mod(t_cap, NOFTCAP_ctrl) == 1 % ʱ�γ����м�������书��
        sol.solveroutput.lambda.eqlin(1 : NOFDER) = zeros(NOFDER, 1);% ������ֵ����
        fastControl_prepare;% ����L���Ӳ������������
        fastControl_implement;% ���ʷ���
    end
end

%% �г�����
result.actualEnegyFee = param.price_e .* result.actualEnergy;
result.actualProfit =  param.price_reg(:, 1) .* result.Bid_R_rev * param.s_perf + ...
    (param.price_reg(:, 2) .* result.actualMil) * param.s_perf;
% ����ʱ�γ���
result.actualProfit =  result.actualProfit * delta_t;

save(fullfile("..", "results", "result_tx_greedy_bid_ctrl_sep_.mat"), "result");

% main_seperate;
