%% Prepare the parameters for the problem
clc;
clear;

for day_price = [21]
    param = {};
    M = 1e6; % Large number
    delta_t_req = 0.5; % Maintenance time

    %% Read the RegD signal data
    % ʱ��������24Сʱ
    NOFSLOTS = 24;

    % Select the date as July 17th-18th
    % day_price = 21; % Price date
    day_reg = day_price + 1; % Frequency regulation signal: RegD signal distribution for July 22, 2020, used for simulation
    hour_init = 0; % Start at 18:00-19:00 (the original 19th time slot)

    % Read and process the RegD signal data from an xlsx file
    % ��Ƶ�ź���ɢϸ����
    granularity = 0.1; 
    % ��Ƶ�źŴ���
    data_prepare_regd;

    %% Parameters for each resource
    data_prepare_parameters;

    %% Standardize the parameters
    data_prepare_std;

    % Resource names
    % ��Դ����
    param.resource_names = ["pv", "es", "ev", "tcl", "ipp"];

    % Resource numbers
    % ��Դ���
    param.resource_range = [[1, 1]; [2, 2]; [3, NOFEV + 2]; ...
        [NOFEV + 3, NOFEV + 5]; [NOFEV + 6, NOFEV + 15];];

    %% Market prices and other parameters
    % Time slot length, 1 hour
    % ʱ�γ��ȣ�1Сʱ
    delta_t = 1;

    % Read the regulation market price data
    % ��ȡ��Ƶ�г��۸�����
    filename = 'regulation_market_results.xlsx';
    sheet = 'regulation_market_results'; % Sheet name
    start_row = (day_price-1) * 24 + hour_init + 2; % Starting row
    xlRange = "G" + start_row + ":H" + (start_row + NOFSLOTS - 1); % Range
    param.price_reg = xlsread(filename, sheet, xlRange); % Capacity price, mileage price
    % Number of scenarios
    % ��������
    NOFSCEN = length(param.hourly_Distribution(1, :));
    % Frequency regulation performance
    % ��Ƶ����
    param.s_perf = 0.984;

    % Read the system energy price data
    % ��ȡϵͳ�����۸�����
    filename = 'rt_hrl_lmps.xlsx';
    sheet = 'rt_hrl_lmps'; % Sheet name
    xlRange = "I" + start_row + ":I" + (start_row + NOFSLOTS - 1); % Range
    param.price_e = xlsread(filename, sheet, xlRange); % Capacity price, mileage price

    clear price filename sheet xlRange start_row signal_length idx jdx

    save("param_day_" + day_price + ".mat");

end