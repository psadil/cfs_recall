function [data, tInfo, expParams, input, sa] =...
    runStaircase( input, constants, window, responseHandler, mondrians, domEye )

expt = 'staircase';
%%
expParams = setupExpParams(120, input.debugLevel, expt);
tInfo = setupTInfo(expParams, input.debugLevel);
sa = setupSAParams(expParams, expt, struct);

data = setupDataTable(expParams, input, expt, domEye);
keys = setupKeys(expt);

%% main experimental loop
giveInstruction(window, keys, responseHandler, constants, expt, expParams);
rep = 1;
for trial = 1:expParams.nTrials
    
    [data.transparency{trial,rep}, sa] =...
        wrapper_SA(data, trial, sa, expParams);
    [data.RoboRT{trial,rep}, data.meanRoboRT{trial,rep}] = ...
        setupRobotResponses(data.transparency{trial,rep},...
        sa, data.tType{trial});
    
    % make texture for this trial (function is setup to hopefully handle
    % creation of many textures if graphics card could handle that
    stims = makeTexs(data.item(trial), window, 'staircase');
    
    switch data.tType{trial}
        case {'CFS', 'NOT STUDIED'}
            showPromptAndWaitForResp(window, 'Press ''j'' if you see an object, or ''f'' if you think none will appear',...
                keys, constants, responseHandler);
            keys_response = keys.bcfs+keys.escape;
    end
    
    
    % function that presents stim and collects response
    [data.response(trial,rep), data.rt{trial,rep},...
        data.tStart{trial,rep}, data.tEnd{trial,rep},...
        tInfo.vbl(tInfo.trial==trial), tInfo.missed(tInfo.trial==trial),...
        data.exitFlag(trial,rep)] = ...
        elicitBCFS(window, responseHandler,...
        stims.tex, data.eyes{trial},...
        keys_response, mondrians, expParams,...
        constants, data.RoboRT{trial,rep},...
        data.transparency{trial,rep}, data.jitter{trial,rep}, data.roboBCFS{trial}, expt, domEye);
    Screen('Close', stims.tex);
    % handle exitFlag, based on responses given
    switch data.exitFlag{trial,rep}
        case 'ESCAPE'
            return;
        case 'CAUGHT'
            showPromptAndWaitForResp(window, 'Please only hit ''f'' when an image is present!',...
                keys, constants, responseHandler);
        case 'f'
            if strcmp(data.tType(trial),'CATCH')
                showPromptAndWaitForResp(window, 'Correct! No object was going to appear.',...
                    keys, constants, responseHandler);
            elseif strcmp(data.tType(trial),'CFS')
                sa.results.exitFlag(sa.values.trial-1) = data.exitFlag(trial,rep);
                showPromptAndWaitForResp(window, 'Incorrect! An object was appearing.',...
                    keys, constants, responseHandler);
            end
        case 'j'
            if strcmp(data.response(trial,rep),'j')
                [data.pas(trial,rep),~,~] = elicitPAS(window, keys.pas, '2', constants, responseHandler);
                if strcmp(data.tType{trial},'CFS')
                    sa.results.rt(sa.values.trial-1) = data.rt{trial,rep};
                    showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                        keys, constants, responseHandler);
                else
                    showPromptAndWaitForResp(window, 'Incorrect! No object was going to appear.',...
                        keys, constants, responseHandler);
                end
            end
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
