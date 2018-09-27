# DataIterators.jl

This small package is a work on progress on providing an iterator over data spread over multiple files. 
It is inteded to facilitate training with minibatches, such that the iterator would provide minibatches of 
constant size hiding the fact that data are spread.

Contains:
* FileIterator
* InfiniteFileIterator
* Iterator2Fun
* CircularBuffer

### FileIterator
The best is to show a simplified example, in which the files system is simulated by a dictionary 
```
d = Dict("a" => [1 2 3 4 5], 
		"b" => [6 7], 
		"c" => [8 9 10 11])
```
and the loading function returns an element from the dictionary
```
loadfun(f) = d[f]
```

The iterator `FileIterator(loadfun, files, bs))` uses loads data using load function `loadfun` from files and 
outputs batches of size `bs`. At the moment it is assumed that files is a structure supporting linear indexing 
(list of vectors). Furthermore, function `nobs` from MLDataPattern package is used to calculate number of samples in minibatch. 
The packege defines its own function `catobs` to concatenates observations. For arrays, it concatenates them along the last 
dimensions and the library contains a fallback `catobs(x...) = cat(x...)`. If you need custom handling for your type, just 
overload it as
```DataIterators.catobs(x::T...) where {T} = mycat(x...)```.

The complete above example is as follows
```
d = Dict("a" => [1 2 3 4 5],
  "b" => [6 7],
  "c" => [8 9 10 11])
loadfun(f) = d[f]
collect(FileIterator(loadfun, ["a", "b", "c"], 2))
 ```
 returns elements
 ```
 [1 2]
 [3 4]
 [5 6]
 [7 8]
 [9 10]
 [11]
 ```
 
 ### InfiniteFileIterator
 Is similar in the spirit to FileIterator except that it provides infinite number of mini-batches. If the data are small and they are loaded in the first round, then the iterator keeps them and sample from them without repetition.


### CircularBuffer
`CircularBuffer(iterator, k)` does what its name suggests. Implements cache providing each sample at most k-times. Note that the implementation is not entirely correct at beggining and end.

### Iterator2Fun
Converts iterator to function call, hiding the state. The approach is not type safe!


* See unit-test for examples *
