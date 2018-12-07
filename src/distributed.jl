"""
	struct DistributedIterator{A}
		iterators::Vector{A}
	  workers::Vector{Int}
	end

	runs `iterators` remotely on `workers`, such that their states are stored on remote processes and only 
	values are moved between processes.
"""
struct DistributedIterator{A}
	iterators::Vector{A}
  workers::Vector{Int}
end


DistributedIterator(iterators::Vector) = DistributedIterator(iterators,workers()[1:length(iterators)])
DistributedIterator(iterator) = DistributedIterator(fill(iterator, nworkers()), workers())

function Base.iterate(ffl::DistributedIterator)
	id = Symbol(randstring(10))
	[remotecall_fetch(DataIterators.inititerator, wi, ffl.iterators[i], id) for (i, wi) in enumerate(ffl.workers)]
	r = [remotecall(DataIterators.next, i, id) for i in ffl.workers]
	Base.iterate(ffl, (1, r, id))
end

function Base.iterate(ffl::DistributedIterator, s)
	i, r, id = s
	isempty(r) && return(nothing)
	v, i, r = fetchresult(i, r)
	v == nothing && return(nothing)
	if i > 0
		r[i] = remotecall(DataIterators.next, r[i].where, id)
		i = cyclicinc(i, length(r))
	end
	return(v, (i, r, id))
end

distributed_states = Dict{Symbol,Any}();
distributed_iterators = Dict{Symbol,Any}();
inititerator(iterator, id) = distributed_iterators[id] = iterator;

"""
	clear_distributed!()

	clear all dictionaries used by remote iterator an all processes
"""
function clear_distributed!() 
	[remotecall_fetch(DataIterators._clear_distributed!, i) for i in workers()]
	_clear_distributed!()
end

function _clear_distributed!()
	foreach(k -> delete!(distributed_states, k), keys(distributed_states))
	foreach(k -> delete!(distributed_iterators, k), keys(distributed_iterators))
end

"""
		next(id)

		return the next value of iterator in `distributed_iterators[id]` using state `distributed_states[id]`
"""
function next(id)
	if !haskey(distributed_iterators, id)
		@warn "iterator not initialized"
		return(nothing)
	end

	iterator = distributed_iterators[id]
	r = haskey(distributed_states, id) ? iterate(iterator, distributed_states[id]) : iterate(iterator)
	if r == nothing 
		delete!(distributed_states, id)
		delete!(distributed_iterators, id)
		return(nothing)
	end
	v, s = r
	distributed_states[id] = s 
	v
end

"""
		cyclicinc(i, n)

		increment `i` by one and if it is greater than `n`, it returns to beginning
"""
cyclicinc(i, n) = i == n ? 1 : i + 1

"""
		(v, i, r) = function fetchresult(i, r)

		Fetch the result from first iterator (future calls in `r`) that has a value. 
		The search for finished iterator starts at `i` and if no iterator is free, it waits for one.
		If a remote iterator finishes (return value is `nothing`), it is removed from r

		v --- returned value 
		i --- position of fetched iterator 
		r --- updated vector with futures

"""
function fetchresult(i, r)
	while !isempty(r)
		i = findready(i, r)
		v = fetch(r[i])
		if v == nothing
			r = r[setdiff(1:length(r), i)]
			i = i > length(r) ? length(r) : i
		else 
			return(v, i, r)
		end
	end
	(nothing, 0, [])
end

"""
	findready(i, r)

	find an index of first finished iterator in `r` (vector of futures) starting at `i`th position
"""
function findready(i, r)
	# @show (i, isready.(r))
	j = i
	while !isready(r[j])
		j = cyclicinc(j, length(r))
		j == i && break;
	end
	j
end

Base.IteratorSize(::DistributedIterator) = Base.SizeUnknown()