using Test
using DataIterators: FileIterator
using Mill: ArrayNode

d = Dict("a" => [1 2 3 4 5], 
	"b" => [6 7], 
	"c" => [8])
loadfun(f) = (println("reading ",f); d[f])

@test all(collect(FileIterator(loadfun, ["a", "b", "c"], 2)) .== [[1 2], [3 4], [5 6], [7 8]])
@test all(collect(FileIterator(loadfun, ["a", "b"], 2)) .== [[1 2], [3 4], [5 6], reshape([7],1 ,1)])
@test all(collect(FileIterator(loadfun, ["a", "b", "c"], 20)) .== [[1 2 3 4 5 6 7 8]])

loadfun(f) = (println("reading ",f); ArrayNode(d[f]))

@test all([x.data for x in FileIterator(loadfun, ["a", "b", "c"], 2, (x, y) -> cat(x, y))] .== [[1 2], [3 4], [5 6], [7 8]])
@test all([x.data for x in FileIterator(loadfun, ["a", "b"], 2, (x, y) -> cat(x, y))] .== [[1 2], [3 4], [5 6], reshape([7],1 ,1)])
@test all([x.data for x in FileIterator(loadfun, ["a", "b", "c"], 20, (x, y) -> cat(x, y))] .== [[1 2 3 4 5 6 7 8]])