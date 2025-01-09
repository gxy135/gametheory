function [sample] = gen_rd(N, nb_samples)

% 本函数所需的输入参数为：
%   N: 网络规模（节点总数）
%   nb_samples: 我们希望生成的指定分布的样本数量。

% K.K.: 本函数生成一个根据加权离散分布的随机整数，
% 其中每个可能的结果都有不同的出现概率。

% 检查 N 是奇数还是偶数，以便处理当 N/2 -1 不是整数的情况
if mod(N, 2)
    % N 是奇数
    a = 0:floor(N/2);     
else 
    % N 是偶数
    a = 0:((N/2)-1);   
end

% 计算从 0 到 N/2 -1（根据 N 的奇偶性）的所有组合数
for cf = 0:1:length(a)-1
    all_nb_config(cf+1) = nchoosek(N, cf);
end
all_config = sum(all_nb_config); % 计算所有组合的总数

% 为每个可能的拜占庭节点数量生成权重
for ix = 0:length(a)-1 
    w(ix+1) = nchoosek(N, ix) / all_config; 
    % 生成分布，每个可能的拜占庭节点数量（从 0 到 N/2 -1）对应一个权重
end

% 根据权重 w 生成样本
sample = a( sum( bsxfun(@ge, rand(nb_samples,1), cumsum(w./sum(w))), 2) + 1 ); 
% 这行代码根据权重向量 w 生成一个大小为 nb_samples 的向量，
% 其中值是根据 w 中的权重生成的。

% 如果想查看分配给每个可能性的权重，将 [sample] 改为 [sample, w]
% 例如，在命令窗口中：
% [s, w] = gen_rd(10, 5000); % 5000 是样本数量，可以根据需要设置为从 1 到数百万
% 然后：
% tabulate(s)

%============================示例=== 示例 ====================================
% 将 [sample] 改为 [sample, w]
% 在命令窗口中：
% [s, w] = gen_rd(10, 5000); % 5000 是样本数量，可以根据需要设置
% 现在：
% tabulate(s)

%========================================================================

end