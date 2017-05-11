function [data, tInfo, expParams, input] = runOccularDominance( input, constants, window, responseHandler, mondrians )
expt = 'occularDominance';


expParams = setupExpParams(120, input.debugLevel, expt);
tInfo = setupTInfo(expParams, input.debugLevel, expt);

data = setupDataTable(expParams, input, expt);
keys = setupKeys(expt);
stims = makeTexs([], window, 'ARROW');

%% main experimental loop

giveInstruction(window, keys, responseHandler, constants, expt, expParams);
rep=1;
for trial = 1:expParams.nTrials
    
    arrowTex = selectArrowTex(stims, data.correctDirection{trial});
    % function that presents arrow stim and collects response
    if all(data.eyes{trial}==[0,1])
        maskEye = 'left';
    else
        maskEye = 'right';
    end
    [data.response(trial,rep), data.rt{trial,rep},...
        data.tStart{trial,rep}, data.tEnd{trial,rep},...
        tInfo.vbl(tInfo.trial==trial), tInfo.missed(tInfo.trial==trial),...
        data.exitFlag(trial,rep)] = ...
        elicitBCFS(window, responseHandler,...
        arrowTex, data.eyes{trial},...
        (keys.escape+keys.arrows), mondrians, expParams,...
        constants, data.RoboRT{trial,rep},...
        expParams.maxAlpha, data.jitter{trial,rep}, data.correctDirection{trial},...
        expt, maskEye, expParams.nTicks);
    
    
    switch data.exitFlag{trial,rep}
        case 'ESCAPE'
            return;
%         case 'CAUGHT'
%             showPromptAndWaitForResp(window, 'Please only respond when an image is present!',...
%                 keys, constants, responseHandler);
        otherwise
            switch data.response{trial,rep}
                case 'RightArrow'
                    if strcmp('\RIGHT',data.correctDirection{trial})
                        showPromptAndWaitForResp(window, 'Correct!',...
                            keys, constants, responseHandler);
                    else
                        showPromptAndWaitForResp(window, 'Incorrect! Please wait until you are certain.',...
                            keys, constants, responseHandler);
                    end
                case 'LeftArrow'
                    if strcmp('\LEFT',data.correctDirection{trial})
                        showPromptAndWaitForResp(window, 'Correct!',...
                            keys, constants, responseHandler);
                    else
                        showPromptAndWaitForResp(window, 'Incorrect! Please wait until you are certain.',...
                            keys, constants, responseHandler);
                    end
            end
    end
    
    if mod(trial,10)==0 && trial ~= expParams.nTrials
        showPromptAndWaitForResp(window, ['You have completed ', num2str(trial), ' out of ', num2str(expParams.nTrials), ' trials'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focusd on the center white cross',...
            keys,constants,responseHandler);
    end
    
    % inter-trial-interval
    iti(window, expParams.iti);
    
end
Screen('Close', stims(1).tex);
Screen('Close', stims(2).tex);

end

function arrowTex = selectArrowTex(stims, correctDirection)

switch correctDirection
    case '\RIGHT'
        arrowTex = stims(1).tex;
    case '\LEFT'
        arrowTex = stims(2).tex;
end

end