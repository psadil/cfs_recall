function main(varargin)


%% collect input
% use the inputParser class to deal with arguments
ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip, 'subject', 0, @isnumeric);
addParamValue(ip, 'dominantEye', 'right', @(x) sum(strcmp(x, {'left','right'}))==1);
addParamValue(ip, 'debugLevel', 0, @(x) isnumeric(x) && x >= 0);
addParamValue(ip, 'responder', 'user', @(x) sum(strcmp(x, {'user','simpleKeypressRobot'}))==1);
addParamValue(ip, 'experiments', [1,1,1], @(x) length(x)==3);
addParamValue(ip, 'study', 1, @(x) isnumeric(x));
addParamValue(ip, 'refreshRate', 100, @(x) any(x==[100,120]));
parse(ip,varargin{:});
input = ip.Results;


%% setup
[constants, input, exit_stat] = setupConstants(input, ip);
if exit_stat==1
    windowCleanup(constants);
    return
end
if input.debugLevel == 0
    demographics(constants.subDir);
end
try
    PsychDefaultSetup(2);
    window = setupWindow(constants, input);
    [mondrians, window] = makeMondrianTexes(window);
    responseHandler = makeInputHandlerFcn(input.responder);
    
    ListenChar(-1);
    HideCursor;
    
    if input.experiments(1)
        expt = 'occularDominance';
        %% assess occular dominance
        [data, tInfo, expParams, input] = runOccularDominance(input, constants, window, responseHandler, mondrians);
        domEye = checkOccularDominanceData(data);
        % save data
        % end of the experiment
        structureCleanup(expt, input.subject, data, constants, tInfo, expParams, window);
    else
        domEye = input.dominantEye;
    end
    
    %% provide practice study + test
    if input.experiments(2)
        expt = 'practice';
        [data, tInfo, expParams, input] =...
            runCFSgonogo(input, constants, window, responseHandler, mondrians, domEye, expt);
        % save data
        structureCleanup(expt, input.subject, data, constants, tInfo, expParams, input, window);
    end
    
    %% run main experiment
    if input.experiments(3)
        expt = 'CFSgonogo';
        [data, tInfo, expParams, input] =...
            runCFSgonogo(input, constants, window, responseHandler, mondrians, domEye, expt);
        % save data
        structureCleanup(expt, input.subject, data, constants, tInfo, expParams, input, window);
    end
    
    mondrians = struct2array(mondrians);
    Screen('Close', mondrians);
    windowCleanup(constants);
    
catch
    psychrethrow(psychlasterror);
    windowCleanup(constants);
end


end

