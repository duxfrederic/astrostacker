using Pkg
if isfile("../Project.toml") && isfile("../Manifest.toml")
    Pkg.activate("../")
end

include("rejection.jl");
include("normalization.jl");
include("stack.jl")

###########################################################################
function getPathListDemo()
    d = "../../data";
    [joinpath(d, p) for p in readdir(d)]
end
pathlist = getPathListDemo();
outname = "stack.fits"
println("starting")
stackFitsFiles(pathlist, 8e9, "stack.fits", 2, 2, "winsorizedsigma", "multiplicativebackground")

###########################################################################