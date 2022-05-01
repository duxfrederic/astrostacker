using Pkg
if isfile("../Project.toml") && isfile("../Manifest.toml")
    Pkg.activate("../")
end

include("rejection.jl");
include("normalization.jl");
include("stack.jl")

###########################################################################
pathlist = 
["/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001112_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001108_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001094_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001097_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001099_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001105_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001095_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001104_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001109_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001098_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001111_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001093_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001100_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001110_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001092_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001107_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001096_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001102_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001101_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001103_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001106_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001108_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001094_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001097_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001099_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001105_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001095_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001104_red_aligned.fits",
"/scratch/telesto/workdir/I _Slot 1_Slot 0__120,000secs_Iris Nebula00001109_red_aligned.fits"];

outname = "stack.fits"
println("starting")
stackFitsFiles(pathlist, 8e9, "stack.fits", 2, 2, "winsorizedsigma", "multiplicativebackground")

###########################################################################