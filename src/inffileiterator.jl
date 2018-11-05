"""
  struct InfiniteFileIterator{A,B}
    loadfun::A
    files::B
    nobs::Int
  end

  cycles over files and outputs batches of size nobs.
  If files provides less than `nobs` samples, then less than `nobs` samples are provided. 
  If all files are iterated during first loading, result is cached and subsequent iterations just sample
  instead of loading.
"""
struct InfiniteFileIterator{A,B}
  loadfun::A
  files::B
  nobs::Int
end

function Base.iterate(ffl::InfiniteFileIterator)
  isempty(ffl.files) && return(nothing)
  x, i = loadnextbatch_i(ffl.loadfun, ffl.files, ffl.nobs , nothing, 1)
  i = (i == 1) ? 0 : i
  iterate(ffl, (x, i))
end

function Base.iterate(ffl::InfiniteFileIterator, state)
  if state[2] == 0
    x, i = state
    return(sampledata(x, ffl.nobs), (x, 0))
  else
    x, i = loadnextbatch_i(ffl.loadfun, ffl.files, ffl.nobs, state...)[1:2]
    if nobs(x) == 0
      return(nothing)
    else
      x, xx = splitdata(x, ffl.nobs)
      return(x, (xx, i))
    end
  end
end

function loadnextbatch_i(loadfun, files, n, x, i)
  istart = i
  while (x == nothing) || (nobs(x) < n)
    try 
      xx =  loadfun(files[i])
      x = catobs(x, xx)
    catch me 
      @warn "error while loading $(files[i])"
      println(me)
    end
    i += 1
    i = i > length(files) ? 1 : i
    i == istart && return (x, i)
  end 
  x, i
end

Base.IteratorSize(s::InfiniteFileIterator) = Base.SizeUnknown()