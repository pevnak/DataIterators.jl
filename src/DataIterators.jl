module DataIterators
using MLDataPattern
using StatsBase: sample
include("utils.jl")
include("fileiterator.jl")
include("inffileiterator.jl")
include("iterator2fun.jl")

export FileIterator, InfiniteFileIterator, Iterator2Fun
end # module
