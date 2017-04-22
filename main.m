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
getAndSaveDemographics(constants);

try
    PsychDefaultSetup(2);
    window = setupWindow(constants);
    [mondrians, window] = makeMondrianTexes(window);
    responseHandler = makeInputHandlerFcn(input.responder);
    
    ListenChar(-1);
    HideCursor;
    
    %% assess occular dominance
    data = runOccularDominance(input, constants, window, responseHandler, mondrians);
    domEye = checkOccularDominanceData(data);
    % save data
    writetable(data, [constants.fName, '.csv']);
    
    %% calibrate appropriate contrast for this participant
    [data, sa] = runStaircase(input, constants, window, responseHandler, mondrians, domEye);
    % save data
    writetable(data, [constants.fName, '.csv']);
    
    %% run main experiment
    data = runCFSRecall(input, constants, window, responseHandler, mondrians, domEye, sa);    
    % save data
    writetable(data, [constants.fName, '.csv']);
    
catch
    psychrethrow(psychlasterror);
    windowCleanup(constants)
end


end

