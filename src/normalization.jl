import NaNStatistics
using FITSIO


function boringNormalization(column, scales, sigmas)
   return column;
end

function backgroundNormalization(column, scales, sigmas)
    # somehow works well: normalize
    # each image by its background value
    normed = (scales[1] ./ scales) .* column;

    normed
end

function neutralizeAndScale(column, scales, sigmas)
    # remove the background, add that of the 
    # first image,
    # then scale
    normed = (scales[1] ./ scales) .* (column .- scales .+ scales[1]);

    normed
end

function boringWeighting(column, scales, sigmas)
    # we only scale:
    return (scales[1] ./ scales) .* column;
end

function weightByBackgroundNoise(column, scales, sigmas)
    Z = sum(sigmas.^(-1));
    weighted = Z^(-1)  .* (column ./ sigmas);

    # scale
    weighted = (scales[1] ./ scales) .* weighted;

    weighted
end


function getFilesStats(filepaths)
    f = FITS(filepaths[1]);
    elt = eltype(f[1]);

    scales = zeros(elt, length(filepaths));
    sigmas = zeros(elt, length(filepaths));

    for i in 1:length(filepaths)
        fin = FITS(filepaths[i], "r");
        m, s = getBackgroundStats(read(fin[1]));
        scales[i] = m;
        sigmas[i] = s;
    end

    [scales, sigmas]
end

function getBackgroundStats(array, ns=1.)
    # used to estimate scales and weights.
    clmp = copy(array);
    while true 
        m = NaNStatistics.nanmedian(clmp);
        s = NaNStatistics.nanstd(clmp);
        clamp!(clmp, m - ns*s, m + ns*s)
        m1 = NaNStatistics.nanmedian(clmp);
        abs(m1 - m)/m > 0.05 || break
    end
    [NaNStatistics.nanmedian(clmp), NaNStatistics.nanstd(clmp)];
end
