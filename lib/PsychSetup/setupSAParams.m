function sa = setupSAParams( expParams, debugLevel )

% Almost all of the following comes from Hsu and Chen (2009)

% defaults regardless of debug level
sa.params.quant = .5; % desired percentile of responses
sa.params.tau = 3;
sa.params.x1 = .5; % initial maximum transparency
sa.params.ratio = 0.22; % ratio of mean to sd in weibull
sa.params.R = 500;  % location of weibull
sa.params.K = 1500; 
sa.params.beta = 0.3;

sa.params.delta = 1.5; % initial amount by which to change maximum transparency

sa.values.nShifts = NaN(expParams.nTrials,1);
sa.values.Yn = NaN(expParams.nTrials,1);
sa.values.trial = 1;

end
