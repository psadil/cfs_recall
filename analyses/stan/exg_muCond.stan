// generated with brms 2.1.0
functions { 
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  int<lower=1> K_sigma;  // number of population-level effects 
  matrix[N, K_sigma] X_sigma;  // population-level design matrix 
  int<lower=1> K_beta;  // number of population-level effects 
  matrix[N, K_beta] X_beta;  // population-level design matrix 
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
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  int Kc_sigma = K_sigma - 1; 
  matrix[N, K_sigma - 1] Xc_sigma;  // centered version of X_sigma 
  vector[K_sigma - 1] means_X_sigma;  // column means of X_sigma before centering 
  int Kc_beta = K_beta - 1; 
  matrix[N, K_beta - 1] Xc_beta;  // centered version of X_beta 
  vector[K_beta - 1] means_X_beta;  // column means of X_beta before centering 
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
  for (i in 2:K_sigma) { 
    means_X_sigma[i - 1] = mean(X_sigma[, i]); 
    Xc_sigma[, i - 1] = X_sigma[, i] - means_X_sigma[i - 1]; 
  } 
  for (i in 2:K_beta) { 
    means_X_beta[i - 1] = mean(X_beta[, i]); 
    Xc_beta[, i - 1] = X_beta[, i] - means_X_beta[i - 1]; 
  } 
} 
parameters { 
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  vector[Kc_sigma] b_sigma;  // population-level effects 
  real temp_sigma_Intercept;  // temporary intercept 
  vector[Kc_beta] b_beta;  // population-level effects 
  real temp_beta_Intercept;  // temporary intercept 
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
  vector[N] sigma = Xc_sigma * b_sigma + temp_sigma_Intercept; 
  vector[N] beta = Xc_beta * b_beta + temp_beta_Intercept; 
  for (n in 1:N) { 
    mu[n] = mu[n] + (r_1_1[J_1[n]]) * Z_1_1[n] + (r_2_1[J_2[n]]) * Z_2_1[n]; 
    sigma[n] = exp(sigma[n]); 
    beta[n] = exp(beta[n]); 
  } 
  // priors including all constants 
  target += student_t_lpdf(b | 3, 0, 1); 
  target += student_t_lpdf(temp_Intercept | 3, 0, 1); 
  target += student_t_lpdf(b_sigma | 3, 0, 1); 
  target += student_t_lpdf(temp_sigma_Intercept | 3, 0, 1); 
  target += student_t_lpdf(b_beta | 3, 0, 1); 
  target += student_t_lpdf(temp_beta_Intercept | 3, 0, 1); 
  target += gamma_lpdf(sd_1 | 2, 1); 
  target += normal_lpdf(z_1[1] | 0, 1); 
  target += gamma_lpdf(sd_2 | 2, 1); 
  target += normal_lpdf(z_2[1] | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += exp_mod_normal_lpdf(Y | mu, sigma, inv(beta)); 
  } 
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
  // actual population-level intercept 
  real b_sigma_Intercept = temp_sigma_Intercept - dot_product(means_X_sigma, b_sigma); 
  // actual population-level intercept 
  real b_beta_Intercept = temp_beta_Intercept - dot_product(means_X_beta, b_beta); 
} 
