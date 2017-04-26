function expParams = setupExpParams( refreshRate, debugLevel, expt )
%setupDebug setup values specific to debug levels

% some defaults
expParams.screen_scale = []; % show at full screen
expParams.respDelay = 0;

%% Set general parameters that change based on debug level only
switch debugLevel
    
    case 0
        % Level 0: normal experiment
        expParams.mondrianHertz = refreshRate/10;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.maxCFS = 30; % max duration until arrows are at full contrast
end
%% Set parameters that change based on experiment (+ debuglevel)
switch expt
    case 'occularDominance'
        expParams.nTrials = 20;
        expParams.maxAlpha = .6;
        expParams.alpha.mondrian = linspace(1,1,expParams.maxAlpha*100);
        expParams.alpha.tex = linspace(0,expParams.maxAlpha,expParams.maxAlpha*100);
        
        expParams.nStudyReps = 1;
    case 'staircase'
        expParams.nTrials = 20;
        expParams.alpha.mondrian = 1;
        expParams.nStudyReps = 1;
        
    case 'CFSRecall'
        expParams.nStudyReps = 2;
        expParams.noiseHertz = refreshRate/10;
        expParams.alpha.mondrian = 1;
        
        switch debugLevel
            case 0
                expParams.maxCFS = 4;
                expParams.maxCFS_noise = 10;
                expParams.nTrials = 96; %208 objects in total
                expParams.nLists = expParams.nTrials/12;
                expParams.nStudyReps = 2;
            case 1
                expParams.maxCFS = 4;
                expParams.maxCFS_noise = 10;
                expParams.nTrials = 6;
                expParams.nLists = 2;
                expParams.nStudyReps = 2;
        end
        expParams.nTrialsPerList = expParams.nTrials / expParams.nLists;
        expParams.nCondPerList = expParams.nTrialsPerList / 3;
        expParams.nTicks_noise = ceil(expParams.maxCFS_noise * expParams.mondrianHertz);

end


%% defaults that need calculating
expParams.nTicks = ceil(expParams.maxCFS * expParams.mondrianHertz);


end
