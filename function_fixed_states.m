function [results] = function_fixed_states(sim_param)
    % function_fixed_states: 该函数用于模拟固定状态下的检测过程，考虑了诚实节点和拜占庭节点的行为。
    %
    % 输入参数:
    %   sim_param: 仿真参数结构体，包含仿真所需的各种参数。
    %
    % 输出:
    %   results: 包含仿真结果的输出结构体。

    Nprove = sim_param.Nprove; % 仿真总次数
    PH1 = sim_param.PH1;       % 系统处于状态 1 的先验概率
    PH0 = 1 - PH1;             % 系统处于状态 0 的先验概率
    L = sim_param.L;           % 多数投票的阈值参数

    Pmal = sim_param.Pmal;     % 恶意行为概率
    %================ Varsh 和 LLR 参数初始化===================================
    Pd_Hp = sim_param.Pd_Hp;   % 诚实节点的检测概率
    Pfa_Hp = sim_param.Pfa_Hp; % 诚实节点的误报概率
    Pd_Bp = sim_param.Pd_Bp;   % 拜占庭节点的检测概率
    Pfa_Bp = sim_param.Pfa_Bp; % 拜占庭节点的误报概率
    gammas = sim_param.gammas; % 用于 Varshney 检测的阈值向量

    Pd_H = Pd_Hp;              % 诚实节点的检测概率初始化
    Pfa_H = Pfa_Hp;            % 诚实节点的误报概率初始化
    Pd_B = Pmal * (1 - Pd_Bp) + (1 - Pmal) * Pd_Bp;
    % 计算拜占庭节点的综合检测概率，考虑了恶意行为的影响。
    Pfa_B = Pmal * (1 - Pfa_Bp) + (1 - Pmal) * Pfa_Bp;
    % 计算拜占庭节点的综合误报概率，考虑了恶意行为的影响。

    Nsoglie_LLR = sim_param.Nsoglie_LLR; % LLR 检测的阈值数量
    Nerr_h = 0;                % 诚实节点的错误计数初始化
    Nerr_b = 0;                % 拜占庭节点的错误计数初始化
    N0 = 0;                     % 系统状态为 0 的计数初始化
    N1 = 0;                     % 系统状态为 1 的计数初始化
    Nerr_hr = zeros(length(gammas), 1); % Varshney 检测下诚实节点的错误计数初始化
    Nerr_br = zeros(length(gammas), 1); % Varshney 检测下拜占庭节点的错误计数初始化
    Nerr_hr_LLR = zeros(Nsoglie_LLR, 1); % LLR 检测下诚实节点的错误计数初始化
    Nerr_br_LLR = zeros(Nsoglie_LLR, 1); % LLR 检测下拜占庭节点的错误计数初始化
    Nerr_H = zeros(length(gammas), 1);  % Varshney 检测下诚实节点的错误计数（按节点）
    Nerr_B = zeros(length(gammas), 1);  % Varshney 检测下拜占庭节点的错误计数（按节点）
    Nerr_H_LLR = zeros(Nsoglie_LLR, 1); % LLR 检测下诚实节点的错误计数（按节点）
    Nerr_B_LLR = zeros(Nsoglie_LLR, 1); % LLR 检测下拜占庭节点的错误计数（按节点）
    %=================================================================

    N = sim_param.N;           % 节点总数
    M = sim_param.M;           % 拜占庭节点数量
    K = sim_param.K;           % 诚实节点数量
    alfa = sim_param.alfa;     % 拜占庭节点的比例
    T = sim_param.T;           % 时间步长或周期数

    possible_states = sim_param.possible_system_states; % 所有可能的系统状态

    epsilon = sim_param.epsilon; % 诚实节点的错误概率
    delta = sim_param.delta;     % 检测准确率

    delta_Byz = (1 - delta) * (1 - Pmal) + (delta) * Pmal; % 拜占庭节点的检测准确率

    for np = 1:Nprove
        if rem(np, 50000) == 0
            fprintf('Simulation %d su %d\n', np, Nprove);
            % 每50000次仿真输出一次进度信息。
        end;
        rd = rand(1, T);
        P = zeros(1, T);
        P(rd < PH1) = 1; % 生成系统状态

        UH = zeros(K, T); % 保存诚实节点的决策
        UB = zeros(M, T); % 保存拜占庭节点的决策
        D = zeros(1, T);  % 保存多数投票规则的决策
        LLRs_OUT = zeros(N, T); % 存储 LLR 输出
        for t = 1:T
            if P(t) == 1 % 如果系统状态为 1
                UH(:, t) = 1; % 诚实节点的报告首先设为 1
                GH = rand(K, 1);
                UH(GH < epsilon, t) = 0; % 诚实节点可能发生错误
                UB(:, t) = 1;
                GB = rand(M, 1);
                UB(GB < delta_Byz, t) = 0; % 拜占庭节点可能发生错误
            else % 如果系统状态为 0
                GH = rand(K, 1);
                UH(GH < epsilon, t) = 1; % 诚实节点可能发生错误
                GB = rand(M, 1);
                UB(GB < delta_Byz, t) = 1; % 拜占庭节点可能发生错误
            end;
            U_ALL = [UB(:, t); UH(:, t)];

            %========================= 设置 Varshney 和 LLR ===========================
            Prob_err = Pmal * M / N;

            U_ALL_2 = [UH(:, t); UB(:, t)];
            Num_ones = length(find(U_ALL_2 == 1));
            Num_zeros = length(find(U_ALL_2 == 0));

            alpha = M / N;
            P1 = (1 - alpha) * Pfa_H + alpha * Pfa_B;
            P2 = (1 - alpha) * Pd_H + alpha * Pd_B;
            PUH0 = ((1 - Prob_err) * P1 + Prob_err * (1 - P1))^Num_ones * ((1 - Prob_err) * (1 - P1) + Prob_err * P1)^Num_zeros;
            PUH1 = ((1 - Prob_err) * P2 + Prob_err * (1 - P2))^Num_ones * ((1 - Prob_err) * (1 - P2) + Prob_err * P2)^Num_zeros;
            for dec = 1:N
                if U_ALL_2(dec) == 0
                    PUH0d = PUH0 / (((1 - Prob_err) * (1 - P1) + Prob_err * P1));
                    PUH1d = PUH1 / ((1 - Prob_err) * (1 - P2) + Prob_err * P2);
                    Px0U = (1 - Prob_err) * ((1 - P1) * (1 - PH1) * PUH0d + (1 - P2) * PH1 * PUH1d);
                    Px1U = Prob_err * (P1 * (1 - PH1) * PUH0d + P2 * PH1 * PUH1d);
                else
                    PUH0d = PUH0 / ((1 - Prob_err) * P1 + Prob_err * (1 - P1));
                    PUH1d = PUH1 / ((1 - Prob_err) * P2 + Prob_err * (1 - P2));
                    Px0U = Prob_err * ((1 - P1) * (1 - PH1) * PUH0d + (1 - P2) * PH1 * PUH1d);
                    Px1U = (1 - Prob_err) * (P1 * (1 - PH1) * PUH0d + P2 * PH1 * PUH1d);
                end;
                LLRs_OUT(dec, t) = abs(log(Px0U / Px1U));
            end;
            %=========================结束设置 Varshney 和 LLR ===========================================

            if sum([UH(:, t); UB(:, t)]) >= L % 根据多数投票规则获得结果
                D(t) = 1;
            else
                D(t) = 0;
            end;

            R_matrix(:, t) = U_ALL;
        end

        %===================== 使用 Varshney 和 LLR 解码 ========================================
        REL = sum(LLRs_OUT, 2);
        if (max(REL) - min(REL)) > 0 % Nsoglie_LLR > 0
            for i = 1:Nsoglie_LLR
                SOGLIA_LLRs(i) = min(REL) + ((max(REL) - min(REL)) / Nsoglie_LLR) * i;
            end
        else
            SOGLIA_LLRs = mean(REL) * ones(1, Nsoglie_LLR);
        end;
        % 显示 SOGLIA_LLRs
        % disp(SOGLIA_LLRs);
        for is = 1:Nsoglie_LLR
            SOGLIA_LLR = SOGLIA_LLRs(is);
            Nerr_H_LLR(is) = Nerr_H_LLR(is) + length(find(REL(1:K) < SOGLIA_LLR));
            Nerr_B_LLR(is) = Nerr_B_LLR(is) + length(find(REL(K + 1:N) >= SOGLIA_LLR));
        end;

        Dall_H = repmat(D, K, 1);
        Errs_H = xor(Dall_H, UH);
        Dall_B = repmat(D, M, 1);
        Errs_B = xor(Dall_B, UB);
        eta_H = sum(Errs_H, 2);
        eta_B = sum(Errs_B, 2);
        for ig = 1:length(gammas)
            gamma = gammas(ig);
            Nerr_H(ig) = Nerr_H(ig) + length(find(eta_H > gamma));
            Nerr_B(ig) = Nerr_B(ig) + length(find(eta_B <= gamma));
        end;

        indx = find(P == 1);
        Nerr_h = Nerr_h + length(find(D(indx) == 0));
        indx = find(P == 0);
        Nerr_b = Nerr_b + length(find(D(indx) == 1));
        % 非对称情况下的变量
        N0 = N0 + numel(find(P == 0));
        N1 = N1 + numel(find(P == 1));

        % 在去除后评估性能
        for ig = 1:length(gammas)
            Dr = 0 * D;
            gamma = gammas(ig);
            indxH = find(eta_H <= gamma);
            indxB = find(eta_B <= gamma);
            if length(indxH) + length(indxB) == 0
                indxH = 1:length(eta_H);
                indxB = 1:length(eta_B);
            end;
            for t = 1:T
                % 决策
                if sum([UH(indxH, t); UB(indxB, t)]) >= (length(indxH) + length(indxB)) / 2
                    Dr(t) = 1;
                else
                    Dr(t) = 0;
                end;
            end
            indx = find(P == 1);
            Nerr_hr(ig) = Nerr_hr(ig) + length(find(Dr(indx) == 0));
            indx = find(P == 0);
            Nerr_br(ig) = Nerr_br(ig) + length(find(Dr(indx) == 1));
        end;
        % 在去除后评估 LLR 情况下的性能
        for is = 1:Nsoglie_LLR
            Dr = 0 * D;
            SOGLIA_LLR = SOGLIA_LLRs(is);
            indxH = find(REL(1:K) >= SOGLIA_LLR);
            indxB = find(REL(K + 1:N) >= SOGLIA_LLR);
            if length(indxH) + length(indxB) == 0
                indxH = 1:length(eta_H);
                indxB = 1:length(eta_B);
            end;
            for t = 1:T
                %%%%%%决策
                if sum([UH(indxH, t); UB(indxB, t)]) >= (length(indxH) + length(indxB)) / 2
                    Dr(t) = 1;
                else
                    Dr(t) = 0;
                end;
            end
            indx = find(P == 1);
            Nerr_hr_LLR(is) = Nerr_hr_LLR(is) + length(find(Dr(indx) == 0));
            indx = find(P == 0);
            Nerr_br_LLR(is) = Nerr_br_LLR(is) + length(find(Dr(indx) == 1));
        end;
        %================== 结束解码 Varshney 和 LLR ==============================

        %=================== 解码最大熵案例 =====================
        all_idx_combinations = permute_matrix(N, M);
        for i = 1:2^T
            state = possible_states(i, :);

            nonz = bsxfun(@minus, R_matrix, state);
            neq = T - sum(nonz ~= 0, 2);

            for Pmal_guess_dec = 1:1:6
                Pmal_guess = (Pmal_guess_dec + 4) / 10;
                delta_Byz_guess = (1 - delta) * (1 - Pmal_guess) + (delta) * Pmal_guess;
                states_score(i, Pmal_guess_dec) = FNKmatrix(M, N, epsilon, delta_Byz_guess, T, neq); % 使用迭代实现（方便）
            end
        end

        %========================= 结束解码最大熵案例 ===========================================================

        %========================= 最大熵最终决策 =================================================================
        [val_dec, idx_dec] = max(states_score, [], 1); % 对每列计算最大值和索引

        for iii = 1:length(val_dec)
            dec_fusion(iii, :) = possible_states(idx_dec(iii), :); % dec_fusion 矩阵的每一行对应不同的 Pmal 猜测下的决策
            % dec_fusion 矩阵的大小应为 6xT

            err_dec(np, iii) = numel(find(P ~= dec_fusion(iii, :))); % 计算每次 Pmal 猜测下的决策错误数量
        end
        %========================= 最大熵最终决策 =================================================================

        total_nb_trials(np) = length(P);

        diff_majority = P - D;

        err_nb_majority(np) = nnz(diff_majority); % 多数投票规则的错误决策数量
    end

    p_err(1, :) = sum(err_dec, 1) / sum(total_nb_trials); % 这一行包含不同 Pmal 猜测下的结果，然后，其大小为 1x6

    results.p_err = p_err;

    %==================== Varshney 和 LLR 的决策和错误计算 =========================
    results.PD = 1 - Nerr_h / Nprove / T;
    results.PFA = Nerr_b / Nprove / T;
    for ig = 1:length(gammas)
        results.PDr(ig) = 1 - Nerr_hr(ig) / Nprove / T;
        results.PFAr(ig) = Nerr_br(ig) / Nprove / T;
        results.PD_IDB(ig) = 1 - Nerr_H(ig) / K / Nprove;
        results.PFA_IDB(ig) = Nerr_B(ig) / M / Nprove;
        results.P_ISO_H(ig) = Nerr_H(ig) / K / Nprove;
        results.P_ISO_B(ig) = 1 - Nerr_B(ig) / M / Nprove;
    end;
    for is = 1:Nsoglie_LLR
        results.PD_IDB_LLR(is) = 1 - Nerr_H_LLR(is) / K / Nprove; % 1 - P_ISO^H
        results.PFA_IDB_LLR(is) = Nerr_B_LLR(is) / M / Nprove;  % 1 - P_ISO^B = P_NONISO^B
        results.P_ISO_H_LLR(is) = Nerr_H_LLR(is) / K / Nprove; % P_ISO^H
        results.P_ISO_B_LLR(is) = 1 - Nerr_B_LLR(is) / M / Nprove;  % P_ISO^B
        results.PDr_LLR(is) = 1 - Nerr_hr_LLR(is) / Nprove / T;
        results.PFAr_LLR(is) = Nerr_br_LLR(is) / Nprove / T;
    end;
    %==================== Varshney 和 LLR 的决策和错误计算 ======================
    error_majority = sum(err_nb_majority) / sum(total_nb_trials);

    results.error_majority = error_majority;

end