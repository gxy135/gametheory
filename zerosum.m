%   如果没有纯策略解，将获得混合策略解；否则，将显示纯策略解的索引。
%
% 将零和博弈问题转换为线性规划问题，然后使用优化工具箱中的 linprog 来解决问题。

% 清空工作区和命令窗口
clear all;
clc;

% 输入游戏矩阵
A = input('输入游戏矩阵: ');
% 初始化策略向量 r 和 s
r = []; 
s = [];
% 获取矩阵 A 的行数 m 和列数 n
[m, n] = size(A);

% 检查是否存在鞍点（纯策略解）
if min(max(A)) == max(min(A'))
    % 获取每列的最大值
    b = max(A);
    % 初始化策略索引向量
    Strategy_Ist = [];
    Strategy_IInd = [];
    ms = [];
    % 遍历每一列，找到最小值所在的行
    for i = 1:n
        for j = 1:m
            % 如果当前列的最大值等于矩阵 A 中第 j 行第 i 列的元素
            if isequal(b(i), A(j, i))
                % 并且该元素等于第 j 行的最小值
                if isequal(A(j, i), min(A(j, :)))
                    r(length(r) + 1) = j; % 记录行索引
                    s(length(s) + 1) = i; % 记录列索引
                end
            end
        end
    end
    % 如果存在唯一的鞍点
    if (length(r) == 1 && length(s) == 1)
        % 显示鞍点的位置和游戏值
        Answer = ['游戏在位置 (' int2str(r) ',' int2str(s) ') 处有一个鞍点，游戏的值为 ' num2str(A(r, s), 6) '。因此不需要混合策略。']
    else
        % 如果存在多个鞍点
        for i = 1:length(r)
            ms = [ms '(' int2str(r(i)) ',' int2str(s(i)) '),'];
        end
        % 显示所有鞍点的位置和游戏值
        Answer = ['游戏在以下位置有鞍点：' ms ' 游戏的值为 ' num2str(A(r(1), s(1)), 6) '。因此不需要混合策略。']
    end
else
    % 如果不存在鞍点，则使用线性规划求解混合策略
    % 玩家 1 的混合策略
    % 目标函数为最小化 v
    % 不等式约束为 A' * x >= v
    % 等式约束为 sum(x) == 1
    % 变量下界为 -inf 和 0
    X_a = linprog(-[1; zeros(m, 1)], [ones(n, 1) -A'], zeros(n, 1), [0 ones(1, m)], [1], [-inf; zeros(m, 1)]);
    v = X_a(1, 1); % 提取游戏值
    X_a(1, :) = []; % 去除游戏值，得到混合策略
    % 玩家 2 的混合策略
    % 目标函数为最大化 v
    % 不等式约束为 -A * y <= -v
    % 等式约束为 sum(y) == 1
    % 变量下界为 -inf 和 0
    X_b = linprog([1; zeros(n, 1)], [-ones(m, 1) A], zeros(m, 1), [0 ones(1, n)], [1], [-inf; zeros(n, 1)]);
    X_b(1, :) = []; % 去除游戏值，得到混合策略
    % 显示结果
    Answer = ['游戏没有鞍点，游戏的值为 ' num2str(v, 6) '，因此建议的混合策略在混合策略矩阵中给出。']
    Strategy_Ist = X_a % 玩家 1 的混合策略
    Strategy_IInd = X_b % 玩家 2 的混合策略
end