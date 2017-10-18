function sa = setupSAParams( expParams, expt, sa )

% Almost all of the following comes from Hsu and Chen (2009)

% defaults regardless of debug level
sa.params.quant = .8; % desired percentile of responses
sa.params.tau = 3;
sa.params.x1 = .5; % initial maximum transparency
sa.params.ratio = 0.22; % ratio of mean to sd in weibull
sa.params.R = 500;  % location of weibull
sa.params.K = 1500;
sa.params.beta = 0.3;

sa.params.delta = 2.5; % initial amount by which to change maximum transparency


switch expt
    case 'practice'
        sa.values.nShifts = NaN(expParams.nTrials,1);
        sa.values.Yn = NaN(expParams.nTrials,1);
        sa.values.trial = 1;
        
        sa.results.transparency = NaN(expParams.nTrials,1);
        sa.results.exitFlag = cell(expParams.nTrials,1);
        sa.results.rt = NaN(expParams.nTrials,1);
        
    case {'CFSRecall', 'CFSgonogo'}
        sa.values.nShifts(isnan(sa.values.nShifts)) = [];
        sa.values.nShifts = [sa.values.nShifts; NaN(expParams.nTrials*expParams.nStudyReps,1)];
        sa.values.Yn(isnan(sa.values.Yn)) = [];
        sa.values.Yn = [sa.values.Yn; NaN(expParams.nTrials*expParams.nStudyReps,1)];
        
        sa.results.rt(isnan(sa.results.rt)) = [];
        sa.results.rt = [sa.results.rt; NaN(expParams.nTrials*expParams.nStudyReps,1)];
        sa.results.exitFlag(isempty(sa.results.exitFlag)) = [];
        sa.results.exitFlag = [sa.results.exitFlag; cell(expParams.nTrials,1)];
        sa.results.transparency(isnan(sa.results.transparency)) = [];
        sa.results.transparency = [sa.results.transparency; NaN(expParams.nTrials*expParams.nStudyReps,1)];
        
end

end
