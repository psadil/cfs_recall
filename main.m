function main(varargin)


%% collect input
% use the inputParser class to deal with arguments
ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip,'subject', 0, @isnumeric);
addParamValue(ip,'debugLevel', 0, @(x) isnumeric(x) && x >= 0);
addParamValue(ip,'responder', 'user', @(x) sum(strcmp(x, {'user','simpleKeypressRobot'}))==1)
parse(ip,varargin{:});
input = ip.Results;


%% setup
[constants, input, exit_stat] = setupConstants(input, ip);
if exit_stat==1
    windowCleanup(constants);
    return
end
demographics = getDemographics(constants);

%% assess occular dominance

try
    PsychDefaultSetup(2);
    window = setupWindow(constants);
    [mondrians, window] = makeMondrianTexes(window);
    responseHandler = makeInputHandlerFcn(input.responder);
    
    ListenChar(-1);
    HideCursor;
    
    data = runOccularDominance(constants, window, responseHandler, mondrians);
    
    % save data
    writetable(data, [constants.fName, '.csv']);
    
    %% calibrate appropriate contrast for this participant
    data = runStaircase(constants);
    
    % save data
    writetable(data, [constants.fName, '.csv']);
    
    %% run main experiment
    data = runCFSRecall(constants);
    
    % save data
    writetable(data, [constants.fName, '.csv']);
    
catch
    psychrethrow(psychlasterror);
    windowCleanup(constants)
    
end


end


