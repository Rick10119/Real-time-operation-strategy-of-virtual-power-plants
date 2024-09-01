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
We provide both Chinese and English versions of the README file, with primary code comments in English. This should not pose a significant issue, given the capabilities of GPT. In fact, a substantial portion of this document was assisted by GPT-3.5-turbo.

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
我们提供了中文和英文两个版本的 README 文件（以及readMe_code文件解释.m文件的作用），但主要代码注释使用英文。这应该不会是大问题，因为 GPT 的强大。事实上，整个文档的很大部分是由 GPT-3.5-turbo 协助完成的。

欢迎查看这里提供的代码和数据。如果您有任何问题或需要进一步帮助，请随时联系我们。
