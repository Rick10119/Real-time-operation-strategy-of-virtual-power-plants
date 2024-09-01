%% Prepare the parameters for the problem
clc;
clear;

for day_price = [21]
    param = {};
    M = 1e6; % Large number
    delta_t_req = 0.5; % Maintenance time

    %% Read the RegD signal data
    % 时段数量，24小时
    NOFSLOTS = 24;

    % Select the date as July 17th-18th
    % day_price = 21; % Price date
    day_reg = day_price + 1; % Frequency regulation signal: RegD signal distribution for July 22, 2020, used for simulation
    hour_init = 0; % Start at 18:00-19:00 (the original 19th time slot)

    % Read and process the RegD signal data from an xlsx file
    % 调频信号离散细粒度
    granularity = 0.1; 
    % 调频信号处理
    data_prepare_regd;

    %% Parameters for each resource
    data_prepare_parameters;

    %% Standardize the parameters
    data_prepare_std;

    % Resource names
    % 资源名字
    param.resource_names = ["pv", "es", "ev", "tcl", "ipp"];

    % Resource numbers
    % 资源编号
    param.resource_range = [[1, 1]; [2, 2]; [3, NOFEV + 2]; ...
        [NOFEV + 3, NOFEV + 5]; [NOFEV + 6, NOFEV + 15];];

    %% Market prices and other parameters
    % Time slot length, 1 hour
    % 时段长度，1小时
    delta_t = 1;

    % Read the regulation market price data
    % 读取调频市场价格数据
    filename = 'regulation_market_results.xlsx';
    sheet = 'regulation_market_results'; % Sheet name
    start_row = (day_price-1) * 24 + hour_init + 2; % Starting row
    xlRange = "G" + start_row + ":H" + (start_row + NOFSLOTS - 1); % Range
    param.price_reg = xlsread(filename, sheet, xlRange); % Capacity price, mileage price
    % Number of scenarios
    % 场景数量
    NOFSCEN = length(param.hourly_Distribution(1, :));
    % Frequency regulation performance
    % 调频性能
    param.s_perf = 0.984;

    % Read the system energy price data
    % 读取系统能量价格数据
    filename = 'rt_hrl_lmps.xlsx';
    sheet = 'rt_hrl_lmps'; % Sheet name
    xlRange = "I" + start_row + ":I" + (start_row + NOFSLOTS - 1); % Range
    param.price_e = xlsread(filename, sheet, xlRange); % Capacity price, mileage price

    clear price filename sheet xlRange start_row signal_length idx jdx

    save("param_day_" + day_price + ".mat");

end