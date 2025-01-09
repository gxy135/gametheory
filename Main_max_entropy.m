 sim_param.PH1 = 0.5; % 设置参数 PH1 为 0.5

sim_param.N = 20; % 总节点数
% sim_param.K = 9; % 诚实节点数（注释掉，未使用）
% sim_param.M = sim_param.N - sim_param.K; % 不诚实节点数（注释掉，未使用）
% sim_param.alfa = (sim_param.N - sim_param.K) / sim_param.N; % 拜占庭节点比例（注释掉，未使用）
sim_param.T = 4; % 时间步长或周期数

sim_param.L = sim_param.N / 2; % 设置参数 L 为 N/2

% 生成所有可能的系统状态（二进制表示）
sim_param.possible_system_states = dec2bin(0:2^sim_param.T - 1, sim_param.T) - '0';

sim_param.epsilon = 0.1; % 设置诚实节点的错误概率 epsilon 为 0.1
sim_param.delta = 1 - sim_param.epsilon; % 设置检测准确率 delta 为 1 - epsilon

%=============== 初始化 Varshney 和 LLR ===================
sim_param.gammas = 0:sim_param.T; % 定义 gamma 参数为 0 到 T 的整数
sim_param.Pd_Hp = 1 - sim_param.epsilon; % 诚实节点的检测概率
sim_param.Pfa_Hp = sim_param.epsilon; % 诚实节点的误报概率
sim_param.Pd_Bp = 1 - sim_param.epsilon; % 拜占庭节点的检测概率
sim_param.Pfa_Bp = sim_param.epsilon; % 拜占庭节点的误报概率
sim_param.Nsoglie_LLR = 10; % 设置 LLR 检测的阈值数量为 10
%============== 结束初始化 Varshney 和 LLR ===============

sim_param.Nprove = 50000; % 设置仿真总次数为 50000

fprintf('N = %f\n', sim_param.N); % 显示总节点数 N
% fprintf('K = %f\n', sim_param.K); % 显示诚实节点数 K（注释掉，未使用）
% fprintf('M = %f\n', sim_param.M); % 显示不诚实节点数 M（注释掉，未使用）
% fprintf('alfa = %f\n', sim_param.alfa); % 显示拜占庭节点比例 alfa（注释掉，未使用）

fprintf('T = %f\n', sim_param.T); % 显示时间步长 T

% 主循环：遍历不同的 Pmal 值
for pmal_dec = 1:1:6
    sim_param.Pmal = (pmal_dec + 4) / 10; % 计算 Pmal 值，范围从 0.5 到 1.0，步长为 0.1
    fprintf('Pmal Real = %f\n', sim_param.Pmal); % 显示实际的 Pmal 值

    % 调用函数 function_fixed_states 或 function_max_entropy_optimized 进行仿真
    % [results] = function_fixed_states(sim_param);
    [results] = function_max_entropy_optimized(sim_param);

    %========== Varshney 和 LLR 的结果计算 =========================================
    PD_IDB = results.PD_IDB; % Varshney 检测方案下的检测概率
    PFA_IDB = results.PFA_IDB; % Varshney 检测方案下的误报概率
    P_ISO_H = results.P_ISO_H; % Varshney 方案中诚实节点的 ISO 值
    P_ISO_B = results.P_ISO_B; % Varshney 方案中拜占庭节点的 ISO 值
    PD_IDB_LLR = results.PD_IDB_LLR; % LLR 检测方案下的检测概率
    PFA_IDB_LLR = results.PFA_IDB_LLR; % LLR 检测方案下的误报概率
    P_ISO_H_LLR = results.P_ISO_H_LLR; % LLR 方案中诚实节点的 ISO 值
    P_ISO_B_LLR = results.P_ISO_B_LLR; % LLR 方案中拜占庭节点的 ISO 值
    PFA = results.PFA; % 误报概率
    PD = results.PD; % 检测概率
    PFAr = results.PFAr; % Varshney 的误报率
    PDr = results.PDr; % Varshney 的检测率
    PFAr_LLR = results.PFAr_LLR; % LLR 的误报率
    PDr_LLR = results.PDr_LLR; % LLR 的检测率

    % 计算 Varshney 和 LLR 方案的最小误报率与漏报率之和
    Hard_N_13_T_4(pmal_dec) = min(PFAr + 1 - PDr);
    Soft_N_13_T_4(pmal_dec) = min(PFAr_LLR + 1 - PDr_LLR);
    %========== 结束 Varshney 和 LLR 的结果计算 =========================================

    perr_majority(pmal_dec) = results.error_majority; % 多数投票规则下的错误率

    % 将最大熵方案的结果存储到矩阵中
    max_entropy_N_13_T_4(pmal_dec, :) = results.p_err; % 最大熵方案的结果
end

% 保存最大熵方案的结果到文件 'max_entropy_N_13_T_4.mat'
save('max_entropy_N_13_T_4.mat', 'max_entropy_N_13_T_4');

% M_all = results.M_all; % 拜占庭节点数量（未使用）
% R_mat_array = results.R_mat_array; % 决策矩阵（未使用）
% SS = results.SS; % 其他结果（未使用）