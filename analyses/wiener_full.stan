// generated with brms 1.10.2
functions { 

  /* Wiener diffusion log-PDF for a single response
   * Args: 
   *   y: reaction time data
   *   dec: decision data (0 or 1)
   *   alpha: boundary separation parameter > 0
   *   tau: non-decision time parameter > 0
   *   beta: initial bias parameter in [0, 1]
   *   delta: drift rate parameter
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
   real wiener_diffusion_lpdf(real y, int dec, real alpha, 
                              real tau, real beta, real delta) { 
     if (dec == 1) {
       return wiener_lpdf(y | alpha, tau, beta, delta);
     } else {
       return wiener_lpdf(y | alpha, tau, 1 - beta, - delta);
     }
   }
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  real<lower=0> bs;  // boundary separation parameter 
  int<lower=1> K_ndt;  // number of population-level effects 
  matrix[N, K_ndt] X_ndt;  // population-level design matrix 
  real<lower=0,upper=1> bias;  // initial bias parameter 
  // data for group-level effects of ID 1 
  int<lower=1> J_1[N]; 
  int<lower=1> N_1; 
  int<lower=1> M_1; 
  vector[N] Z_1_1; 
  int<lower=0,upper=1> dec[N];  // decisions 
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  real min_Y = min(Y); 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  int Kc_ndt = K_ndt - 1; 
  matrix[N, K_ndt - 1] Xc_ndt;  // centered version of X_ndt 
  vector[K_ndt - 1] means_X_ndt;  // column means of X_ndt before centering 
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
  for (i in 2:K_ndt) { 
    means_X_ndt[i - 1] = mean(X_ndt[, i]); 
    Xc_ndt[, i - 1] = X_ndt[, i] - means_X_ndt[i - 1]; 
  } 
} 
parameters { 
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  vector[Kc_ndt] b_ndt;  // population-level effects 
  real temp_ndt_Intercept;  // temporary intercept 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations 
  vector[N_1] z_1[M_1];  // unscaled group-level effects 
} 
transformed parameters { 
  // group-level effects 
  vector[N_1] r_1_1 = sd_1[1] * (z_1[1]); 
} 
model { 
  vector[N] mu = Xc * b + temp_Intercept; 
  vector[N] ndt = Xc_ndt * b_ndt + temp_ndt_Intercept; 
  for (n in 1:N) { 
    mu[n] = mu[n] + (r_1_1[J_1[n]]) * Z_1_1[n]; 
    ndt[n] = exp(ndt[n]); 
  } 
  // priors including all constants 
  target += student_t_lpdf(b | 3, 0, 1); 
  target += student_t_lpdf(temp_Intercept | 3, 0, 1); 
  target += normal_lpdf(b_ndt | -2, 1); 
  target += normal_lpdf(temp_ndt_Intercept | -2, 1); 
  target += gamma_lpdf(sd_1 | 2, 1); 
  target += normal_lpdf(z_1[1] | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    for (n in 1:N) { 
      target += wiener_diffusion_lpdf(Y[n] | dec[n], bs, ndt[n], bias, mu[n]); 
    } 
  } 
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
  // actual population-level intercept 
  real b_ndt_Intercept = temp_ndt_Intercept - dot_product(means_X_ndt, b_ndt); 
} 