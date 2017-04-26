function main(varargin)


%% collect input
% use the inputParser class to deal with arguments
ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip,'subject', 0, @isnumeric);
addParamValue(ip,'dominantEye', 'right', @(x) sum(strcmp(x, {'left','right'}))==1);
addParamValue(ip,'debugLevel', 0, @(x) isnumeric(x) && x >= 0);
addParamValue(ip,'responder', 'user', @(x) sum(strcmp(x, {'user','simpleKeypressRobot'}))==1)
addParamValue(ip,'experiments', [1,1,1], @(x) length(x)==3)
parse(ip,varargin{:});
input = ip.Results;


%% setup
[constants, input, exit_stat] = setupConstants(input, ip);
if exit_stat==1
    windowCleanup(constants);
    return
end
getDemographics(constants);

try
    PsychDefaultSetup(2);
    window = setupWindow(constants);
    [mondrians, window] = makeMondrianTexes(window);
    responseHandler = makeInputHandlerFcn(input.responder);
    
    ListenChar(-1);
    HideCursor;
    
    if input.experiments(1)
        %% assess occular dominance
        [data, tInfo, expParams, input] = runOccularDominance(input, constants, window, responseHandler, mondrians);
        domEye = checkOccularDominanceData(data);
        % save data
        % end of the experiment
        expt = 'occularDominance';
        structureCleanup(expt, input.subject, data, constants, tInfo, expParams);
    else
        domEye = input.dominantEye;
    end
    
    %% calibrate appropriate contrast for this participant
    [data, tInfo, expParams, input, sa] =...
        runStaircase( input, constants, window, responseHandler, mondrians, domEye);
    % save data
    expt = 'staircase';
    structureCleanup(expt, input.subject, data, constants, tInfo, expParams, input, sa);
    
    %% run main experiment
    [data, tInfo, expParams, input, sa] =...
        runCFSRecall(input, constants, window, responseHandler, mondrians, domEye, sa);
    % save data
    expt = 'CFSRecall';
    structureCleanup(expt, input.subject, data, constants, tInfo, expParams, input, sa);
    windowCleanup(constants);
    
catch
    psychrethrow(psychlasterror);
    windowCleanup(constants);
end


end

