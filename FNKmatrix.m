function [fnk, M] = FNKmatrix(K, N, epsilon, delta, T, neq)

if size(neq,1)==1
    neq = [0, neq]; 
elseif size(neq,2)==1
    neq = [0; neq]; 
end
% must append one zero because Matlab indexing starts from [1],
% otherwise one doesn't get the right neq[s] during computation below

A = [ones(N-K+1,N); zeros(K+1,N)];
B = A(1:(K+1)*(N+1));

M = reshape(B,N+1,K+1);

[I,J] = find(M==1);

for i=1:numel(I)
    
    k = J(i);
    n = I(i);
    %fprintf('Filling element (n,k) = (%d,%d)\n',n-1,k-1);
    
    % First column, i.e. K=0, all the nodes are honest
    if (k==1)
        
        t=1;
        for s=2:n
            t = t*(epsilon^(T-neq(s)) * (1-epsilon)^neq(s));
        end
        M(n,k) = t;
        
    elseif n==k  % Main diagonal, all nodes are byzantines
        
        t=1;
        for s=2:n
            t = t*(delta^(T-neq(s)) * (1-delta)^neq(s));
        end
        
        M(n,k) = t;
        
    else % All the rest of the matrix
        M(n,k) = delta^(T-neq(n)) * (1-delta)^neq(n) * M(n-1,k-1) + ...
            epsilon^(T-neq(n)) * (1-epsilon)^neq(n) * M(n-1,k);
    end
    
end

%fnk = log(M(end));

fnk = M(end);

