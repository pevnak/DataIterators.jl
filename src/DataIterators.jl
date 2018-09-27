module DataIterators
using MLDataPattern
using StatsBase: sample
include("utils.jl")
include("fileiterator.jl")
include("inffileiterator.jl")
include("iterator2fun.jl")
include("circularbuffer.jl")

export FileIterator, InfiniteFileIterator, Iterator2Fun, CircularBuffer
end # module
