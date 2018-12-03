Mill.catobs(::Nothing, x) = x
Mill.catobs(x, ::Nothing) = x

"""
  (y, yy) = splitdata(x, n)

  split data such that `y` contains `n` samples and `yy` contains the rest. 
  If `x` does not contain enough samples, `y` will contain `nobs(x)` samples. 
"""
function splitdata(x, n)
  j = min(nobs(x), n)
  idx = 1:j
  cidx = j+1:nobs(x)
  return(getobs(x,idx), getobs(x, cidx))
end

splitdata(::Nothing, n) = (nothing, nothing)

"""
  y = sampledata(x, n)

  return random subset of `x` with `n` samples. If `x` has less than `n` samples, all samples are returned (shallow copy).
"""
function sampledata(x, n)
  if nobs(x) < n
    return(x)
  else
    getobs(x, sample(1:nobs(x), n, replace = false))
  end
end