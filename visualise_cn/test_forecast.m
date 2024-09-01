%% 比较预测的调频场景分布和实际分布。
diff = 0.1;
% data_prepare;% 得到预测的场景分布

% 当日的场景分布


% 每个小时一个分布
hourly_Distribution = [];
hourly_Mileage = [];
signals = Signal_day;% 取出列

for hour = 1 : 24
    
    Distributions = [];
      
        Distribution = zeros(2 / diff + 2, 1); % 初始化，离散化df，单独考虑-1和1
        % 编号从1~22：-1~1
        
        % 扫描，得到pdf
        for t_cap = 1 + (hour - 1) * 1800 : hour * 1800
            if signals(t_cap) >= 0 % 向上调频
                s_idx = ceil(signals(t_cap) / diff) + 1 / diff + 1; % 场景编号
                if signals(t_cap) > 0.9999 % 当作1计算
                    s_idx = length(Distribution);
                end
            else
                s_idx = floor(signals(t_cap) / diff) + 1 / diff + 2; % 场景编号
                if signals(t_cap) < - 0.9999 % 当作1计算
                    s_idx = 1;
                end
            end
            Distribution(s_idx) = Distribution(s_idx) + 1;
        end
        
        % 计算频率
        Distribution = Distribution / sum(Distribution);
        
        Distributions = [Distributions, Distribution];
        
        % plot(Distribution);hold on;
        % plot(test);
hourly_Distribution = [hourly_Distribution, Distribution];

end

hourly_Distribution = hourly_Distribution';
%%



% for hour = 1 :  24
%     x(hour) = sum((hourly_Distribution(hour, :) - param.hourly_Distribution(hour, :)).^2);
% end
% hour = find(x==min(x))
    
%%

hour = 11;   
    
% plot(hourly_Distribution(hour, :));hold on;
% plot(param.hourly_Distribution(hour, :));

table = [param.hourly_Distribution(hour, :); hourly_Distribution(hour, :)];


    
