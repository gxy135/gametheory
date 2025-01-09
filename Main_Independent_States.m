clear all;
clc;
%======================== T 4 N 16 =======================================

%-------------------------------------------------------------------------
% 设置参数 PH1 为 0.5
sim_param.PH1 = 0.5;

% 设置参数 T 为 4
sim_param.T = 4;

% 设置参数 N 为 20
sim_param.N = 20;
% 计算参数 K1 为 11
sim_param.K1 = 11;
% 计算参数 alfa 为 (N - K1) / N
sim_param.alfa = (sim_param.N - sim_param.K1) / sim_param.N;

% 设置参数 epsilon 为 0.1
sim_param.epsilon = 0.1;

% 设置参数 Nprove 为 50000
sim_param.Nprove = 50000;
% 计算参数 delta 为 1 - epsilon
sim_param.delta = 1 - sim_param.epsilon;

% 生成所有可能的系统状态（二进制表示）
sim_param.possible_system_states = dec2bin(0:2^sim_param.T - 1, sim_param.T) - '0';
% 设置参数 L 为 N/2
sim_param.L = sim_param.N / 2;

%===================== 初始化 Varshney 和 LLR =========================

% 定义 gamma 参数为 0 到 T 的整数
sim_param.gammas = 0:sim_param.T;
% 诚实节点的检测概率 Pd_Hp 为 1 - epsilon
sim_param.Pd_Hp = 1 - sim_param.epsilon; % 诚实节点的检测概率
% 诚实节点的误报概率 Pfa_Hp 为 epsilon
sim_param.Pfa_Hp = sim_param.epsilon; % 诚实节点的误报概率
% 拜占庭节点的检测概率 Pd_Bp 为 1 - epsilon
sim_param.Pd_Bp = 1 - sim_param.epsilon; % 拜占庭节点的检测概率
% 拜占庭节点的误报概率 Pfa_Bp 为 epsilon
sim_param.Pfa_Bp = sim_param.epsilon; % 拜占庭节点的误报概率
% 设置 LLR 的阈值数量 Nsoglie_LLR 为 10
sim_param.Nsoglie_LLR = 10;

%===================== 结束初始化 Varshney 和 LLR =========================

% 显示参数 alfa 的值
fprintf('Alfa = %f\n', sim_param.alfa);
% 显示参数 T 的值
fprintf('T = %f\n', sim_param.T);
% 显示参数 N 的值
fprintf('N = %f\n', sim_param.N);
% 显示诚实节点数量 K1 的值
fprintf('K honests = %f\n', sim_param.K1);
% 显示拜占庭节点数量 (N - K1) 的值
fprintf('M byzantines = %f\n', (sim_param.N - sim_param.K1));
% 显示参数 epsilon 的值
fprintf('epsilon = %f\n', sim_param.epsilon);

% 初始化变量 xx 为 0
xx = 0;
% 循环变量 pmal_dec 从 1 到 6，步长为 1
for pmal_dec = 1:1:6
    xx = xx + 1;    
    % 计算参数 Pmal 为 (pmal_dec + 4) / 10
    sim_param.Pmal = (pmal_dec + 4) / 10;
    % 显示参数 Pmal 的值
    fprintf('Pmal = %f\n', sim_param.Pmal);

    % 调用函数 function_independent_states 并将结果存储在变量 results 中
    [results] = function_independent_states(sim_param);
    
    %============= Varshney 和 LLR 的结果 ================================
    % 从 results 中提取各个结果变量
    PD_IDB = results.PD_IDB;
    PFA_IDB = results.PFA_IDB;
    P_ISO_H = results.P_ISO_H; % Varshney 方案中诚实节点的 ISO 值
    P_ISO_B = results.P_ISO_B; % Varshney 方案中拜占庭节点的 ISO 值
    PD_IDB_LLR = results.PD_IDB_LLR;
    PFA_IDB_LLR = results.PFA_IDB_LLR;
    P_ISO_H_LLR = results.P_ISO_H_LLR;
    P_ISO_B_LLR = results.P_ISO_B_LLR;
    PFA = results.PFA;
    PD = results.PD;
    PFAr = results.PFAr; % Varshney 的误报率
    PDr = results.PDr;
    PFAr_LLR = results.PFAr_LLR; % LLR 的误报率
    PDr_LLR = results.PDr_LLR;

    % 不选择最小化误报率与漏报率之和的阈值
    Varsh(xx) = min(PFAr + 1 - PDr);
    SOFT(xx) = min(PFAr_LLR + 1 - PDr_LLR);
    Majority(xx) = results.error_majority;

    %============= 结束 Varshney 和 LLR 的结果 ================================

    % 将结果存储在矩阵 Independent 中
    Independent(xx, :) = results.error_eq4;

end

% 保存结果到文件 'Independent.mat'
save('Independent.mat', 'Independent');
% 保存结果到文件 'Varsh.mat'
save('Varsh.mat', 'Varsh');
% 保存结果到文件 'SOFT.mat'
save('SOFT.mat', 'SOFT');
% 保存结果到文件 'Majority.mat'
save('Majority.mat', 'Majority');


