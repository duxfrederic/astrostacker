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


function boringRejectionFunction(x, siglow, sighigh, normalizationFunction, scales, sigmas, weightingFunction)
    return x;
end

function winsorizedSigmaClipping(x, siglow, sighigh, normalizationFunction, scales, sigmas, weightingFunction)
    N = length(x);
    # first, normalize the input:
    xnorm = normalizationFunction(x, scales, sigmas);
    # but from now on, x will be weighted 
    x = weightingFunction(x, scales, sigmas);
    while true
        m = StatsBase.median(xnorm);
        sig = StatsBase.std(xnorm);
        tmp = copy(xnorm);
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
        clippednorm = Vector{eltype(x)}();
        n = 0;
        @inbounds for i = 1:N
            if sigmaClipping(xnorm[i], m, sig, siglow, sighigh)
                n += 1
            else 
                push!(clipped, x[i])
                push!(clippednorm, xnorm[i])
            end
        end
        N = N - n;
        
        # the x elements are rejected without
        # being affected by the normalization:
        x = copy(clipped);
        xnorm = copy(clippednorm);

        n > 0 & N > 3 || break
    end 
    # in the end, we return the rejected,
    # un-normalized version:
    return x
end