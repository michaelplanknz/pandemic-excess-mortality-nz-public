# Random rounding function 
rrn <- function(x, n=3, seed){ ## The default rounding base (n) is 3, but user can supply their own base when calling function
  if (!missing(seed)) set.seed(seed)
  
  rr <- function(x, n){
    if (is.na(x)) return(0)
    if ((x%%n)==0) return(x)
    res <- abs(x)
    lo <- (res%/%n) * n
    if ((runif(1) * n) <= res%%n) res <- lo + n
    else res <- lo
    return(ifelse(x<0, (-1)*res, res))
  }
  
  isint <- function(x){
    x <- x[!is.na(x)]
    sum(as.integer(x)==x)==length(x)
  }
  
  if (class(x) %in% c("numeric", "integer")){
    if(isint(x)) return(sapply(x, rr, n))
    else return(x)
  }
  
  for (i in 1:ncol(x))
  {
    if (class(x[,i]) %in% c("numeric", "integer") & isint(x[,i])) x[,i] <- sapply(x[,i], rr, n)
  }
  x
}
