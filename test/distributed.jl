@everywhere begin
 push!(LOAD_PATH, "/Users/tpevny/Work/Julia/Pkg");
 using DataIterators;
 d = Dict("a" => 10*myid().+[1 2 3 4 5],
         "b" => 10*myid().+[6 7]);
 loadfun(f) = d[f]
end 

ffl = DistributedIterator(fill(FileIterator(loadfun,["a","b"],3), nworkers()), workers())
collect(ffl)