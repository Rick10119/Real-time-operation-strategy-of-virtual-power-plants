# chen_lyu_real-time_2024_apen
### Project Overview

#### Introduction
This repository contains the data and code used in the research paper titled "Real-Time Operation Strategy of Virtual Power Plants With Optimal Power Disaggregation Among Heterogeneous Resources" published in Applied Energy (2024). The data is organized in the file `Test data of VPP providing regulation.xlsx`.

Citation: Q. Chen, R. Lyu, H. Guo, and X. Su. "Real-Time Operation Strategy of Virtual Power Plants With Optimal Power Disaggregation Among Heterogeneous Resources." Applied Energy 361 (2024): 122876.

#### Goal
The goal of this repository is to provide programming insights and reference code for individuals interested in implementing the proposed methods. It aims to facilitate the use of the code for problem-solving, method comparison, and understanding, rather than solely reproducing the exact results presented in the paper. While the current version should yield similar results, we have removed extraneous elements used for illustrative purposes, retaining only the core code to prevent overwhelming readers with excessive code and parameters.

#### Background
This work builds upon our previous research titled "Co-Optimizing Bidding and Power Allocation of an EV Aggregator Providing Real-Time Frequency Regulation Service." Key improvements include:
1. Introduction of new resources such as air conditioning loads, distributed energy storage, and industrial loads, proposing a standardized model to represent these resources, beyond just electric vehicles.
2. Development of an algorithm for optimal fast disaggregation that does not require online solver calls, in contrast to the previous method that relied on online linear programming solving.

#### Limitations and Future Work
Despite the advancements, our work has limitations such as the lack of consideration for the actual performance of frequency regulation and ramp power constraints. Additionally, the numerical testing results exhibit instability, which will be addressed in future work (already resolved in our upcoming paper, currently under review and will be made public along with the code upon acceptance).

#### Code Details
We provide both Chinese and English versions of the README file, with primary code comments in English. This should not pose a significant issue, given the capabilities of GPT. In fact, a substantial portion of this document was assisted by GPT-3.5-turbo:

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

Feel free to explore the code and data provided here. If you have any questions or need further assistance, please do not hesitate to reach out.

### 项目概述

#### 简介
这个存储库包含了在《Applied Energy》（2024年）发表的研究论文中使用的数据和代码。论文标题为《Real-Time Operation Strategy of Virtual Power Plants With Optimal Power Disaggregation Among Heterogeneous Resources》。数据整理在文件 `Test data of VPP providing regulation.xlsx` 中。

引用：Q. Chen, R. Lyu, H. Guo, and X. Su. "Real-Time Operation Strategy of Virtual Power Plants With Optimal Power Disaggregation Among Heterogeneous Resources." Applied Energy 361 (2024): 122876.

#### 目标
这个存储库的目标是为对实现所提方法感兴趣的人提供编程思路和参考代码，方便使用来解决问题或者对比我们的方法和其他方法。我们删去了用于丰富算例的部分，只保留了最核心的代码，以避免过多的代码和参数吓到读者。尽管当前版本应该产生类似的结果，但我们的目标不是直接复现论文中的结果。

#### 背景
这项工作是在之前的研究基础上进行的，前一项研究为《Co-Optimizing Bidding and Power Allocation of an EV Aggregator Providing Real-Time Frequency Regulation Service》。主要改进包括：
1. 引入了空调负荷、分布式储能、工业负荷等新资源，并提出了一个标准化模型来建模这些资源，而不仅仅考虑电动汽车。
2. 提出了一个不需要在线调用求解器的算法来实现最优快速分解，而不像之前的方法需要在线求解线性规划。

#### 局限性和未来工作
尽管取得了进展，我们的工作仍有一些缺点，比如没有考虑响应调频的实际效果，也没有考虑爬坡功率限制，在数值测试中效果不稳定。这些问题将在未来的工作中讨论，实际上已在我们的新论文中解决，但论文仍在审稿状态，等论文被接收后，代码也会同步公开。

#### 代码详情
我们提供了中文和英文两个版本的 README 文件（以及readMe_code文件解释.m文件的作用），但主要代码注释使用英文。这应该不会是大问题，因为 GPT 的强大。事实上，整个文档的很大部分是由 GPT-3.5-turbo 协助完成的:

### 项目说明

**开始之前:**

为了运行程序，您需要安装 MATLAB + YALMIP + CPLEX。
在 `optimal_bidding_control` 文件夹中运行 `main` 即可获得最基础的结果。
如果 MATLAB 版本过高可能导致崩溃，您需要使用 Gurobi。请将以下代码修改为：
```matlab
ops = sdpsettings('debug',0,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
```
改为：
```matlab
ops = sdpsettings('debug',0,'solver','gurobi','savesolveroutput',1,'savesolverinput',1);
```

#### 数据准备（data_prepare）
- `07 2020.xlsx`：PJM 2020年7月的 RegD 信号。
- `rt_hrl_lmps.xlsx`：PJM 市场数据：实时逐小时节点电价（来自 PJM 官网）。
- `regulation_market_results.xlsx`：PJM 市场数据：逐小时调频市场价格（来自 PJM 官网）。
- `load_parameters_Lu_milp.xlsx`：工业负荷参数来自 Lu_data-driven_2022。

#### 数据准备主程序（data_prepare_main）
- 准备 DER 参数（data_prepare_parameters）。
- 读取光伏出力数据（data_prepare_pv_output）。
- 处理历史 RegD 信号中的爬坡速率（data_prepare_ramp）。
- 读取历史 RegD 信号，统计信号分布（data_prepare_regd）。
- 用标准化参数矩阵描述各 DER 的性能参数（data_prepare_std）。

#### 最优投标控制（optimal_bidding_control）
- 主要的程序（main）：投标-功率控制。
- 执行控制算法（fastControl_implement）。
- 准备控制算法所需参数（fastControl_prepare）。
- 日前最优投标程序（maxProfit_1）。
- 实时最优投标程序（maxProfit_t）。
- 评估快速控制算法计算时间（test_calc_time_fastControl）。
- 评估最优投标问题计算时间（test_calc_time_optimalBidding）。
- 评估最优分解问题计算时间（test_calc_time_optimalControl）。

#### 结果（results）
- 存储的结果，以 `.mat` 格式存储（_basic，基本数据；_ic，验证激励相容性数据）。

#### 结果可视化（visualise）
- 结果的可视化和画图，其中 `cost_wrt_method` 是统计各种方法主要结果的程序。

**注意**：对于基础认识，只需关注加粗的程序，了解：
1. 如何实现各类资源标准化建模以及参数的确定（parameters, _std）。
2. 最优投标程序和快速分解算法（maxProfit_1, maxProfit_t, fastControl_prepare, fastControl_implement）。
3. 整个参与市场的流程（main）。

**proportional_control/greedy_control**：对比现有文献中的一些方法（包括投标和功率分配）。
具体细节请参考我们的论文。命名方式与我们的方法类似，因为并非我们提出的，所以仅供参考，没有详细解释。

欢迎查看这里提供的代码和数据。如果您有任何问题或需要进一步帮助，请随时联系我们。
