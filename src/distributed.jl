struct DistributedIterator{A}
	ifuns::Vector{A}
  workers::Vector{Int}
end

distributed_states = Dict{Symbol,Any}();
distributed_iterators = Dict{Symbol,Any}();
inititerator(iterator, id) = distributed_iterators[id] = iterator;

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

function Base.iterate(ffl::DistributedIterator)
	id = Symbol(randstring(10))
	[remotecall_fetch(DataIterators.inititerator, wi, ffl.ifuns[i], id) for (i, wi) in enumerate(ffl.workers)]
	r = [remotecall(DataIterators.next, i, id) for i in ffl.workers]
	Base.iterate(ffl, (1, r, id))
end

function Base.iterate(ffl::DistributedIterator, s)
	i, r, id = s
	isempty(r) && return(nothing)
	v, i, r = fetchresult(i, r)
	if i > 0
		r[i] = remotecall(DataIterators.next, r[i].where, id)
		i = cyclicinc(i, length(r))
	end
	return(v, (i, r, id))
end

cyclicinc(i, n) = i == n ? 1 : i + 1

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

function findready(i, r)
	status = isready.(r)
	j = i
	while status[j] == true
		j = cyclicinc(j, length(r))
		j == i && break;
	end
	j
end

Base.IteratorSize(::DistributedIterator) = Base.SizeUnknown()