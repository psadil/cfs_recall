function [] = setupBlocking(varargin)

%{
Construct grand blocking table for CFS recall experiment, go/nogo version

Values that must be blocked:
  - Study Condition of object
  - Go or Nogo of object (1/4 nogo per list per condition)

Values that won't be blocked
  - list object is encountered in

Values to randomize
  - Position of object in study list
  - Position of object in test list

Implies needing units of 12 participants

This function must be run in same folder as stimPairs.csv. To signify that
this function should only have ever been run once, the resulting file will
need to be manually moved to the main folder after it has been run.

NOTE: variable delItems is holdover from previous experiment. Those
potential items were excluded for a variety of reasons, including
overlapping aperture parts or objects with names that were too obvious
given the apertures.
 
  %}

% objects to not use. For each object included, its pair is also included
delItems = [5,9,10,12,17,21,22,24,27,35,38,36,41,42,46,48,49,51,54,55,...
    63,65,67,70,75,77,82,83,84,87,91,92,93,94,101,106,105,108,109,114,...
    116,120,127,130,132,134,136,138,142,148,149,152,158,160,164,168,169,...
    171,173,175,178,180,182,190,...
    1,104];

t = readtable('stimPairings.csv');
t = removerows(t,delItems);
% at the moment, this code only works when the following two variables are
% equal
nItemsPerList = 12;
nParticipantUnits = 12;

ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip,'nItems', 96, @(x) isnumeric(x) && mod(x,nItemsPerList)==0 && x < size(t,1));
addParamValue(ip,'nSubs', 204, @(x) isnumeric(x) && mod(x,nParticipantUnits)==0);
parse(ip,varargin{:});
input = ip.Results;

nConds = 3;
nLists = input.nItems / nItemsPerList;

% only take as many objects as there will be trials
t = t(1:input.nItems,:);

% need to shuffle items, because the object files are in alphabetical order
t = t(randperm(input.nItems),:);

% each set of 12 items will always be encountered in the same list
t.list = repelem(1:nLists,nItemsPerList)';

% repeat table as many times as there are subjects
t = repmat(t,[input.nSubs,1]);

t.subject = repelem(1:input.nSubs,input.nItems)';

% trial_study indexes the study trial that object pair1 will be encountered
% on, for a given participant. Note that all objects will be studied twice
% (the order will be repeated)
t.trial_study = nan(size(t,1),1);

% trial_test indexes which test trial object pair1 will be encountered on,
% for a given participant.
t.trial_test = nan(size(t,1),1);

% tType_study indicates which condition object pair1 was studied under
t.tType_study = repelem({[]},size(t,1))';

% tType_test indicates the study condition of the object that was seen on
% trial_test
t.tType_test = repelem({[]},size(t,1))';

% the correct response for go/nogo test
t.gonogo_answer = repelem({[]},size(t,1))';

% the names of the conditions. These exact values will be used heavily
% throughout main program.
studyCondNames = [{'Binocular'},{'CFS'},{'Not Studied'}];
gonogoNames = [{'go'},{'nogo'}];

%{
baseCond key
  1-3: Binocular, go
  4: Binocular, nogo
  5-7: CFS, go
  8: CFS, nogo
  9-11: Not Studied, go
  12: Not Studied, nogo  
%}
baseCond = Shuffle(1:nParticipantUnits);
studyCond = baseCond;
studyCond(baseCond==1 | baseCond==2 | baseCond==3 | baseCond==4) = 1;
studyCond(baseCond==5 | baseCond==6 | baseCond==7 | baseCond==8) = 2;
studyCond(baseCond==9 | baseCond==10 | baseCond==11 | baseCond==12) = 3;


for sub = 1:input.nSubs
    trial_study = arrayfun(@(x) randperm(nItemsPerList)+x, nItemsPerList*(0:nLists-1), 'UniformOutput',false);
    trial_test = arrayfun(@(x) randperm(nItemsPerList)+x, nItemsPerList*(0:nLists-1), 'UniformOutput',false);
    
    % useful index for mapping between study and test orders, within a
    % given list
    % this should be a find statement involving index and trial_study
    testIndex = arrayfun(@(x,y) x{1}-y, trial_test, nItemsPerList*(0:nLists-1), 'UniformOutput',false);
    
    % NOTE: this may appear to put the same order of conditions in each
    % study list. That is not the case, because the order of the items has
    % been shuffled by the above, trial_study, variable.
    tType_study = arrayfun(@(x) mod(studyCond + sub,nConds)+1, 1:nLists, 'UniformOutput',false);
    gonogo = arrayfun(@(x) mod(baseCond + sub,4), 1:nLists, 'UniformOutput',false);

    gonogo_study_answer = gonogo;
    for list = 1:nLists
       gonogo_study_answer{list}(gonogo{list}==0) = 2;
       gonogo_study_answer{list}(gonogo{list}~=0) = 1;
    end
    
    % need to translate the condition determined for the study order into
    % the test order
    tType_test = cellfun(@(x,y) x(y), tType_study, testIndex, 'UniformOutput',false);
    gonogo_answer = cellfun(@(x,y) x(y), gonogo_study_answer, testIndex, 'UniformOutput',false);
    for list = 1:nLists
        t.trial_study(t.subject==sub & t.list==list) = trial_study{list};
        t.trial_test(t.subject==sub & t.list==list) = trial_test{list};
        
        t.tType_study(t.subject==sub & t.list==list) = studyCondNames(tType_study{list});
        t.tType_test(t.subject==sub & t.list==list) = studyCondNames(tType_test{list});
        
        t.gonogo_answer(t.subject==sub & t.list==list) = gonogoNames(gonogo_answer{list});
    end
end

writetable(t,'blockingTable.csv');

end

