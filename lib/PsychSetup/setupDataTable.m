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
data.jitter = mat2cell(randi([0,expParams.mondrianHertz^-1 * input.refreshRate],...
    [expParams.nTrials,expParams.nStudyReps]),repelem(1,expParams.nTrials));

data.response = ...
    repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
data.rt = repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);

switch expt
    case 'occularDominance'
        % jitter is in ticks, which translates to the hertz of mondrians
        data.tType_study = Shuffle(repelem(1:4,expParams.nTrials/4))';
        
        % arrow points left(1) and right(2) on half of all trials
        data.correctDirection = cell(expParams.nTrials,1);
        data.correctDirection(data.tType_study == 1 | data.tType_study==2) = {'\LEFT'};
        data.correctDirection(data.tType_study == 3 | data.tType_study==4) = {'\RIGHT'};
        
        % arrow shown to left eye only (codes 2,4) or right eye (1,3)
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        data.eyes(data.tType_study==2 | data.tType_study==4) = {[1,0]};
        data.eyes(data.tType_study==1 | data.tType_study==3) = {[0,1]};
        
        data.eyePresent = repelem({''},expParams.nTrials)';
        data.eyePresent(data.tType_study==2 | data.tType_study==4) = {'left'};
        data.eyePresent(data.tType_study==1 | data.tType_study==3) = {'right'};
        
        data.RoboRT = repmat({repelem(3,expParams.nStudyReps)}, [expParams.nTrials,1]);
        
    case {'CFSgonogo', 'practice'}
        domEye = varargin{1};
        % in the main experiment, we take advantage of how writetable
        % automatically splits non-elemental columns when writing a .csv
        % file. So, every column that contains a vector for first and
        % second study repetition will be split during the saving process
        
        names = readtable(fullfile(pwd,'stims','expt','objectNames_2afc.csv'));
        switch expt
            case 'CFSgonogo'
                t = readtable('blockingTable.csv');
                t = t(t.subject==input.subject,:);
                t = sortrows(t,'trial_study');
                t = t(1:expParams.nTrials,:); % this only comes up when debugging
                
                
                data.item = t.pair1;
                data.pair = t.pair2;
                data.list = t.list;
                
                % trial type key
                data.tType_study = t.tType_study;
                data.trial_test = t.trial_test;
                
                testTable = sortrows(t,'trial_test');
                
                data.item_test = testTable.pair1;
                data.pair_test = testTable.pair2;
                data.tType_test = testTable.tType_test;
                
                data.gonogo_answer = testTable.gonogo_answer;
            case 'practice'
                data.item = Shuffle(197:208)';
                pairs = readtable(fullfile(pwd,'stims','expt','stimPairings.csv'));
                data.pair = pairs.pair2(data.item);
                data.list = repelem(1, expParams.nTrials)';
                
                data.tType_study = ...
                    Shuffle(repelem({'CFS','Binocular','Not Studied'},expParams.nTrials/3))';
                data.trial_test = Shuffle(1:12)';
                
                data.item_test = data.item(data.trial_test);
                data.pair_test = data.pair(data.trial_test);
                data.tType_test = data.tType_study(data.trial_test);
                
                gonogo_answers = [{'go'},{'nogo'}];
                data.gonogo_answer = gonogo_answers(Randi(2,[1,12]))';
        end
        data.name = names{data.item,1};
        data.name_test = names{data.item_test,1};
        
        data.roboBCFS = ...
            repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
        data.roboBCFS(strcmp(data.tType_study,'CFS'),:) = repmat({'j'},[expParams.nTrials/3,expParams.nStudyReps]);
        data.roboBCFS(strcmp(data.tType_study,'Not Studied'),:) = repmat({'f'},[expParams.nTrials/3,expParams.nStudyReps]);
        data.roboBCFS(strcmp(data.tType_study,'Binocular'),:) = repmat({'z'},[expParams.nTrials/3,expParams.nStudyReps]);
        
        data.eyes = repelem({[0,0]},expParams.nTrials)';
        data.eyes(strcmp(data.tType_study,{'Binocular'})) = {[1,1]};
        if strcmp(domEye, {'right'})
            data.eyes(strcmp(data.tType_study,{'CFS'})) = {[1,0]};
        else
            data.eyes(strcmp(data.tType_study,{'CFS'})) = {[0,1]};
        end
        
        data.tStart_cue = NaN(expParams.nTrials,1);
        data.tEnd_cue = NaN(expParams.nTrials,1);
        data.tStart_noise = NaN(expParams.nTrials,1);
        data.tEnd_noise = NaN(expParams.nTrials,1);
        data.exitFlag_cue = repelem({'EMPTY'},expParams.nTrials)';
        data.exitFlag_noise = repelem({'EMPTY'},expParams.nTrials)';
        % jitter is in ticks, which translates to the hertz of mondrians
        data.jitter(strcmp(data.tType_study,'Not Studied'),:) = {repelem(0,expParams.nStudyReps)};
        data.jitter_noise = randi([0,expParams.mondrianHertz^-1 * input.refreshRate],[expParams.nTrials,1]);
        
        data.transparency = ...
            repmat({repelem(NaN, expParams.nStudyReps)}, [expParams.nTrials,1]);
        data.pas = ...
            repmat(repelem({[]},expParams.nStudyReps), [expParams.nTrials,1]);
        data.RoboRT = ...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        data.meanRoboRT = ...
            repmat({repelem(NaN,expParams.nStudyReps)}, [expParams.nTrials,1]);
        
        data.response_cue = cell(expParams.nTrials,1);
        data.rt_cue = NaN(expParams.nTrials,1);
        data.RoboRT_cue = repmat({1}, [expParams.nTrials,1]);
        %         data.meanRoboRT_cue = NaN(expParams.nTrials,1);
        data.response_noise = cell(expParams.nTrials,1);
        data.rt_noise = NaN(expParams.nTrials,1);
        data.RoboRT_noise = repmat({1}, [expParams.nTrials,1]);
        %         data.meanRoboRT_noise = NaN(expParams.nTrials,1);
end

end
