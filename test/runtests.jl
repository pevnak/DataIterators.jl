using Test, DataIterators
using Mill: ArrayNode

function collectnl(iter, n = typemax(Int))
	next = iterate(iter)
	items = []
	j = 0;
	while next !== nothing && j < n
	    (i, state) = next
	    push!(items, i)
	    next = iterate(iter, state)
	    j += 1
	end
	items
end

callnl(iter, n) = [iter() for _ in 1:n]

@testset "testing FileIterator with Arrays" begin
	d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => reshape([8], (1,1)))
	loadfun(f) = d[f]
	@test isempty(collect(FileIterator(loadfun, [], 2)))
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

@testset "testing InfiniteFileIterator with Arrays" begin
	d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => reshape([8], (1,1)))
	loadfun(f) = d[f]
	@test isempty(collect(InfiniteFileIterator(loadfun, [], 2)))
	@test all(collectnl(InfiniteFileIterator(loadfun, ["a", "b", "c"], 2), 8) .== [[1 2], [3 4], [5 6], [7 8], [1 2], [3 4], [5 6], [7 8]])
	@test all(map(x -> sort(x, dims = 2),collectnl(InfiniteFileIterator(loadfun, ["b"], 2), 3)) .== [[6 7], [6 7], [6 7]])
	@test all(map(x -> sort(x, dims = 2),collectnl(InfiniteFileIterator(loadfun, ["b"], 3), 3)) .== [[6 7], [6 7], [6 7]])
	@test all(map(x -> sort(x, dims = 2),collectnl(InfiniteFileIterator(loadfun, ["a", "b"], 7), 2)) .== [[1 2 3 4 5 6 7], [1 2 3 4 5 6 7]])
	@test all(map(x -> sort(x, dims = 2),collectnl(InfiniteFileIterator(loadfun, ["a", "b"], 10), 2)) .== [[1 2 3 4 5 6 7], [1 2 3 4 5 6 7]])
	@test all(collectnl(InfiniteFileIterator(loadfun, ["a", "b"], 5), 2) .== [[1 2 3 4 5], [6 7 1 2 3]])
end


@testset "testing Iterator2fun with Arrays" begin
	d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => reshape([8], (1,1)))
	loadfun(f) = d[f]
	@test all(callnl(Iterator2Fun(InfiniteFileIterator(loadfun, ["b", "c"], 2)), 8) .== [[6 7], [8 6], [7 8], [6 7], [8 6], [7 8], [6 7], [8 6]])
end


@testset "testing CircularBuffer with Arrays" begin
	d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => reshape([8], (1,1)))
	loadfun(f) = d[f]
	@test all(collectnl(CircularBuffer(FileIterator(loadfun, ["b", "c"], 2), 2)) .== [ [6 7], reshape([8], 1, 1), [6 7], reshape([8], 1, 1), reshape([8], 1, 1)])
end

include("distributed.jl")
 
nothing