%% ��ͨͶ�꣬��ʱ��1��ʼ

% ���ڣ�1����ֵ������2�������������ճ���

% ���룺��ʱ����������Ƶ�г��۸񣻵綯��������뿪��ʱ�Ρ�������
% �������ʱ��Ͷ��������ص���

%% �����趨

% �� data_prepare_main.m



%% ��������
% Ͷ����������������Ƶ(MW)
Bid_P = sdpvar(NOFSLOTS, 1, 'full'); 
Bid_R = sdpvar(NOFSLOTS, 1, 'full'); 

% ��������
P_dis = sdpvar(NOFDER, NOFSLOTS, NOFSCEN, 'full'); % DER�ڸ������ŵ繦��(kW)
P_ch = sdpvar(NOFDER, NOFSLOTS, NOFSCEN, 'full'); % DER�ڸ�������繦��(kW)
E = sdpvar(NOFDER, NOFSLOTS + 1, 'full'); % DER�ڸ�ʱ��֮���ĵ������(kWh)�������뿪ʱ��(ʱ�γ�)����˶�һ��ά��
Cost_deg = sdpvar(NOFSLOTS, NOFSCEN, 'full');% ��ʱ�θ��������ϻ��ɱ�($)

%% Ŀ�꺯��
% �������桢��Ƶ�������桢��Ƶ������桢����ɱ������ܳɱ�
Profit = param.price_e' * Bid_P + param.price_reg(:, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(:, 2) .* param.hourly_Mileage)' * Bid_R * param.s_perf + ...
     ((param.hourly_Distribution * param.d_s) .* param.price_e)' * Bid_R - ...
     sum(sum(param.hourly_Distribution .* Cost_deg));
% ����ʱ�γ���
Profit = Profit * delta_t;

%% Լ������

Constraints = [];

% ���Ϊ�ﵽʱ�ĵ���(������) NOFDER
Constraints = [Constraints, param_std.energy_init - E(:, 1) == 0];

% ������Ӧ-������ƽ�� NOFSLOTS * NOFSCEN
temp = permute(sum(P_dis - P_ch), [2, 3, 1]);% ��DER�Ĺ��ʾۺ�
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, repmat(Bid_P, 1, NOFSCEN) + ...
    repmat(Bid_R, 1, NOFSCEN) .* repmat(param.d_s', NOFSLOTS, 1) - temp == 0];
    
% ����������(MW)�� NOFDER * NOFSLOTS * NOFSCEN
Constraints = [Constraints, repmat(param_std.power_dis_lower_limit, 1, 1, NOFSCEN) <= P_dis];
Constraints = [Constraints, repmat(param_std.power_ch_lower_limit, 1, 1, NOFSCEN) <= P_ch];
Constraints = [Constraints, P_dis <=repmat(param_std.power_dis_upper_limit, 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch <= repmat(param_std.power_ch_upper_limit, 1, 1, NOFSCEN)];

% ���ʴ����ĳɱ� NOFSLOTS * NOFSCEN
temp = permute(sum(repmat(param_std.pr_dis, 1, NOFSLOTS, NOFSCEN) .* P_dis + ...
    repmat(param_std.pr_ch, 1, NOFSLOTS, NOFSCEN) .* P_ch), [2, 3, 1]);% ��DER�Ĺ��ʾۺ�, �������� 
temp = reshape(temp, NOFSLOTS, NOFSCEN);

Constraints = [Constraints, Cost_deg == temp];

% ʱ�μ���������(MWh)
% ����������
% �м�ʱ�ε������������С֮�� NOFDER * NOFSLOTS
Constraints = [Constraints, param_std.energy_lower_limit <= E(:, 2 : end)];
Constraints = [Constraints, E(:, 2 : end) <= param_std.energy_upper_limit];

% ��ƵͶ�����������(����ʱ��)Լ�� NOFSLOTS
% �ŵ磨d_s = 1�������һ����Ƶ����
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, NOFSLOTS) ...
    .* E(:, 1 : end - 1) - delta_t_req * param_std.eta_dis * P_dis(:, :, end) ...
    + delta_t_req * param_std.wOmiga >= param_std.energy_lower_limit(:, [1, 1 : end - 1])];

% ��磨d_s = -1������һ����Ƶ����
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, NOFSLOTS) ...
    .* E(:, 1 : end - 1) - delta_t_req * param_std.eta_ch * P_ch(:, :, 1) ...
    + delta_t_req * param_std.wOmiga <= param_std.energy_upper_limit(:, [1, 1 : end - 1])];

% ǰ��ʱ���ν� NOFDER * NOFSLOTS
temp = repmat(param.hourly_Distribution', 1, NOFDER);
% �ֲ��ظ�Ϊ SCEN * (SLOTS * DER)
temp_ch = permute(P_ch, [3, 2, 1]);% ��������
temp_ch = reshape(temp_ch, NOFSCEN, NOFSLOTS * NOFDER);% ������ƽΪ SCEN * (SLOTS * DER)
temp_ch = sum(temp_ch .* temp);% ��ˣ��������ʼ�Ȩ���
temp_ch = reshape(temp_ch, NOFSLOTS, NOFDER)';% ����дΪ SLOTS * DER,��ת��ΪDER * SLOTS

temp_dis = permute(P_dis, [3, 2, 1]);% ��������
temp_dis = reshape(temp_dis, NOFSCEN, NOFSLOTS * NOFDER);% ������ƽΪ SCEN * (SLOTS * DER)
temp_dis = sum(temp_dis .* temp);% ��ˣ��������ʼ�Ȩ���
temp_dis = reshape(temp_dis, NOFSLOTS, NOFDER)';% ����дΪ SLOTS * DER,��ת��ΪDER * SLOTS

Constraints = [Constraints, E(:, 2 : end) == repmat(param_std.theta, 1, NOFSLOTS) .* E(:, 1 : end - 1) ...
    + param_std.eta_ch * temp_ch * delta_t ...
    - param_std.eta_dis * temp_dis * delta_t ...
    + param_std.wOmiga * delta_t];

% ���μӵ�Ƶ��Դ������
% ��Щ��Դ�ڸ�������������ͬ
Constraints = [Constraints, P_dis(param.index_none_reg, :, :) == repmat(P_dis(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch(param.index_none_reg, :, :) == repmat(P_ch(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];

%% ���solve
ops = sdpsettings('debug',0,'solver','gurobi','savesolveroutput',1,'savesolverinput',1,'verbose', 0);

sol = optimize(Constraints, - Profit, ops);

if sol.problem == 0 % ���ɹ�
    disp("ʱ��1 :Ͷ����ɡ�")
else 
    disp("ʱ��1 :Ͷ��ʧ�ܡ�")
end



%% ��¼
result.Bid_R_init = value(Bid_R);
result.Bid_P_init = value(Bid_P);
result.E_init = value(E);
result.Bid_R_cur = value(Bid_R(1));
result.Bid_P_cur = value(Bid_P(1));
result.E_cur = value(E(:, 1));



% ���ں����ļ�¼
result.Bid_R_rev = value(Bid_R);
result.Bid_P_rev = value(Bid_P);
result.E_rev = result.E_cur;


