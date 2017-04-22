function data = runStaircase( input, constants, window, responseHandler, mondrians, domEye )


%%
expParams = setupExpParams(input.debugLevel, 'staircase');
tInfo = setupTInfo(expParams, input.debugLevel);
sa = setupSAParams(input.debugLevel);

data = setupDataTable(expParams, input, domEye, 'staircase');
keys = setupKeys('staircase');

%% main experimental loop
giveInstruction(window, keys, responseHandler, constants, 'staircase');

for trial = 1:expParams.nTrials
    
    [data.transparency(trial), sa.values.trial] =...
        wrapper_SA(data, trial, sa, sa.values.trial, expParams);
    [data.RoboRT(trial), data.meanRoboRT(trial)] = ...
        setupRobotResponses(data.transparency(trial),...
        sa, expParams, data.jitter(trial), data.tType{trial});
    
    % make texture for this trial (function is setup to hopefully handle
    % creation of many textures if graphics card could handle that
    stims = makeTexs(data.item(trial), window);
    
    % function that presents stim and collects response
    [data.response(trial), data.rt(trial),...
        data.tStart(trial), data.tEnd(trial),...
        tInfo.vbl(tInfo.trial==trial), tInfo.missed(tInfo.trial==trial),...
        data.exitFlag(trial)] = ...
        elicitBCFS(window, responseHandler,...
        stims.tex, data.eyes{trial},...
        keys, mondrians, expParams, constants, data.RoboRT(trial),...
        data.transparency(trial), data.jitter(trial));
    Screen('Close', stims.tex);
    % handle exitFlag, based on responses given
    switch data.exitFlag{trial}
        case 'ESCAPE'
            break;
        case 'CAUGHT'
            showPromptAndWaitForResp(window, 'Please only hit ENTER when an image is present!',...
                keys, constants, responseHandler);
        case 'SPACE'
            if strcmp(data.tType{trial},'NULL')
                showPromptAndWaitForResp(window, 'Correct! No object was going to appear.',...
                    keys, constants, responseHandler);
            elseif strcmp(data.tType{trial},'CFS')
                showPromptAndWaitForResp(window, 'Incorrect! An object was appearing.',...
                    keys, constants, responseHandler);
            end
        case 'OK'
            if strcmp(data.response{trial},'Return')
                [data.pas(trial),~,~] = getPAS(window, keys.pas, '2', constants, responseHandler);
                showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                    keys, constants, responseHandler);
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


% end of the experiment
structureCleanup(constants, tInfo, expParams, input, sa);

end
