import StatsBase
using FITSIO


function boringNormalization(filepaths)
   return [1. for f in filepaths]
end

function backgroundNormalization(filepaths)
    norm = Vector{Float32}();
    for f in filepaths
        FITS(f, "r") do fin
            push!(norm, getBackground(read(fin[1])));
        end
    end

    norm ./ StatsBase.minimum(norm);
end

function getBackground(array, ns=1.)
    clmp = copy(array);
    while true 
        m = StatsBase.median(clmp);
        s = StatsBase.std(clmp);
        clamp!(clmp, m - ns*s, m + ns*s)
        m1 = StatsBase.median(clmp);
        abs(m1 - m)/m > 0.05 || break
    end

    StatsBase.median(clmp);
end