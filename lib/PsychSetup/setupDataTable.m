function data = setupDataTable( expParams, input, domEye, expt )
%setupDataTable setup data table for this participant.

rng('shuffle');
scurr = rng; % set up and seed the randon number generator

data = table;
data.subject = repelem(input.subject, expParams.nTrials)';
data.seed = repelem(scurr.Seed, expParams.nTrials)';
data.trial = (1:expParams.nTrials)';
data.tStart = NaN(expParams.nTrials,1);
data.tEnd = NaN(expParams.nTrials,1);
data.exitFlag = repelem({'EMPTY'},expParams.nTrials)';
% jitter is in ticks, which translates to the hertz of mondrians
data.jitter = randi([0,expParams.mondrianHertz^-1 * 120],[expParams.nTrials,1]);

% arrow points right and left on half of all trials each
data.response = cell(expParams.nTrials,1);
data.rt = NaN(expParams.nTrials,1);


switch expt
    case 'occularDominance'
        data.trialCode = Shuffle(repelem({'Right','Left'},expParams.nTrials/2))';
        
        % arrow points left(1) and right(2) on half of all trials each
        data.correctDirection = (data.trialCode==1 | data.trialCode==2)+1;
        
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        if strcmp(domEye, {'Right'})
            data.eyes(strcmp(data.tType,{'CFS'})) = {[1,0]};
        else
            data.eyes(strcmp(data.tType,{'CFS'})) = {[0,1]}';
        end

        
        
        % Half of trials present arrow to left(0), half to right(1) eye
        data.rightEye = (data.trialCode==3 | data.trialCode==4);
        
        % on one third of trials, draw to both eyes
        data.bothEyes = (data.trialCode==5);
                
    case 'CFSRecall'
        data.item = randperm(expParams.nTrials)';
        % data.block = repelem(1:10, expParams.nTrials/10)';
        
        % trial type key
        data.tType = Shuffle([repelem({'CFS'},expParams.nTrials*(1/3)),...
            repelem({'BINOCULAR'},expParams.nTrials*(1/3)), ...
            repelem({'NOT STUDIED'},expParams.nTrials*(1/3))])';
        
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        if strcmp(domEye, {'Right'})
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

end

