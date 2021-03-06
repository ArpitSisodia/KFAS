#'Multivariate Innovations
#'
#'Function \code{mvInnovations} computes the multivariate versions of one 
#'step-ahead prediction errors and their variances using the output of \code{\link{KFS}}.
#'@export
#'@param x Object of class \code{KFS}.
#'@return 
#'\item{v}{Multivariate prediction errors \eqn{v_{t} = y_{t} - Z_{t}a_{t}
#'}{v[t,i] = y[t] - Z[t]a[t]}}
#'\item{F}{Prediction error variances \eqn{Var(v_{t})}{Var(v[t])}. }
#'\item{Finf}{Diffuse part of \eqn{F_t}{F[t]}.}
#'@examples
#'
#' # Compute the filtered estimates based on the KFS output
#' 
#' filtered <- function(x) {
#'   innov <- mvInnovations(x)
#'   att <- window(x$a, end = end(x$a) - 1)
#'   tvz <- attr(x$model,"tv")[1]
#'   
#'   for (i in 1:nrow(att)) {
#'     att[i,] <- att[i,] + 
#'       x$P[,,i] %*% 
#'       t(solve(innov$F[,,i], x$model$Z[, , tvz * (i - 1) + 1, drop = FALSE])) %*%
#'       innov$v[i, ]
#'   }
#'   att
#' }
mvInnovations <- function(x){
  
  # Compute the multivariate versions of one-step-ahead prediction errors and variances
  # Used in rstandard.KFS
  if(any(x$model$distribution!="gaussian"))
    stop("Function is only compatible with fully Gaussian models.")
  if(!("a" %in% names(x)))
    stop("Function needs filtered estimates of states and their covariances.")
  out<-.Fortran(fmvfilter, NAOK = TRUE, attr(x$model, "tv")[1], 
                x$model$Z, attr(x$model, "p"), attr(x$model, "m"), attr(x$model, "n"),
                x$d, x$a[1:attr(x$model, "n"),], x$P[,,1:attr(x$model, "n")], 
                x$Pinf[,,1:x$d], v=x$model$y, 
                F=array(x$model$H,c(attr(x$model, "p"),attr(x$model, "p"),attr(x$model, "n"))),
                Finf=array(0,c(attr(x$model, "p"),attr(x$model, "p"),x$d)))
  out[c("v","F","Finf")]
}
