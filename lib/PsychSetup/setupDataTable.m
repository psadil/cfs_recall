function data = setupDataTable( expParams, input, expt, varargin )
%setupDataTable setup data table for this participant.

rng('shuffle');
scurr = rng; % set up and seed the randon number generator

data = table;
data.subject = repelem(input.subject, expParams.nTrials)';
data.seed = repelem(scurr.Seed, expParams.nTrials)';
data.trial = (1:expParams.nTrials)';

data.tStart = repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
data.tEnd = repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
data.exitFlag = repmat(repelem({'EMPTY'},expParams.nStudyReps), [expParams.nTrials,1]);

% jitter is in ticks, which translates to the hertz of mondrians
data.jitter = mat2cell(randi([0,expParams.mondrianHertz^-1 * 120],...
    [expParams.nTrials,expParams.nStudyReps]),repelem(1,expParams.nTrials));

data.response = ...
    repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
data.rt = repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);

switch expt
    case 'occularDominance'
        % jitter is in ticks, which translates to the hertz of mondrians
        data.tType = Shuffle(repelem(1:4,expParams.nTrials/4))';
        
        % arrow points left(1) and right(2) on half of all trials
        data.correctDirection = cell(expParams.nTrials,1);
        data.correctDirection(data.tType == 1 | data.tType==2) = {'\LEFT'};
        data.correctDirection(data.tType == 3 | data.tType==4) = {'\RIGHT'};
        
        % arrow shown to left eye only (codes 2,4) or right eye (1,3)
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        data.eyes(data.tType==2 | data.tType==4) = {[1,0]};
        data.eyes(data.tType==1 | data.tType==3) = {[0,1]};
        
        data.eyePresent = repelem({''},expParams.nTrials)';
        data.eyePresent(data.tType==2 | data.tType==4) = {'left'};
        data.eyePresent(data.tType==1 | data.tType==3) = {'right'};
        
        data.RoboRT = repmat({repelem(3,expParams.nStudyReps)}, [expParams.nTrials,1]);
        
    case 'staircase'
        domEye = varargin{1};
        data.item = randperm(expParams.nTrials)';
        
        % trial type key
        data.tType = Shuffle([repelem({'CFS'},expParams.nTrials*(4/5)),...
            repelem({'CATCH'},expParams.nTrials*(1/5))])';
        
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        if strcmp(domEye, {'Right'})
            data.eyes(strcmp(data.tType,{'CFS'})) = {[1,0]};
        else
            data.eyes(strcmp(data.tType,{'CFS'})) = {[0,1]};
        end
        
        % jitter is in ticks, which translates to the hertz of mondrians
        data.jitter(strcmp(data.tType,'NOT STUDIED')) = {0};
        
        
        data.transparency =...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        data.pas =...
            repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
        data.RoboRT =...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        data.meanRoboRT =...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        
        data.roboBCFS = ...
            repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
        data.roboBCFS(strcmp(data.tType,'CFS')) = {'j'};
        data.roboBCFS(strcmp(data.tType,'CATCH')) = {'f'};
        
    case 'CFSRecall'
        domEye = varargin{1};
        % in the main experiment, we take advantage of how writetable
        % automatically splits non-elemental columns when writing a .csv
        % file. So, every column that contains a vector for first and
        % second study repetition will be split during the saving process
        
        
        pairs = readtable(fullfile(pwd,'stims','expt','stimPairings.csv'));
        names = readtable(fullfile(pwd,'stims','expt','objectNames_2afc.csv'));
        
        % we only want one element in each pair to be studied. If it's seen
        % at study, it should never be seen at test. Similarly, if the
        % bullet is seen at test, it shouldn't also be encountered as a
        % study item.
        tmp = pairs;
        count = 0;
        for item = 1:size(pairs,1)
            if tmp.pair2(tmp.pair2==pairs.pair2(item)) <= (size(pairs,1)/2+count)
                tmp(tmp.pair1==pairs.pair2(item),:) = [];
                count=count+1;
            end
        end
        
        data.item = tmp.pair1(randperm(expParams.nTrials));
        data.pair = NaN(expParams.nTrials,1);
        for trial = 1:expParams.nTrials
            data.pair(trial) = tmp.pair2(tmp.pair1==data.item(trial));
        end
        data.name = names{data.item,1};
        data.list = repelem(1:expParams.nLists, expParams.nTrialsPerList)';
        
        % trial type key
        data.tType = repelem({[]},expParams.nTrials)';
        data.swap = repelem({[]},expParams.nTrials)';
        data.trial_test = NaN(expParams.nTrials,1);
        data.item_test = NaN(expParams.nTrials,1);
        data.pair_test = NaN(expParams.nTrials,1);
        data.tType_test = repelem({[]},expParams.nTrials)';
        data.swap_test = repelem({[]},expParams.nTrials)';
        data.name_test = repelem({[]},expParams.nTrials)';
        for list = 1:expParams.nLists
            data.tType(data.list==list) = Shuffle([repelem({'CFS'},expParams.nTrialsPerList*(1/3)),...
                repelem({'BINOCULAR'},expParams.nTrialsPerList*(1/3)), ...
                repelem({'NOT STUDIED'},expParams.nTrialsPerList*(1/3))])';
            for cond = {'CFS','BINOCULAR','NOT STUDIED'}
                data.swap(data.list==list & strcmp(data.tType,cond)) = ...
                    Shuffle(repelem({'match','mismatch'}, expParams.nCondPerList/2));
            end
            
            data.trial_test(data.list==list) = Shuffle(data.trial(data.list==list));
            data.item_test(data.list==list) = data.item(data.trial_test(data.list==list));
            data.pair_test(data.list==list) = data.pair(data.trial_test(data.list==list));
            data.tType_test(data.list==list) = data.tType(data.trial_test(data.list==list));
            data.swap_test(data.list==list) = data.swap(data.trial_test(data.list==list));
            data.name_test(data.list==list) = data.name(data.trial_test(data.list==list));
        end
        data.roboBCFS = ...
            repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
        data.roboBCFS(strcmp(data.tType,'CFS')) = {'j','j'};
        data.roboBCFS(strcmp(data.tType,'NOT STUDIED')) = {'f','f'};
        data.roboBCFS(strcmp(data.tType,'BINOCULAR')) = {'z','z'};
        
        data.mm_answer = repelem({[]},expParams.nTrials)';
        data.mm_answer(strcmp(data.swap_test,'match')) = {'p'};
        data.mm_answer(strcmp(data.swap_test,'mismatch')) = {'q'};
        
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        data.eyes(strcmp(data.tType,{'BINOCULAR'})) = {[1,1]};
        if strcmp(domEye, {'right'})
            data.eyes(strcmp(data.tType,{'CFS'})) = {[1,0]};
        else
            data.eyes(strcmp(data.tType,{'CFS'})) = {[0,1]};
        end
        
        
        data.tStart_cue = NaN(expParams.nTrials,1);
        data.tEnd_cue = NaN(expParams.nTrials,1);
        data.tStart_noise = NaN(expParams.nTrials,1);
        data.tEnd_noise = NaN(expParams.nTrials,1);
        data.exitFlag_cue = repelem({'EMPTY'},expParams.nTrials)';
        data.exitFlag_noise = repelem({'EMPTY'},expParams.nTrials)';
        % jitter is in ticks, which translates to the hertz of mondrians
        data.jitter(strcmp(data.tType,'NOT STUDIED'),:) = {repelem(0,expParams.nStudyReps)};
        data.jitter_cue = randi([0,expParams.mondrianHertz^-1 * 120],[expParams.nTrials,1]);
        data.jitter_noise = randi([0,expParams.mondrianHertz^-1 * 120],[expParams.nTrials,1]);
        
        
        data.transparency =...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        data.pas = ...
            repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
        data.RoboRT =...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        data.meanRoboRT =...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        
        data.response_cue = cell(expParams.nTrials,1);
        data.rt_cue = NaN(expParams.nTrials,1);
        data.RoboRT_cue = repmat({2}, [expParams.nTrials,1]);
        data.meanRoboRT_cue = NaN(expParams.nTrials,1);
        data.response_noise = cell(expParams.nTrials,1);
        data.rt_noise = NaN(expParams.nTrials,1);
        data.RoboRT_noise = repmat({2}, [expParams.nTrials,1]);
        data.meanRoboRT_noise = NaN(expParams.nTrials,1);
end

end

