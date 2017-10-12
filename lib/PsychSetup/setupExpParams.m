function expParams = setupExpParams( refreshRate, debugLevel, expt )
%setupDebug setup values specific to debug levels

% some defaults
expParams.screen_scale = []; % show at full screen
expParams.respDelay = 0;

hz = 10;

%% Set general parameters that change based on debug level only
switch debugLevel
    case 0
        % Level 0: normal experiment
        expParams.mondrianHertz = refreshRate/hz;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.maxCFS = 30; % max duration until arrows are at full contrast
    case 1
        expParams.mondrianHertz = refreshRate/hz;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.maxCFS = 30; % max duration until arrows are at full contrast
end
%% Set parameters that change based on experiment (+ debuglevel)
switch expt
    case 'occularDominance'
        expParams.nTrials = 40;
        expParams.maxAlpha = .6;
        expParams.alpha.mondrian = linspace(1,1,expParams.maxAlpha*100);
        expParams.alpha.tex = linspace(0,expParams.maxAlpha,expParams.maxAlpha*100);
        expParams.noiseFadeInDur = 4;
        expParams.nStudyReps = 1;
        
    case {'CFSgonogo', 'practice'}
        expParams.noiseHertz = refreshRate/hz;
        expParams.alpha.mondrian = 1;
        
        switch expt
            case 'practice'
                expParams.nTrials = 12;
                expParams.nLists = expParams.nTrials/12;
                expParams.nStudyReps = 1;
                
            otherwise
                switch debugLevel
                    case 0
                        expParams.nTrials = 120;
                        expParams.nLists = expParams.nTrials/12;
                        expParams.nStudyReps = 2;
                    case 1
                        expParams.nTrials = 12;
                        expParams.nLists = expParams.nTrials/12;
                        expParams.nStudyReps = 1;
                end
                
        end
        switch debugLevel
            case 0
                expParams.maxCFS = 30;
                expParams.maxCFS_bino = 5;
                expParams.nTicks_bino = ceil(expParams.maxCFS_bino * expParams.mondrianHertz);
                
                expParams.maxCFS_noise = 5;
                expParams.noiseFadeInDur = 2.5;
            case 1
                expParams.maxCFS = .3;
                expParams.maxCFS_bino = .3;
                expParams.nTicks_bino = ceil(expParams.maxCFS_bino * expParams.mondrianHertz);
                
                expParams.maxCFS_noise = 3;
                expParams.noiseFadeInDur = .1;
        end
        
        expParams.nTrialsPerList = expParams.nTrials / expParams.nLists;
        expParams.nCondPerList = expParams.nTrialsPerList / 3;
        expParams.nTicks_noise = ceil(expParams.maxCFS_noise * expParams.mondrianHertz);
end

%% defaults that need calculating
expParams.nTicks = ceil(expParams.maxCFS * expParams.mondrianHertz);


end
