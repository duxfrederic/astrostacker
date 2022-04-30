using FITSIO
import StatsBase

include("rejection.jl");
include("normalization.jl");



function stackFitsFiles(pathlist, limitmemory, outname, siglow, sighigh,
                        rejection, 
                        normalization)

    # we assume that one file fits in memory.
    # like, were this not the case I'd give up anyways.


    # select our options:
    if rejection == "winsorizedsigma"
        rejectionFunction = winsorizedSigmaClipping;
    else 
        throw(error("Unimplemented rejection method"))
    end
    
    if normalization == "multiplicativebackground"
        normalizationFunction = backgroundNormalization;
    else
        throw(error("Unimplemented normalization method"))
    end

    # first compute the normalization to make 
    # our rejection algorithms meaningfull:
    normalization = normalizationFunction(pathlist);

    

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
        readStackPart!(stack, pathlist, ini, ending, normalization);

        # let's reject-average it!
        mainresult[ini:ending, :] = rejectionMean(stack, rejectionFunction, 
                                                  siglow, sighigh);
    end
    FITS(outname, "w") do fout
        write(fout, mainresult);
    end
    
end

function readStackPart!(stack, pathlist, ini, ending, normalization)

    for i = 1:length(pathlist)
        coeff = 1. / normalization[i];
        stack[i, :, :] = coeff * read(FITS(pathlist[i])[1], ini:ending, :);
    end

    stack
end



function rejectionMean(array, rejectionFunction, siglow, sighigh)
    depth, sizex, sizey = size(array)
    result =  zeros(eltype(array), (sizex, sizey));

    @inbounds for j = 1:sizey 
        @inbounds for i = 1:sizex
            column = array[:, i, j];
            trimmed = rejectionFunction(copy(column), siglow, sighigh);
            result[i,j] = StatsBase.mean(trimmed);
        end
    end
    result
end


