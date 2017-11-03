// generated with brms 1.10.2
functions { 
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  int<lower=1> K_shape;  // number of population-level effects 
  matrix[N, K_shape] X_shape;  // population-level design matrix 
  // data for group-level effects of ID 1 
  int<lower=1> J_1[N]; 
  int<lower=1> N_1; 
  int<lower=1> M_1; 
  vector[N] Z_1_1; 
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  int Kc_shape = K_shape - 1; 
  matrix[N, K_shape - 1] Xc_shape;  // centered version of X_shape 
  vector[K_shape - 1] means_X_shape;  // column means of X_shape before centering 
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
  for (i in 2:K_shape) { 
    means_X_shape[i - 1] = mean(X_shape[, i]); 
    Xc_shape[, i - 1] = X_shape[, i] - means_X_shape[i - 1]; 
  } 
} 
parameters { 
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  vector[Kc_shape] b_shape;  // population-level effects 
  real temp_shape_Intercept;  // temporary intercept 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations 
  vector[N_1] z_1[M_1];  // unscaled group-level effects 
} 
transformed parameters { 
  // group-level effects 
  vector[N_1] r_1_1 = sd_1[1] * (z_1[1]); 
} 
model { 
  vector[N] mu = Xc * b + temp_Intercept; 
  vector[N] shape = Xc_shape * b_shape + temp_shape_Intercept; 
  for (n in 1:N) { 
    mu[n] = mu[n] + (r_1_1[J_1[n]]) * Z_1_1[n]; 
    shape[n] = exp(shape[n]); 
    mu[n] = exp((mu[n]) / shape[n]); 
  } 
  // priors including all constants 
  target += student_t_lpdf(b | 3, 0, 1); 
  target += student_t_lpdf(temp_Intercept | 3, 0, 1); 
  target += student_t_lpdf(b_shape | 3, 0, 1); 
  target += student_t_lpdf(temp_shape_Intercept | 3, 0, 1); 
  target += gamma_lpdf(sd_1 | 2, 1); 
  target += normal_lpdf(z_1[1] | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += weibull_lpdf(Y | shape, mu); 
  } 
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
  // actual population-level intercept 
  real b_shape_Intercept = temp_shape_Intercept - dot_product(means_X_shape, b_shape); 
} 