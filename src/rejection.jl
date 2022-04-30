import StatsBase

function winsorize!(x, m0, m1)
    @inbounds for i = 1:length(x)
        if x[i] < m0 
            x[i] = m0 
        elseif x[i] > m1 
            x[i] = m1 
        end  
    end
end

function sigmaClipping(x, m, sig, siglow, sighigh)
    if (m - x) / sig > siglow 
        return true
    elseif (x - m) / sig > sighigh 
        return true
    else
        return false
    end

end

function winsorizedSigmaClipping(x, siglow, sighigh)
    N = length(x);

    while true
        m = StatsBase.median(x);
        sig = StatsBase.std(x);
        tmp = copy(x);
        while true
            m0 = m - 1.5 * sig; 
            m1 = m + 1.5 * sig; 
            winsorize!(tmp, m0, m1);
            m = StatsBase.median(tmp); 
            sig0 = sig; 
            sig = 1.134 * StatsBase.std(tmp)
            abs(sig-sig0) / sig0 > 0.0005 || break
        end

        clipped = Vector{eltype(x)}();
        n = 0;
        @inbounds for i = 1:N
            if sigmaClipping(x[i], m, sig, siglow, sighigh)
                n += 1
            else 
                push!(clipped, x[i])
            end
        end
        N = N - n;

        x = copy(clipped);

        n > 0 & N > 3 || break
    end 

    return x
end