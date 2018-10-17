module DataIterators
using MLDataPattern, Distributed, Random, Mill
using StatsBase: sample
include("utils.jl")
include("fileiterator.jl")
include("inffileiterator.jl")
include("iterator2fun.jl")
include("circularbuffer.jl")
include("distributed.jl")

export FileIterator, InfiniteFileIterator, Iterator2Fun, CircularBuffer, DistributedIterator
end # module
