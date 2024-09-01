%% Read RegD signal data from Excel
filename = '07 2020.xlsx';
sheet = 'Dynamic'; % Sheet name
xlRange = 'B2:AF43202'; % Range

% Read all signal data for July, 2s per point * 31 days
Signals = xlsread(filename, sheet, xlRange);

% Data clearing, exclude data beyond [-1, 1]
Signals(find(Signals < -1)) = -1;
Signals(find(Signals > 1)) = 1;

%% Process the raw signal data
% Organize by 0.1 resolution: 1) distribution of regd signals this month, 2) distribution of regd signals on July 15th

nofHisDays = 14; % Use past 14 days of historical data for prediction
signal_length = 43202 - 2; % (remove the first and last, total 24 * 1800)

% Data for the 15th used for simulation
Signal_day = Signals(1:end-1, day_reg);

% One distribution per hour
hourly_Distribution = [];
hourly_Mileage = [];

for hour = 1:24
    
    Distributions = [];
    
    for day_idx = day_reg - nofHisDays : day_reg - 1 % Past 14 days data
        signals = Signals(1:end-1, day_idx); % Extract column
        
        Distribution = zeros(2 / diff + 2, 1); % Initialize, discretize df, consider -1 and 1 separately
        % Numbered from 1 to 22: -1 to 1
        
        % Scan to get pdf
        for t_cap = 1 + (hour - 1) * 1800 : hour * 1800
            if signals(t_cap) >= 0 % Upward frequency adjustment
                s_idx = ceil(signals(t_cap) / diff) + 1 / diff + 1; % Scenario number
                if signals(t_cap) > 0.9999 % Consider as 1
                    s_idx = length(Distribution);
                end
            else
                s_idx = floor(signals(t_cap) / diff) + 1 / diff + 2; % Scenario number
                if signals(t_cap) < - 0.9999 % Consider as -1
                    s_idx = 1;
                end
            end
            Distribution(s_idx) = Distribution(s_idx) + 1;
        end
        
        % Calculate frequency
        Distribution = Distribution / sum(Distribution);
        
        Distributions = [Distributions, Distribution];
    end
    
    Distribution = Distributions * 1/nofHisDays * ones(nofHisDays, 1);
    hourly_Distribution = [hourly_Distribution, Distribution];
    
    %% Calculate historical mileage
    
    Mileage = [];
    for day_idx = day_reg - nofHisDays : day_reg - 1 % Past two weeks of data
        
        % Extract column (one day)
        signals = Signals(1 + (hour - 1) * 1800 : hour * 1800, day_idx);
        
        % Calculate mileage for this hour
        mileage = sum(abs(signals(2:end) - signals(1:end-1)));
        
        Mileage = [Mileage, mileage];
    end
    
    Mileage =  Mileage * 1/nofHisDays * ones(nofHisDays, 1);
    
    hourly_Mileage = [hourly_Mileage, Mileage];
end

%% Rows: different intervals; Columns (different times)
param.hourly_Mileage = hourly_Mileage';
param.hourly_Distribution = hourly_Distribution';
param.d_s = [-1; (-1 + 0.5 * diff : diff : 1 - 0.5 * diff)'; 1]; % Average signal values for each scenario, in units of capacity 1

clear Mileage mileage signals Distributions Distribution hourly_Distribution hourly_Mileage nofHisDays
clear col s_idx Signals
clear filename hour sheet t_cap xlRange day_idx
