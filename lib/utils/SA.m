function Xn1 = SA( X, trial, latency, sa, expParams)
%SA Stochastic Adaptation algorithm for updating value

sa.values.Yn(trial) = Yn(latency, sa.params.tau);

[~, nRuns] = RunLength(sa.values.Yn(1:trial));
sa.values.nShifts(trial) = length(nRuns);

if trial < 3
    Xn1 = X - (sa.params.delta/trial)*(sa.values.Yn(trial) - sa.params.quant);
else
    Xn1 = X - (sa.params.delta/(2+sa.values.nShifts(trial)))*...
        (sa.values.Yn(trial) - sa.params.quant);
end

end

%%
function Y = Yn(latency, tau)
if latency > tau
    Y=0;
else
    Y=1;
end
end

