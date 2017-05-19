function [data, tInfo, expParams, input, sa] =...
    runStaircase( input, constants, window, responseHandler, mondrians, domEye )

expt = 'staircase';
%%
expParams = setupExpParams(120, input.debugLevel, expt);
tInfo = setupTInfo(expParams, input.debugLevel, expt);
sa = setupSAParams(expParams, expt, struct);

data = setupDataTable(expParams, input, expt, domEye);
keys = setupKeys(expt);

%% main experimental loop
giveInstruction(window, keys, responseHandler, constants, expt, expParams);
rep = 1;
for trial = 1:expParams.nTrials
    
    [data.transparency{trial,rep}, sa] =...
        wrapper_SA(data.tType_study{trial}, sa, expParams);
    [data.RoboRT{trial,rep}, data.meanRoboRT{trial,rep}] = ...
        setupRobotResponses(data.transparency{trial,rep},...
        sa, data.tType_study{trial});
    
    % make texture for this trial (function is setup to hopefully handle
    % creation of many textures if graphics card could handle that
    stims = makeTexs(data.item(trial), window, 'staircase');
    
    showPromptAndWaitForResp(window, 'Press ''j'' if you see an object, or ''f'' if you think none will appear',...
        keys, constants, responseHandler);
    keys_response = keys.bCFS+keys.escape;
    
    % function that presents stim and collects response
    [data.response(trial,rep), data.rt{trial,rep},...
        data.tStart{trial,rep}, data.tEnd{trial,rep},...
        tInfo.vbl(tInfo.trial==trial), tInfo.missed(tInfo.trial==trial),...
        data.exitFlag(trial,rep)] = ...
        elicitBCFS(window, responseHandler,...
        stims.tex, data.eyes{trial},...
        keys_response, mondrians, expParams,...
        constants, data.RoboRT{trial,rep},...
        data.transparency{trial,rep}, data.jitter{trial,rep}, data.roboBCFS{trial},...
        expt, domEye, expParams.nTicks);
    Screen('Close', stims.tex);
    % handle exitFlag, based on responses given
    
    [data.pas(trial,rep), sa, esc] = wrapper_bCFS_exitFlag(data.exitFlag{trial,rep}, data.tType_study{trial}, data.rt{trial}(rep),...
        data.response{trial,rep}, sa, window, keys, constants, responseHandler);    
    if esc
        return;
    end
    
    % show reminder on each block of trials. Breaks up the expt a bit
    if mod(trial,10)==0 && trial ~= expParams.nTrials
        showPromptAndWaitForResp(window, ['You have completed ', num2str(trial), ' out of ', num2str(expParams.nTrials), ' trials'],...
            keys, constants, responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focused on the center cross',...
            keys, constants, responseHandler);
    end
    
    % inter-trial-interval
    iti(window, expParams.iti);
end


end
