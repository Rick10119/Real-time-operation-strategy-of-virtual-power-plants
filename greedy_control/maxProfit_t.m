%% ������һʱ��Ͷ�������У���ص�����Ӱ�Ӽ۸����ڵ�ǰʱ�ν��з���

% ���ڣ�������һʱ��Ͷ�����������������ճ���

% ���룺��ʱ����������Ƶ�г��۸񣻵綯��������뿪��ʱ�Ρ���������ǰʱ��ʱ��t_cap; ��ǰʱ�ε�Ͷ����
% ���룺��ǰ����ص�����
% ��ֵ�� ��һʱ��Ͷ��ʱ����ʱ�ε�Ͷ������
% ���:  δ����ʱ��Ͷ��������ص�����δ��һ��ʱ��L����


%% �����趨

% ���ࣺ�� data_prepare.m

% ��ǰʱ�α�� CUR_SLOT
CUR_SLOT = ceil(t_cap / 1800);% 2sһ��������1800����ȡ����Ϊ��ǰʱ�α��
% ʣ��ʱ������
REST_SLOTS = NOFSLOTS - CUR_SLOT;

% ��ǰʱ�ε��б���
Bid_R_cur = result.Bid_R_rev(CUR_SLOT);
Bid_P_cur = result.Bid_P_rev(CUR_SLOT);
result.Bid_R_cur = result.Bid_R_rev(CUR_SLOT);
result.Bid_P_cur = result.Bid_P_rev(CUR_SLOT);
E_cur = result.E_cur ;


%% ����
% Ͷ����������������Ƶ(MW), ��t + 1��T, ����t + 1Ϊ��һ��entry
Bid_P = sdpvar(REST_SLOTS, 1, 'full');
Bid_R = sdpvar(REST_SLOTS, 1, 'full');

% ��������
P_dis = sdpvar(NOFDER, REST_SLOTS + 1, NOFSCEN, 'full'); % DER�ڸ������ŵ繦��(kW),��ǰʱ��ʣ��ʱ����ȻҪ���䣬��˶�һ��ʱ��ά��
P_ch = sdpvar(NOFDER, REST_SLOTS + 1, NOFSCEN, 'full'); % DER�ڸ�������繦��(kW),��ǰʱ��ʣ��ʱ����ȻҪ���䣬��˶�һ��ʱ��ά��
E = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % DER�ڸ�ʱ��֮���ĵ������(kWh)��������ǰʱ�̡��뿪ʱ�̣���˶�2��ά��
delta_E1 = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % ���ڼ��㷣��
delta_E2 = sdpvar(NOFDER, REST_SLOTS + 2, 'full'); % ���ڼ��㷣��
delta_E3 = sdpvar(NOFDER, REST_SLOTS, 'full'); % ���ڼ��㷣��
delta_E4 = sdpvar(NOFDER, REST_SLOTS, 'full'); % ���ڼ��㷣��
Cost_perf = sdpvar(REST_SLOTS + 1, NOFSCEN, 'full');% δ����ʱ�θ����������ܳɱ�($/h)

%% Ŀ�꺯��
% �������桢��Ƶ�������桢��Ƶ������桢����ɱ������ܳɱ�
Profit = param.price_e(CUR_SLOT + 1 : end)' * Bid_P + param.price_reg(CUR_SLOT + 1 : end, 1)' * Bid_R * param.s_perf + ...
    (param.price_reg(CUR_SLOT + 1 : end, 2) .* param.hourly_Mileage(CUR_SLOT + 1 : end))' * Bid_R * param.s_perf + ...
    ((param.hourly_Distribution(CUR_SLOT + 1 : end, :) * param.d_s) .* param.price_e(CUR_SLOT + 1 : end))' * Bid_R - ...
    sum(sum(param.hourly_Distribution(CUR_SLOT + 1 : end, :) .* Cost_perf(2 : end, :)));

% ����ʱ�γ���
Profit = Profit * delta_t;

%���ϵ�ǰʱ�εĳɱ�
Profit = Profit - ((param.hourly_Distribution(CUR_SLOT, :) * param.d_s) .* param.price_e(CUR_SLOT))' * Bid_R_cur * delta_t_rest - ...
    sum(sum(param.hourly_Distribution(CUR_SLOT, :) .* Cost_perf(1, :))) * delta_t_rest;

% ����Լ���ķ���
Profit = Profit - M * sum(sum(delta_E1)) - M * sum(sum(delta_E2)) ...
    - M * sum(sum(delta_E3)) - M * sum(sum(delta_E4));

%% Լ������

Constraints = [];

% ��ǰ�������ɴ��Ƴ�L����
Constraints = [Constraints, E_cur - E(:, 1) == 0];

% ������Ӧ-������ƽ�⡣ REST_SLOTS + 1 * NOFSCEN
temp = permute(sum(P_dis - P_ch), [2, 3, 1]);% ��DER�Ĺ��ʾۺ�
temp = reshape(temp, REST_SLOTS + 1, NOFSCEN);

Constraints = [Constraints, repmat(Bid_P, 1, NOFSCEN) + ...
    repmat(Bid_R, 1, NOFSCEN) .* repmat(param.d_s', REST_SLOTS, 1) - temp(2 : end, :) == 0];% δ����ʱ��
Constraints = [Constraints, repmat(Bid_P_cur, 1, NOFSCEN) + ...
    repmat(Bid_R_cur, 1, NOFSCEN) .* param.d_s' - temp(1, :) == 0];% ��ǰʱ��

% ����������(kW)�� NOFDER * REST_SLOTS * NOFSCEN
Constraints = [Constraints, repmat(param_std.power_dis_lower_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN) <= P_dis];
Constraints = [Constraints, repmat(param_std.power_ch_lower_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN) <= P_ch];
Constraints = [Constraints, P_dis <= repmat(param_std.power_dis_upper_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch <= repmat(param_std.power_ch_upper_limit(:, CUR_SLOT : end), 1, 1, NOFSCEN)];

% �ŵ��ϻ�($) REST_SLOTS + 1 * NOFSCEN
temp = permute(sum(repmat(param_std.pr_dis, 1, REST_SLOTS + 1, NOFSCEN) .* P_dis + ...
    repmat(param_std.pr_ch, 1, REST_SLOTS + 1, NOFSCEN) .* P_ch), [2, 3, 1]);% ��DER�Ĺ��ʾۺ�, ��������
temp = reshape(temp, REST_SLOTS + 1, NOFSCEN);

Constraints = [Constraints, Cost_perf == temp];

% ʱ�μ���������(kWh)
% ����������
% �����������С֮�� NOFDER * REST_SLOTS + 1
Constraints = [Constraints, param_std.energy_lower_limit(:, CUR_SLOT : end) <= E(:, 2 : end) + delta_E1(:, 2 : end)];
Constraints = [Constraints, E(:, 2 : end) - delta_E2(:, 2 : end) <= param_std.energy_upper_limit(:, CUR_SLOT : end)];
Constraints = [Constraints, 0 <= delta_E1];
Constraints = [Constraints, 0 <= delta_E2];

% ��ƵͶ�����������(����ʱ��)Լ�� REST_SLOTS
delta_t_req = 0.5;
% �ŵ磨d_s = 1�������һ����Ƶ����
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, REST_SLOTS) ...
    .* E(:, 2 : end - 1) - delta_t_req * param_std.eta_dis * P_dis(:, 2 : end, end) ...
    + delta_t_req * param_std.wOmiga(:, CUR_SLOT + 1 : end) >= param_std.energy_lower_limit(:, CUR_SLOT : end - 1) - delta_E3];

% ��磨d_s = -1������һ����Ƶ����
Constraints = [Constraints, repmat((ones(NOFDER, 1) - delta_t_req * (ones(NOFDER, 1) - param_std.theta)), 1, REST_SLOTS) ...
    .* E(:, 2 : end - 1) - delta_t_req * param_std.eta_ch * P_ch(:, 2 : end, 1) ...
    + delta_t_req * param_std.wOmiga(:, CUR_SLOT + 1 : end) <= param_std.energy_upper_limit(:, CUR_SLOT : end - 1) + delta_E4];
Constraints = [Constraints, 0 <= delta_E3];
Constraints = [Constraints, 0 <= delta_E4];

% ǰ��ʱ���ν� NOFDER * (REST_SLOTS + 1,)
temp = repmat(param.hourly_Distribution(CUR_SLOT : end, :)', 1, NOFDER);
% �ֲ��ظ�Ϊ SCEN * (SLOTS * DER)
temp_ch = permute(P_ch, [3, 2, 1]);% ��������
temp_ch = reshape(temp_ch, NOFSCEN, (REST_SLOTS + 1) * NOFDER);% ������ƽΪ SCEN * (SLOTS * DER)
temp_ch = sum(temp_ch .* temp);% ��ˣ��������ʼ�Ȩ���
temp_ch = reshape(temp_ch, (REST_SLOTS + 1), NOFDER)';% ����дΪ SLOTS * DER,��ת��ΪDER * SLOTS

temp_dis = permute(P_dis, [3, 2, 1]);% ��������
temp_dis = reshape(temp_dis, NOFSCEN, (REST_SLOTS + 1) * NOFDER);% ������ƽΪ SCEN * (SLOTS * DER)
temp_dis = sum(temp_dis .* temp);% ��ˣ��������ʼ�Ȩ���
temp_dis = reshape(temp_dis, (REST_SLOTS + 1), NOFDER)';% ����дΪ SLOTS * DER,��ת��ΪDER * SLOTS

Constraints = [Constraints, E(:, 3 : end) == repmat(param_std.theta, 1, REST_SLOTS) .* E(:, 2 : end - 1) ...
    + param_std.eta_ch * temp_ch(:, 2 : end) * delta_t ...
    - param_std.eta_dis * temp_dis(:, 2 : end) * delta_t ...
    + param_std.wOmiga(:, CUR_SLOT + 1 : end) * delta_t];% δ��ʱ��

Constraints = [Constraints, E(:, 2) == (ones(NOFDER, 1) - delta_t_rest * (ones(NOFDER, 1) - param_std.theta)) .* E(:, 1) ...
    + param_std.eta_ch * temp_ch(:, 1) * delta_t_rest ...
    - param_std.eta_dis * temp_dis(:, 1) * delta_t_rest ...
    + param_std.wOmiga(:, CUR_SLOT) * delta_t_rest];% ��ǰʱ��

% ���μӵ�Ƶ��Դ������
% ��Щ��Դ�ڸ�������������ͬ
Constraints = [Constraints, P_dis(param.index_none_reg, :, :) == repmat(P_dis(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];
Constraints = [Constraints, P_ch(param.index_none_reg, :, :) == repmat(P_ch(param.index_none_reg, :, 1), 1, 1, NOFSCEN)];


%% ���solve
ops = sdpsettings('debug',0,'solver','gurobi','savesolveroutput',1,'savesolverinput',1,'verbose', 0);

sol = optimize(Constraints, - Profit, ops);

%% ��¼
if sol.problem == 0 || sol.problem == 4% ���ɹ�
    disp("ʱ��" + (CUR_SLOT) + " :����Ͷ����ɡ�ʱ�̣�" + t_cap)
    % ��¼,����Ͷ��
    result.Bid_R_rev(CUR_SLOT+1 : end) = value(Bid_R);
    result.Bid_P_rev(CUR_SLOT+1 : end) = value(Bid_P);
    % �ǵ�Ƶ��Դ����
    result.p_none_reg = value(value(P_ch(param.index_none_reg, 1, 1)));

else
    disp("ʱ��" + (CUR_SLOT) + " :Ͷ���Ż�ʧ�ܡ�")
end


