// generated with brms 2.1.0
functions { 

  /* inverse Gaussian log-PDF for a single response (for data only) 
   * Copyright Stan Development Team 2015 
   * Args: 
   *   y: the response value 
   *   mu: positive mean parameter 
   *   shape: positive shape parameter 
   *   log_y: precomputed log(y) 
   *   sqrt_y: precomputed sqrt(y) 
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
   real inv_gaussian_lpdf(real y, real mu, real shape,  
                          real log_y, real sqrt_y) { 
     return 0.5 * log(shape / (2 * pi())) -  
            1.5 * log_y - 
            0.5 * shape * square((y - mu) / (mu * sqrt_y)); 
   }
  /* vectorized inverse Gaussian log-PDF (for data only) 
   * Copyright Stan Development Team 2015 
   * Args: 
   *   y: response vector 
   *   mu: positive mean parameter vector 
   *   shape: positive shape parameter 
   *   sum_log_y: precomputed sum of log(y) 
   *   sqrt_y: precomputed sqrt(y) 
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
   real inv_gaussian_vector_lpdf(vector y, vector mu, real shape,  
                                 real sum_log_y, vector sqrt_y) { 
     return 0.5 * rows(y) * log(shape / (2 * pi())) -  
            1.5 * sum_log_y - 
            0.5 * shape * dot_self((y - mu) ./ (mu .* sqrt_y)); 
   }
  /* inverse Gaussian log-CDF for a single quantile 
   * Args: 
   *   y: a quantile 
   *   mu: positive mean parameter 
   *   shape: positive shape parameter 
   *   log_y: ignored (cdf and pdf should have the same args) 
   *   sqrt_y: precomputed sqrt(y) 
   * Returns: 
   *   log(P(Y <= y)) 
   */ 
   real inv_gaussian_lcdf(real y, real mu, real shape,  
                          real log_y, real sqrt_y) { 
     return log(Phi(sqrt(shape) / sqrt_y * (y / mu - 1)) + 
                exp(2 * shape / mu) * Phi(-sqrt(shape) / sqrt_y * (y / mu + 1))); 
   }
  /* inverse Gaussian log-CCDF for a single quantile 
   * Args: 
   *   y: a quantile 
   *   mu: positive mean parameter 
   *   shape: positive shape parameter 
   *   log_y: ignored (ccdf and pdf should have the same args) 
   *   sqrt_y: precomputed sqrt(y) 
   * Returns: 
   *   log(P(Y > y)) 
   */ 
   real inv_gaussian_lccdf(real y, real mu, real shape, 
                           real log_y, real sqrt_y) { 
     return log(1 - Phi(sqrt(shape) / sqrt_y * (y / mu - 1)) - 
                  exp(2 * shape / mu) * Phi(-sqrt(shape) / sqrt_y * (y / mu + 1)));
   }
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  // data for group-level effects of ID 1 
  int<lower=1> J_1[N]; 
  int<lower=1> N_1; 
  int<lower=1> M_1; 
  vector[N] Z_1_1; 
  // data for group-level effects of ID 2 
  int<lower=1> J_2[N]; 
  int<lower=1> N_2; 
  int<lower=1> M_2; 
  vector[N] Z_2_1; 
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  vector[N] sqrt_Y;
  vector[N] log_Y;
  real sum_log_Y;
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  for (n in 1:N) {
    sqrt_Y[n] = sqrt(Y[n]);
    log_Y[n] = log(Y[n]);
  }
  sum_log_Y = sum(log_Y);
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
} 
parameters { 
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  real<lower=0> shape;  // shape parameter 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations 
  vector[N_1] z_1[M_1];  // unscaled group-level effects 
  vector<lower=0>[M_2] sd_2;  // group-level standard deviations 
  vector[N_2] z_2[M_2];  // unscaled group-level effects 
} 
transformed parameters { 
  // group-level effects 
  vector[N_1] r_1_1 = sd_1[1] * (z_1[1]); 
  // group-level effects 
  vector[N_2] r_2_1 = sd_2[1] * (z_2[1]); 
} 
model { 
  vector[N] mu = Xc * b + temp_Intercept; 
  for (n in 1:N) { 
    mu[n] = mu[n] + (r_1_1[J_1[n]]) * Z_1_1[n] + (r_2_1[J_2[n]]) * Z_2_1[n]; 
  } 
  // priors including all constants 
  target += student_t_lpdf(temp_Intercept | 3, 2, 10); 
  target += gamma_lpdf(shape | 0.01, 0.01); 
  target += student_t_lpdf(sd_1 | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  target += normal_lpdf(z_1[1] | 0, 1); 
  target += student_t_lpdf(sd_2 | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  target += normal_lpdf(z_2[1] | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += inv_gaussian_vector_lpdf(Y | mu, shape, sum_log_Y, sqrt_Y); 
  } 
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
} 
