catobs(::Nothing, x) = x
catobs(x, ::Nothing) = x
catobs(x::AbstractArray{T,N}...) where {N,T}= cat(x..., dims = N)
catobs(x...) = cat(x...)


"""
  (y, yy) = splitdata(x, n)

  split data such that `y` contains `n` samples and `yy` contains the rest. 
  If `x` does not contain enough samples, `y` will contain `nobs(x)` samples. 
"""
function splitdata(x, n)
  j = min(nobs(x), n)
  return(getobs(x,1:j), getobs(x, j+1:nobs(x)))
end

splitdata(::Nothing, n) = (nothing, nothing)

"""
  y = sampledata(x, n)

  return random subset of `x` with `n` samples. If `x` has less than `n` samples, all samples are returned (shallow copy).
"""
function sampledata(x, n)
  if nobs(x) == 0
    return(nothing)
  elseif nobs(x) < n
    return(x)
  else
    getobs(x, sample(1:nobs(x), n))
  end
end