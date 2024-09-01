### 项目说明

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