function data = runOccularDominance( constants, window, responseHandler, mondrians )

expParams = setupExpParams(input.debugLevel);
tInfo = setupTInfo(expParams, input.debugLevel);

data = setupDataTable(expParams, input, 'staircase');
keys = setupKeys(occularDominance);
arrows = makeArrowTexes(window);


%% main experimental loop

giveInstruction(window, keys, responseHandler, constants, 'occularDominance');

answers = [{'\LEFT'}, {'\RIGHT'}];
for trial = 1:expParams.nTrials
    
    % function that presents arrow stim and collects response
    [ data.response(trial), data.rt(trial), data.tStart(trial), data.tEnd(trial), exit_flag] = ...
        elicitArrowResponse(window, responseHandler,...
        arrows(data.correctDirection(trial)).tex, data.rightEye(trial),...
        keys, mondrians, expParams, constants, answers{data.correctDirection(trial)},...
        data.bothEyes(trial));
    
    if exit_flag==1
        break;
    end
    
    if mod(trial,10)==0 && trial ~= expParams.nTrials
        showReminder(window, ['You have completed ', num2str(trial), ' out of ', num2str(expParams.nTrials), ' trials'],...
            keys, constants, responseHandler);
        
        showReminder(window, 'Remember to keep your eyes focusd on the center white square',...
            keys, constants, responseHandler);
    end
    
    % inter-trial-interval
    iti(window, expParams.iti);
    
end


% end of the experiment
structureCleanup(constants);
end

