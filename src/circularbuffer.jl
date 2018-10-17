struct CircularBuffer{I}
	i::I
	n::Int
end 


function Base.iterate(iter::CircularBuffer) 
	nextitem = iterate(iter.i)
	nextitem == nothing && return(nothing)
	x, s = nextitem
	buffer = (x,)
	(x, (buffer, 2, s))
end

function addtobuffer(buffer, n, x, ins)
	buffer = length(buffer) >= n ? buffer[1:end - 1] : buffer
	buffer = (x, buffer...)
	(buffer, ins)
end

function Base.iterate(iter::CircularBuffer, s)
	buffer, bi, ins = s
	length(buffer) == 0 && return(nothing)
	if bi > length(buffer)
		nextitem = ins == nothing ? nothing : iterate(iter.i, ins)
		buffer, ins = (nextitem == nothing) ? (buffer, nothing) : addtobuffer(buffer, iter.n, nextitem...)
		x = buffer[1]
		buffer = ins == nothing ? buffer[1:end - 1] : buffer
		return(x, (buffer[1:length(buffer)], 2, ins))
	else 
		return(buffer[bi], (buffer, bi + 1, ins))
	end
end

Base.IteratorSize(s::CircularBuffer) = Base.SizeUnknown()
