# astrostacker.jl

While IRAF is slowly dying, every astronomer is switching their workflow towards Python. This is awesome, but I do not think there exists a good image stacker available natively in Python. As a result, often images are combined using a simple median, but this yields a signal-to-noise ratio which is always below that obtained with an average. An average however, needs the rejection of the unreasonable valued pixels to be viable. This is not easily done in Python, and the implementations I have seen (e.g., `ccdproc`) have not been working for me. Hence this package implementing, hopefully, a proper stacking algorithm that maximizes the signal-to-noise ratio of your stacks the way IRAF used to do. 

