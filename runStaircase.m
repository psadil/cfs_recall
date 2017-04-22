function data = runStaircase( constants, window, responseHandler, mondrians )


%%
tInfo = setupTInfo(expParams, input.debugLevel);
sa = setupSAParams(input.debugLevel);

data = setupDataTable(expParams, input, demographics);
keys = setupKeys;

%% main experimental loop
giveInstruction(window, keys, responseHandler, constants, 'staircase');

trial_SA = 1;
for trial = 1:expParams.nTrials
    
    [data.transparency(trial), trial_SA] =...
        wrapper_SA(data, trial, sa, trial_SA, expParams);
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
                showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                    keys, constants, responseHandler);
                [data.pas(trial),~,~] = getPAS(window, keys.pas, '2', constants, responseHandler);
            end
    end
    
    % show reminder on each block of trials. Breaks up the expt a bit
    if mod(trial,10)==0 && trial ~= expParams.nTrials
        showPromptAndWaitForResp(window, ['You have completed ', num2str(trial), ' out of ', num2str(expParams.nTrials), ' trials'],...
            keys, constants, responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focusd on the center cross',...
            keys, constants, responseHandler);
    end
    
    % inter-trial-interval
    iti(window, expParams.iti);
end


% end of the experiment
structureCleanup(constants, tInfo, expParams, input, sa);

end


%%
function stims = makeTexs(item, window)

stims = struct('id', item);

% grab all images
[im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
    'stims', 'expt', 'whole', ['object', num2str(x.id), '_noBkgrd']), 'png'), ...
    stims, 'UniformOutput', 0);
stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);

% make textures of images
stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);

end

%% wrapper for SA algorithm
function [transparency, trial_SA] = wrapper_SA(data, trial, sa, trial_SA, expParams)

% This function helps implement two pieces of experimental logic.
% First, the transparency on null trials is automatically set to 0.
% Second, the overall data table is filtered so that we're only
% dealing with non-null trials. The SA algorithm doesn't need to
% see those trials for which participants weren't supposed to
% respond!

if strcmp(data.tType{trial},'NULL')
    transparency = 0;
elseif strcmp(data.tType{trial},'CFS')
    data_SA = data(~strcmp(data.tType,'NULL'),:);
    if trial_SA == 1
        transparency_log = sa.params.x1;
    elseif strcmp(data_SA.exitFlags{trial_SA-1}, 'SPACE')
        transparency_log = data_SA.transparency(trial_SA-1);
    else
        transparency_log = ...
            SA(log(data_SA.transparency(trial_SA-1)),...
            trial_SA, data_SA.rt(trial_SA-1), sa);
    end
    trial_SA = trial_SA + 1;
    % need to convert transparency scale
    transparency = exp(transparency_log);
    % but, we can't have transparency greater than 1
    transparency = min(1, transparency);
    % to keep the rate constant, we need to alter the resolution of
    % the value chosen
    %     transparency = transparency + mod(1/expParams.mondrianHertz,transparency);
    % finally can't have value less than 1/mondrianHertz
    transparency = max(transparency, 1/expParams.mondrianHertz);
end

end

