using Distributed, Test
nprocs() < 3 && addprocs(3 - nprocs())
@everywhere begin
 using DataIterators;
 d = Dict("a" => 10*myid().+[1 2 3 4 5],
         "b" => 10*myid().+[6 7]);
 loadfun(f) = d[f]
end 

ffl = DistributedIterator(fill(FileIterator(loadfun,["a","b"],3), 2), [2,3])
@testset "remote iterator" begin
	@test all(collect(ffl) .== [[31 32 33], [21 22 23], [34 35 36], [24 25 26], reshape([37],1 ,1), reshape([27], 1, 1), nothing])
end