function expParams = setupExpParams( refreshRate, debugLevel, expt )
%setupDebug setup values specific to debug levels

% some defaults
expParams.screen_scale = []; % show at full screen
expParams.respDelay = 0;

%% Set parameters that change based on debug level
switch debugLevel
    
    case 0
        % Level 0: normal experiment
        expParams.mondrianHertz = refreshRate/10;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.maxCFS = 30; % max duration until arrows are at full contrast
end
%% Set parameters that change based on experiment
switch expt
    case 'occularDominance'
        expParams.nTrials = 20;
        
    case 'staircase'
        expParams.nTrials = 10;
        
    case 'CFSRecall'
        expParams.nTrials = 10;
        expParams.nLists = 2;
        expParams.nStudyReps = 2;
        expParams.nTrialsPerList = expParams.nTrials_study / expParams.nLists;
end


%% defaults that need calculating
expParams.nTicks = ceil(expParams.maxCFS * expParams.mondrianHertz);

expParams.alpha.mondrian = linspace(1,1,expParams.nTicks);


end
