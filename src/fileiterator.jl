"""
  struct FileIterator{A, B, F}
    loadfun::A
    files::B
    nobs::Int 
  end


  Iterate over all files and return batches of size nobs. 
"""
struct FileIterator{A,B}
  loadfun::A
  files::B
  nobs::Int 
end

function Base.iterate(ffl::FileIterator, state = (nothing, 1))
  x, i = loadnextbatch(ffl.loadfun, ffl.files, ffl.nobs, state...)[1:2]
  x == nothing && return(nothing)
  nobs(x) == 0 && return(nothing)
  x, xx = splitdata(x, ffl.nobs)
  x, (xx, i)
end


"""
  loadnextbatch(loadfun, files, n, x, i)

  load batch of data of size `n` using `loadfun` and the list of `files` with position `i`

"""
function loadnextbatch(loadfun, files, n, x, i)
  while (i <=length(files)) && ( x == nothing || nobs(x) < n)
    try 
      xx = loadfun(files[i])
      xx == nothing && return(x, i)
      x = filteredcat(x, xx)
    catch me 
      @warn "error while loading $(files[i])"
      println(me)
    end
    i += 1
  end 
  x, i
end


Base.IteratorSize(s::FileIterator) = Base.SizeUnknown()