function expParams = setupExpParams( refreshRate, debugLevel )
%setupDebug setup values specific to debug levels

% some defaults
expParams.screen_scale = []; % show at full screen
expParams.stereoMode = 1;
expParams.respDelay = 0;

%% Set parameters that change based on debug level
switch debugLevel
    
    case 0
        % Level 0: normal experiment
        expParams.mondrianHertz = refreshRate/10;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.nTrials = 100;
        expParams.maxCFS = 30; % max duration until arrows are at full contrast
    case 1
        % Level 1: Run through all trials giving correct answers. Speed at
        % anticipanted subject speed
        expParams.mondrianHertz = refreshRate/8;
        expParams.iti = 1;
        expParams.nTrials = 30;
        expParams.maxCFS = 30; % maximum number of ticks
        expParams.respDelay = 10*8;
    case 2
        % Level 2: Like 1, but super fast
        expParams.mondrianHertz = refreshRate/10;
        expParams.iti = .1;
        expParams.nTrials = 150;
        expParams.maxCFS = 2; % maximum number of ticks
        expParams.respDelay = 2;
end


%% defaults that need calculating
expParams.nTicks = ceil(expParams.maxCFS * expParams.mondrianHertz);

expParams.alpha.mondrian = linspace(1,1,expParams.nTicks);


end
