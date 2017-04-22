function [ data ] = setupDataTable( expParams, input, demographics )
%setupDataTable setup data table for this participant. 

rng('shuffle');
scurr = rng; % set up and seed the randon number generator

data = table;
data.subject = repelem(input.subject, expParams.nTrials)';
data.seed = repelem(scurr.Seed, expParams.nTrials)';
data.dominantEye = repelem({input.dominantEye}, expParams.nTrials)';
data.sex = repelem(demographics(1), expParams.nTrials)';
data.ethnicity = repelem(demographics(2), expParams.nTrials)';
data.race = repelem(demographics(3), expParams.nTrials)';
data.trial = (1:expParams.nTrials)';
data.item = randperm(expParams.nTrials)';
% data.block = repelem(1:10, expParams.nTrials/10)';
data.tStart = NaN(expParams.nTrials,1);
data.tEnd = NaN(expParams.nTrials,1);
data.exitFlag = repelem({'EMPTY'},expParams.nTrials)';

% jitter is in ticks, which translates to the hertz of mondrians
data.jitter = randi([0,expParams.mondrianHertz^-1 * 120],[expParams.nTrials,1]);

% trial type key
data.tType = Shuffle([repelem({'CFS'},expParams.nTrials*(4/5)),...
    repelem({'NULL'},expParams.nTrials*(1/5))])';

data.eyes = repelem({[0,0]},expParams.nTrials)';
if strcmp(input.dominantEye, {'Right'})
    data.eyes(strcmp(data.tType,{'CFS'})) = {[1,0]};
else
    data.eyes(strcmp(data.tType,{'CFS'})) = {[0,1]}';
end

data.transparency = NaN(expParams.nTrials,1);
data.pas = cell(expParams.nTrials,1);
data.response = cell(expParams.nTrials,1);
data.rt = NaN(expParams.nTrials,1);
data.RoboRT = NaN(expParams.nTrials,1);
data.meanRoboRT = NaN(expParams.nTrials,1);

end

