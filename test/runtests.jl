using Test
using DataIterators: FileIterator
using Mill: ArrayNode

@testset "testing FileIterator with Arrays" begin
	d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => reshape([8], (1,1)))
	loadfun(f) = d[f]
	@test all(collect(FileIterator(loadfun, ["a", "b", "c"], 2)) .== [[1 2], [3 4], [5 6], [7 8]])
	@test all(collect(FileIterator(loadfun, ["a", "b"], 2)) .== [[1 2], [3 4], [5 6], reshape([7],1 ,1)])
	@test all(collect(FileIterator(loadfun, ["a", "b", "c"], 20)) .== [[1 2 3 4 5 6 7 8]])
end

@testset "testing FileIterator with ArrayNode" begin
	d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => reshape([8], (1,1)))
	loadfun(f) = ArrayNode(d[f])

	@test all([x.data for x in FileIterator(loadfun, ["a", "b", "c"], 2)] .== [[1 2], [3 4], [5 6], [7 8]])
	@test all([x.data for x in FileIterator(loadfun, ["a", "b"], 2)] .== [[1 2], [3 4], [5 6], reshape([7],1 ,1)])
	@test all([x.data for x in FileIterator(loadfun, ["a", "b", "c"], 20)] .== [[1 2 3 4 5 6 7 8]])
end
