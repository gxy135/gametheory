function y = fnk(K,N,s0,epsilon,delta,T,neq,it)

% Tutti i casi in cui ci sono solo onesti
if (K==0)
    y=1;
    for i=it:s0 %i=s0-N+1:s0
        y = y*(epsilon^(T-neq(i)) * (1-epsilon)^neq(i));
    end
    
    % Tutti i casi cui ci sono solo bizantini
elseif (K==N)
    y=1;
    for i=it:s0%i=s0-N+1:s0
        y = y*(delta^(T-neq(i)) * (1-delta)^neq(i));
    end
    
    % Tutte le altre configurazioni
elseif (K~=N)
    
    y = delta^(T-neq(it)) * (1-delta)^neq(it) * fnk(K-1, N-1,s0,epsilon,delta,T,neq,it+1) + ...  % contributo (K-1,N-1)
        epsilon^(T-neq(it)) * (1-epsilon)^neq(it) * fnk(K,N-1,s0,epsilon,delta,T,neq,it+1); % contributo (K,N-1)
    
end


