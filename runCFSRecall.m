function [data, tInfo, expParams, input, sa] =...
    runCFSRecall( input, constants, window, responseHandler, mondrians, domEye, sa )

expt = 'CFSRecall';

expParams = setupExpParams(120, input.debugLevel, expt);
tInfo = setupTInfo(expParams, input.debugLevel);
sa = setupSAParams(expParams, expt, sa);

data = setupDataTable(expParams, input, expt, domEye);
keys = setupKeys(expt);
% responseHandler = makeInputHandlerFcn(input.responder);

noiseRect = ScaleRect(window.imagePlace, 2, 2);
res = repelem(noiseRect(3) - noiseRect(1),2);
noisetex = CreateProceduralNoise(window.pointer, res(1), res(2), 'Perlin', [0.5 0.5 0.5 1]);


%% main experimental loop
for list = 1:expParams.nLists
    
    if list == 1
        giveInstruction(window, keys, responseHandler, constants, expt, expParams);
    else
        showPromptAndWaitForResp(window, ['You are beginning list ', num2str(list), ' out of ', num2str(expParams.nLists), ' lists'],...
            keys, constants, responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focused on the center cross',...
            keys, constants, responseHandler);
    end
    
    %% go through study phase of this list
    for rep = 1:expParams.nStudyReps
        for item = 1:expParams.nTrialsPerList
            trial = item + (expParams.nTrialsPerList*(list-1));
            
            [data.transparency{trial}(rep), sa] =...
                wrapper_SA(data, trial, sa, expParams);
            [data.RoboRT{trial}(rep), data.meanRoboRT{trial}(rep)] = ...
                setupRobotResponses(data.transparency{trial}(rep),...
                sa, data.tType{trial});
            
            % make texture for this trial (function is setup to hopefully handle
            % creation of many textures if graphics card could handle that
            stims = makeTexs(data.item(trial), window, 'STUDY');
            
            switch data.tType{trial}
                case 'BINOCULAR'
                    showPromptAndWaitForResp(window, 'Please study the details of the following object',...
                        keys, constants, responseHandler);
                    keys_response = keys.escape;
                case {'CFS', 'NOT STUDIED'}
                    showPromptAndWaitForResp(window, 'Press Enter if you see an object, or SPACE if you think none will appear',...
                        keys, constants, responseHandler);
                    keys_response = (keys.enter+keys.escape+keys.space);
            end
            
            % function that presents stim and collects response
            [data.response(trial,rep), data.rt{trial}(rep),...
                data.tStart{trial}(rep), data.tEnd{trial}(rep),...
                tInfo.vbl(tInfo.trial==trial), tInfo.missed(tInfo.trial==trial),...
                data.exitFlag(trial,rep)] = ...
                elicitBCFS(window, responseHandler,...
                stims.tex, data.eyes{trial},...
                keys_response, mondrians, expParams,...
                constants, data.RoboRT{trial}(rep),...
                data.transparency{trial}(rep), data.jitter{trial}(rep), '\ENTER', expt, domEye);
            Screen('Close', stims.tex);
            
            % handle exitFlag, based on responses given
            switch data.exitFlag{trial,rep}
                case 'ESCAPE'
                    return;
                case 'CAUGHT'
                    showPromptAndWaitForResp(window, 'Please only hit ENTER when an image is present!',...
                        keys, constants, responseHandler);
                case 'SPACE'
                    switch data.tType{trial}
                        case {'CATCH', 'NOT STUDIED'}
                            showPromptAndWaitForResp(window, 'Correct! No object was going to appear.',...
                                keys, constants, responseHandler);
                        case 'CFS'
                            sa.results.exitFlag(sa.values.trial-1) = data.exitFlag(trial,rep);
                            showPromptAndWaitForResp(window, 'Incorrect! An object was appearing.',...
                                keys, constants, responseHandler);
                    end
                case 'OK'
                    if strcmp(data.response{trial,rep},'Return')
                        [data.pas(trial,rep),~,~] = elicitPAS(window, keys.pas, '2', constants, responseHandler);
                        if strcmp(data.tType{trial},'CFS')
                            sa.results.rt(sa.values.trial-1) = data.rt{trial}(rep);
                            showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                                keys, constants, responseHandler);
                        else
                            showPromptAndWaitForResp(window, 'Incorrect! No object was going to appear.',...
                                keys, constants, responseHandler);
                        end
                    end
            end
            
            % inter-trial-interval
            iti(window, expParams.iti);
        end
    end
    
    %% Instruction for test
    if list == 1
        giveInstruction(window, keys, responseHandler, constants, 'TEST', expParams);
    else
        showPromptAndWaitForResp(window, ['This is the test phase for list ', num2str(list), ' out of ', num2str(expParams.nLists), ' lists'],...
            keys, constants, responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focused on the center cross',...
            keys, constants, responseHandler);
    end
    
    
    %% go through test phase of this list
    for item = 1:expParams.nTrialsPerList
        
        trial = item + (expParams.nTrialsPerList*(list-1));
        
        stims = makeTexs(data.item_test(trial), window, 'NAME',data.pair_test(trial));
        
        [data.response_cue(trial), data.rt_cue(trial),...
            data.tStart_cue(trial), data.tEnd_cue(trial),...
            data.exitFlag_cue(trial)] = elicitCueName(window, ...
            responseHandler, stims.tex, keys, constants, '\ENTER');
        Screen('Close', stims.tex);
        
        iti(window, expParams.iti);
        
        if strcmp(data.swap_test(trial), 'match')
            stims = makeTexs(data.item_test(trial), window, 'NOISE',data.pair_test(trial));
        else
            stims = makeTexs(data.pair_test(trial), window, 'NOISE',data.item_test(trial));
        end
        [data.response_noise(trial), data.rt_noise(trial),...
            data.tStart_noise(trial), data.tEnd_noise(trial),...
            ~, ~,...
            data.exitFlag_noise(trial)] = elicitNoise(window, ...
            responseHandler, stims.tex, keys, expParams,...
            constants, data.RoboRT_noise{trial}, 1, data.jitter_noise(trial), data.mm_answer{trial}, noisetex);
        Screen('Close', stims.tex);
        % handle exitFlag, based on responses given
        switch data.exitFlag_noise{trial}
            case 'ESCAPE'
                return;
            case 'CAUGHT'
                showPromptAndWaitForResp(window, 'Please only hit ENTER when an image is present!',...
                    keys, constants, responseHandler);
            case 'OK'
                switch data.response_noise{trial}
                    case 'q'
                        switch data.swap_test{trial}
                            case 'match'
                                prompt = 'Correct! The objects matched';
                            otherwise
                                prompt = 'Incorrect! The objects were mismatched';
                        end
                    case 'p'
                        switch data.swap_test{trial}
                            case 'mismatch'
                                prompt = 'Correct! The objects were mismatched';
                            otherwise
                                prompt = 'Incorrect! The objects matched';
                        end
                    otherwise
                        prompt = '';
                end
                showPromptAndWaitForResp(window, prompt,...
                    keys, constants, responseHandler);
        end
        % inter-trial-interval
        iti(window, expParams.iti);
    end
    
end

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    % prompt participant to respond
    DrawFormattedText(window.pointer, ['That is the end of the experiment.\n',...
        'Thanks for participating!'], 'ceter', 'center');
end
Screen('Flip', window.pointer);

WaitSecs(2);

end
