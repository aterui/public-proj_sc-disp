dtnorm <- function(x, mu = 0, tau, nu){
  ( gamma( (nu + 1)/2 )/gamma(nu/2) ) * sqrt( tau/(nu*pi) ) * (1 + (tau/nu)*(x - mu)^2 )^(-(nu + 1)/2)
}