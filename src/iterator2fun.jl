mutable struct Iterator2Fun{I}
  i::I
  s::Any
end

Iterator2Fun(i) = Iterator2Fun(i, nothing)

function (s::Iterator2Fun)()
  r = (s.s == nothing) ? iterate(s.i) : iterate(s.i, s.s)
  r == nothing && return(nothing)
  x, s.s = r
  x
end