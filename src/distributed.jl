struct DistributedIterator{A}
	ifuns::Vector{A}
  workers::Vector{Int}
end

itstates = Dict{Symbol,Any}();

function next(ifun, id)
	r = if haskey(itstates, id)
		iterate(ifun, itstates[id])
	else 
		iterate(ifun)
	end
	if r == nothing 
		delete!(itstates, id)
		return(nothing)
	end
	v, s = r
	itstates[id] = s 
	v
end

function Base.iterate(ffl::DistributedIterator)
	id = Symbol(randstring(10))
	r = [remotecall(DataIterators.next, wi, ffl.ifuns[i], id) for (i, wi) in enumerate(ffl.workers)]
	Base.iterate(ffl, (1, r, id))
end

function Base.iterate(ffl::DistributedIterator, s)
	i, r, id = s
	isempty(r) && return(nothing)
	v, i, r = fetchresult(i, r)
	if i > 0
		r[i] = remotecall(DataIterators.next, r[i].where, ffl.ifuns[i], id)
	end
	@show v
	println()
	return(v, (i, r, id))
end

cyclicinc(i, n) = i == n ? 1 : i + 1

function fetchresult(i, r)
	while !isempty(r)
		i = findready(i, r)
		@show r
		v = fetch(r[i])
		@show r
		@show v
		if v == nothing
			r = r[setdiff(1:length(r), i)]
			i = i > length(r) ? length(r) : i
		else 
			return(v, cyclicinc(i, length(r)), r)
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