%% Read other resource parameters
% All need to be converted to MW units

%% New Energy (PV)
load("output_pv.mat");
param.power_dis_upper_limit_pv = output_pv';
param.power_dis_lower_limit_pv = 0 * output_pv';

%% Energy Storage
param.energy_init_es = 1; % Initial energy
param.energy_upper_limit_es = 0.9 * 2; % Energy upper limit
param.energy_lower_limit_es = 0.1 * 2; % Energy lower limit
param.power_dis_upper_limit_es = 1; % Discharge power upper limit
param.power_dis_lower_limit_es = 0; % Discharge power lower limit
param.power_ch_upper_limit_es = 1; % Charge power upper limit
param.power_ch_lower_limit_es = 0; % Charge power lower limit
param.theta_es = 1; % Retention rate
param.eta_dis_es = 0.90; % Discharge efficiency
param.eta_ch_es = 0.90; % Charge efficiency
param.pr_dis_es = 100; % Discharge cost $/MWh
param.pr_ch_es = 100; % Charge cost $/MWh

%% Electric Vehicles
% Read EV arrive time from Excel
filename = 'EV_arrive_leave.xlsx';
sheet = 'EV_arrive_leave'; % Sheet name
xlRange = 'A2:C121'; % Range

% EV number, arrival time slot, departure time slot
EV_arrive_leave = xlsread(filename, sheet, xlRange);

param.energy_init_ev = 20 * 1e-3; % Initial energy
param.energy_end_ev = 50 * 1e-3; % Minimum energy at the end
param.energy_upper_limit_ev = 60 * 0.9 * 1e-3; % Energy upper limit, 60kWh converted to MWh
param.energy_lower_limit_ev = 60 * 0.1 * 1e-3; % Energy lower limit
param.power_dis_upper_limit_ev = 22 * 1e-3; % Discharge power upper limit
param.power_dis_lower_limit_ev = 0; % Discharge power lower limit
param.power_ch_upper_limit_ev = 22 * 1e-3; % Charge power upper limit
param.power_ch_lower_limit_ev = 0; % Charge power lower limit
param.theta_ev = 1; % Retention rate
param.eta_dis_ev = 0.90; % Discharge efficiency
param.eta_ch_ev = 0.90; % Charge efficiency
param.pr_dis_ev = 150; % Discharge cost $/MWh
param.pr_ch_ev = 0; % Charge cost $/MWh

% Number of EVs
NOFEV = length(EV_arrive_leave);
% Charging status u
param.u = zeros(NOFEV, NOFSLOTS);
for idx = 1 : NOFEV
    for jdx = 1 : NOFSLOTS
        if EV_arrive_leave(idx, 2) <= jdx && jdx <= EV_arrive_leave(idx, 3)
            param.u(idx, jdx) = 1;
        end
    end
end

%% Temperature-Controlled Loads
load("h_load_temperature.mat"); % Outdoor temperature data
load("h_load.mat"); % Heat load data
NOFTCL = 3;
tcl_c = [80, 80, 40]' * 1e-3; % Equivalent capacitance
tcl_r = [0.1, 0.1, 0.15]' * 1e3; % Equivalent resistance
tcl_cop = [3.6, 3.6, 3.3]'; % Cycle efficiency
h_load = [0.4, 0.4, 0.2]' * h_load(:, 2)';

% Temperature transformation T' = 28 - T
T_ref = 28;
param.energy_init_tcl = T_ref - 26; % Initial energy
param.energy_upper_limit_tcl = 4; % Energy upper limit
param.energy_lower_limit_tcl = 0; % Energy lower limit
param.power_ch_upper_limit_tcl = 1e-3 * [400 400 200]'; % Charge power upper limit
param.power_ch_lower_limit_tcl =  [0 0 0]'; % Charge power lower limit

% 1 = delta_t
gama = 1 ./ (tcl_c .* tcl_r); 
alpha = [1 1 1]' - gama;
beta = 1 ./ tcl_c;
param.theta_tcl = alpha; % Retention rate
param.eta_ch_tcl = beta .* tcl_cop; % Charge efficiency
% Heat load/external temperature influence
h_load_temperature = ones(1, NOFSLOTS) * T_ref - h_load_temperature(:, 2)';
param.wOmiga = - repmat(beta, 1, NOFSLOTS) .*  h_load  - gama * h_load_temperature;

%% Industrial Production Process
% Use Lu-2021 data

% See paper lu-2021-data-driven
filename = "load_parameters_Lu_milp.xlsx";
load_parameter = xlsread(filename);

% Parameters related to load, specific meanings on iPad

% Energy-material conversion coefficient (converted to MW)
NOFIPP = 10;
production_rate =  1e3 * load_parameter(:, 1);
% Maximum material storage capacity
S_max =  load_parameter(:, 4);
% Material target value (change amount)
S_tar = zeros(size(S_max));
S_tar(end) = 200 * 22; % The bottleneck process needs to work for 22 hours.

param.energy_init_ipp = 0.5 * S_max; % Initial material value
param.energy_upper_limit_ipp = S_max * 0.90; % Material upper limit
param.energy_lower_limit_ipp = S_max * 0.10; % Material lower limit
param.power_ch_upper_limit_ipp = 1e-3 * load_parameter(:, 3); % Power upper limit
param.power_ch_lower_limit_ipp =  zeros(10, 1); % Power lower limit
param.energy_end_ipp = param.energy_init_ipp + S_tar; % Material target at the end

param.theta_ipp = 1; % Retention rate
param.eta_ch_ipp = production_rate; % Power-state conversion rate

clear alpha beta EV_arrive_leave gama h_load h_load_temperature idx jdx load_parameter ...
     output_pv production_rate S_max S_tar tcl_c tcl_cop tcl_r;