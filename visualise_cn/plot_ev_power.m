





load("results_methods/result_my_alloc.mat");
lc = 'SouthEast';
plot_ev_power_sub;
saveas(gcf,'typical_ev_1.pdf');

load("results_methods/result_proportional.mat");
lc = 'SouthWest';
plot_ev_power_sub;
saveas(gcf,'typical_ev_2.pdf');

load("results_methods/result_heuristic.mat");
lc = 'SouthEast';
plot_ev_power_sub;
saveas(gcf,'typical_ev_3.pdf');

load("results_methods/result_minDeg.mat");
lc = 'SouthWest';
plot_ev_power_sub;
saveas(gcf,'typical_ev_4.pdf');
