function tInfo = setupTInfo( expParams, debugLevel, expt )
%setupDebug setup values specific to debug levels

% first tick is always initial empty flip
switch expt
    case 'CFSRecall'
        nTicks = expParams.nTicks_bino + 1;
    otherwise
        nTicks = expParams.nTicks + 1;
end

tInfo = table;
tInfo.trial = repelem(1:expParams.nTrials, nTicks)';
tInfo.tick = repmat(1:nTicks, [expParams.nStudyReps, expParams.nTrials])';
switch debugLevel
    otherwise
        tInfo.vbl = NaN(expParams.nTrials*nTicks,expParams.nStudyReps);
        tInfo.missed = NaN(expParams.nTrials*nTicks,expParams.nStudyReps);
end



end
