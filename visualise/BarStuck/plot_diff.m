

% expectTime = 6/4.5*max(expect_coPrice);
expectTime = mean(expect_beta_SDE);
% expectTime = mean(expect_chargingTime_slot + expect_roadTime);
% expectTime = mean(expect_arrive_number_slot);

expectTime = [expectTime,expectTime(12)];


% stairs(expectTime,'LineWidth',linewidth);



hold on;