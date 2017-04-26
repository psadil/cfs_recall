function tInfo = setupTInfo( expParams, debugLevel )
%setupDebug setup values specific to debug levels

% first tick is always initial empty flip
nTicks = expParams.nTicks + 1;

tInfo = table;
tInfo.trial = repelem(1:expParams.nTrials, nTicks)';
tInfo.tick = repmat(1:nTicks, [expParams.nStudyReps, expParams.nTrials])';
switch debugLevel
    otherwise
        tInfo.vbl = NaN(expParams.nTrials*nTicks,expParams.nStudyReps);
        tInfo.missed = NaN(expParams.nTrials*nTicks,expParams.nStudyReps);
end



end
