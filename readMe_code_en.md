### Project Overview


Before getting started:

To run the program, you need MATLAB + YALMIP + CPLEX.
Run `main` in `optimal_bidding_control` to obtain the most basic results.
If the MATLAB version is too high and may cause crashes, you need to use Gurobi. Change:
```matlab
ops = sdpsettings('debug',0,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
```
to:
```matlab
ops = sdpsettings('debug',0,'solver','gurobi','savesolveroutput',1,'savesolverinput',1);
```

#### Data Preparation (data_prepare)
- `07 2020.xlsx`: RegD signal for PJM in July 2020.
- `rt_hrl_lmps.xlsx`: PJM market data: Real-time hourly nodal prices (from PJM official website).
- `regulation_market_results.xlsx`: PJM market data: Hourly regulation market prices (from PJM official website).
- `load_parameters_Lu_milp.xlsx`: Industrial load parameters from Lu_data-driven_2022.

#### Data Preparation Main Program (data_prepare_main)
- Prepare DER parameters (data_prepare_parameters).
- Read photovoltaic output data (data_prepare_pv_output).
- Process ramp rates in historical RegD signals (data_prepare_ramp).
- Read historical RegD signals and analyze signal distribution (data_prepare_regd).
- Describe DER performance parameters using standardized parameter matrices (data_prepare_std).

#### Optimal Bidding Control (optimal_bidding_control)
- Main program (main): Bidding-Power Control.
- Execute control algorithm (fastControl_implement).
- Prepare parameters required for control algorithm (fastControl_prepare).
- Optimal bidding program for the day ahead (maxProfit_1).
- Real-time optimal bidding program (maxProfit_t).
- Evaluate computation time of fast control algorithm (test_calc_time_fastControl).
- Evaluate computation time of optimal bidding problem (test_calc_time_optimalBidding).
- Evaluate computation time of optimal decomposition problem (test_calc_time_optimalControl).

#### Results (results)
- Stored results in .mat format (_basic for basic data; _ic for compatibility validation data).

#### Visualization of Results (visualise)
- Visualization and plotting of results, where `cost_wrt_method` is a program for analyzing main results of various methods.

**Note**: For foundational understanding, focus on the programs in bold to understand:
1. How to model various resources and determine parameters (parameters, _std).
2. Optimal bidding programs and fast decomposition algorithms (maxProfit_1, maxProfit_t, fastControl_prepare, fastControl_implement).
3. The overall process of participating in the market (main).

**proportional_control/greedy_control**: These programs compare methods from existing literature 
(including bidding and power allocation). For detailed information, please refer to our paper. 
The naming convention is similar to our methods, as these are referenced from existing literature without detailed explanations.