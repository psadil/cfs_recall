
# Almost all of the following comes from Hsu and Chen (2009)



meanRT <- function(intensity, R=150, K=220, beta=0.3){
  out <- R + K*(exp(intensity)^(-beta))
  return(out)
}

weibullParams <- function(mu, sd){
  shape <- (sd/mu)^-1.086
  scale <- mu/(gamma(1+1/shape))
  
  out <- list(scale=scale,shape=shape)
  return(out)
}

Yn2 <- function(latency, tau=3000){
  dplyr::if_else(latency>tau, 0, 1)
}

Yn9 <- function(latency, tau=3000){
  dplyr::if_else(runif(1)>FAdist::dweibull3(latency,intensity), 0, 1)
}


# Define parameters

SA <- function(X, n, latency, tau=3000, quant=.794, delta=2){
  # tau <- 3000 # desired msec delay
  # quant <- .794 # Desired quantile (quant proportion of trials will be greater than tau)
  # delta <- 2 # fixed amount to change 
  # X <- intensity 
  
  # returns intensity for trial n+1
  
    Xn1 <- X - (delta/n)*(Yn2(latency=latency, tau=tau) - quant)

  return(Xn1)
}



simTrials <- function(tau=3000, quant = .794, N=1000, x1=1, ratio = .22, R=150, K=220, beta=0.3){
  
  rt <- rep(NA, times=N)
  X <- rep(NA, times=N)
  avgRT <- rep(NA, times=N)
  for (n in 1:N){
    if(n==1){
      X[n] <- x1
    } else{
      X[n] <- SA(X=X[n-1], n=n, latency=rt[n-1], tau=tau, quant=quant)
    }
    avgRT[n] <- meanRT(intensity = X[n], R=R, K=K, beta=beta)
    weiParams <- weibullParams(mu=avgRT[n], sd = avgRT[n]*ratio)
    
    rt[n] <- FAdist::rweibull3(n=1, shape = weiParams$shape, scale = weiParams$scale, thres = R)
  }
  out <- list(rt=rt,X=X,avgRT=avgRT)
  return(out)
}

test <- simTrials(N=100, x1=-13)
