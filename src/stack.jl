using FITSIO
import NaNStatistics

include("rejection.jl");
include("normalization.jl");



function stackFitsFiles(pathlist, outname; 
                        limitmemory=4e9, # default: ~ 4GB memory
                        combination="average", 
                        normalization="background",
                        rejection="winsorizedsigma",
                        rejlow=1.6, # in units of sigma for the default
                        rejhigh=1.7,
                        weighting="backgroundnoise")

    # we assume that one file fits in memory.
    # like, were this not the case I'd give up anyways.
    

    ############### selecting our options ####################
    # combination:
    if (combination == "average") | (combination == "mean")
        combinationFunction = NaNStatistics.nanmean
    elseif combination == "median"
        combinationFunction = NaNStatistics.nanmedian
    end

    # rejection:
    if rejection == "winsorizedsigma"
        rejectionFunction = winsorizedSigmaClipping;
    elseif (rejection == "none") | (rejection == "") 
        rejectionFunction = boringRejectionFunction;
    else 
        throw(error("Unimplemented rejection method"))
    end

    # normalization:
    if normalization == "background"
        normalizationFunction = backgroundNormalization;
    elseif (normalization == "none") | (normalization == "")
        normalizationFunction = boringNormalization;
    else
        throw(error("Unimplemented normalization method"))
    end

    # weighting
    if weighting == "backgroundnoise"
        weightingFunction = weightByBackgroundNoise
    elseif ((weighting == "none") | (weighting == ""))
        weightingFunction = boringWeighting
    else
        throw(error("Unimplemented weighting method"))
    end


    # get the size of the files:
    f = FITS(pathlist[1])[1];
    sizex, sizey = size(f);

    # initialize the result:
    mainresult = zeros(eltype(f), (sizex, sizey));

    # get the memory footprint of the files:
    mem = Base.summarysize(read(f)) * length(pathlist);
    
    # consider spitting the process if our files are 
    # too big:
    limitmemory = floor(Int, limitmemory);
    if mem > limitmemory 
        Nparts = div(mem, limitmemory) + 1;
    else 
        Nparts = 1;
    end


    # so, we'll store some values if needed
    # (basically if we do any kind of normalization
    #  and weighting)
    if ~( ((normalization == "none") | (normalization == ""))
           & ((rejection == "none") | (rejection == "")) )
        scales, sigmas = getFilesStats(pathlist);
    else
        scales = ones(eltype(f), length(pathlist));
        sigmas = ones(eltype(f), length(pathlist));
    end

    

    print("Stacking in ")
    print(Nparts)
    println(" parts.")

    # this is the size of the slice we are
    # going to load. (slicing the x axis)
    slicesize = div(sizex, Nparts);

    # now we go slice by slice.
    for N = 1:Nparts
        # we'll begin reading at `ini`:
        ini = (N-1) * slicesize + 1;
        # and end at `last`:
        if N == Nparts 
            ending = sizex;
        else 
            ending = N * slicesize;
        end
        stackxsize = ending - ini + 1; 
        
        # this is our partial stack:
        stack = zeros(eltype(f), (length(pathlist), stackxsize, sizey));
        readStackPart!(stack, pathlist, ini, ending);

        # let's reject-average it!
        mainresult[ini:ending, :] = stackCombine(stack, 
                                                 combinationFunction,
                                                 rejectionFunction, 
                                                 rejlow, rejhigh,
                                                 normalizationFunction,
                                                 scales, sigmas,
                                                 weightingFunction);
    end
    # write the result to disk.
    FITS(outname, "w") do fout
        write(fout, mainresult);
    end
    
end

function readStackPart!(stack, pathlist, ini, ending)

    for i = 1:length(pathlist)
        stack[i, :, :] = read(FITS(pathlist[i])[1], ini:ending, :);
    end

    stack
end



function stackCombine(array, combineFunction, rejectionFunction, rejlow, rejhigh,
                                              normalizationFunction, scales, sigmas,
                                              weightingFunction)
    depth, sizex, sizey = size(array)
    result =  zeros(eltype(array), (sizex, sizey));

    @inbounds for j = 1:sizey 
        @inbounds for i = 1:sizex
            column = array[:, i, j];
            trimmed = rejectionFunction(copy(column), rejlow, rejhigh,
                                        normalizationFunction, scales, sigmas,
                                        weightingFunction);
            result[i,j] = combineFunction(trimmed);
        end
    end
    result
end


