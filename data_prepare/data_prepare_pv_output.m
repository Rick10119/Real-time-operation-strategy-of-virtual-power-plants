%% Photovoltaic Output Data

% Data is from yi-2022-rubost
output_pv = [0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.01 
0.02 
0.03 
0.05 
0.10 
0.16 
0.22 
0.27 
0.32 
0.36 
0.40 
0.44 
0.53 
0.61 
0.69 
0.77 
0.79 
0.80 
0.80 
0.80 
0.84 
0.88 
0.93 
0.98 
1.00 
0.99 
0.98 
0.97 
0.95 
0.91 
0.87 
0.83 
0.79 
0.76 
0.72 
0.69 
0.65 
0.57 
0.50 
0.42 
0.35 
0.32 
0.29 
0.26 
0.23 
0.20 
0.17 
0.13 
0.10 
0.07 
0.05 
0.03 
0.01 
0.01 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
0.00 
];

% Accumulate to hours, and change the maximum capacity to 2.5MW
output_pv = reshape(output_pv, 4, 24);
output_pv = output_pv' * ones(4, 1) * 15/60 * 2.5;

% plot(output_pv);

save("output_pv.mat", 'output_pv');