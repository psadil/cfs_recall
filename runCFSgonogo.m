function [data, tInfo, expParams, input, sa] =...
    runCFSgonogo( input, constants, window, responseHandler, mondrians, domEye, sa )

expt = 'CFSgonogo';

expParams = setupExpParams(input.refreshRate, input.debugLevel, expt);
tInfo = setupTInfo(expParams, input.debugLevel, expt);
sa = setupSAParams(expParams, expt, sa);

data = setupDataTable(expParams, input, expt, domEye);
keys = setupKeys(expt);
% responseHandler = makeInputHandlerFcn(input.responder);


% res = repelem(noiseRect(3) - noiseRect(1),2);
% noisetex = CreateProceduralNoise(window.pointer, res(1), res(2), 'ClassicPerlin', [0.5 0.5 0.5 1]);

%% main experimental loop
for list = 1:expParams.nLists
    
    if input.study
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
                    wrapper_SA(data.tType_study{trial}, sa, expParams);
                [data.RoboRT{trial}(rep), data.meanRoboRT{trial}(rep)] = ...
                    setupRobotResponses(data.transparency{trial}(rep),...
                    sa, data.tType_study{trial});
                
                % make texture for this trial (function is setup to hopefully handle
                % creation of many textures if graphics card could handle that
                stims = makeTexs(data.item(trial), window, 'STUDY');
                
                switch data.tType_study{trial}
                    case 'Binocular'
                        showPromptAndWaitForResp(window, 'Please study the details of the following object',...
                            keys, constants, responseHandler);
                        keys_response = keys.escape;
                        nTicks = expParams.nTicks_bino;
                    case {'CFS', 'Not Studied'}
                        showPromptAndWaitForResp(window, 'Press ''j'' if you see an object, or ''f'' if you think none will appear',...
                            keys, constants, responseHandler);
                        keys_response = keys.bCFS+keys.escape;
                        nTicks = expParams.nTicks;
                end
                
                % function that presents stim and collects response
                [data.response(trial,rep), data.rt{trial}(rep),...
                    data.tStart{trial}(rep), data.tEnd{trial}(rep),...
                    ~, ~,...
                    data.exitFlag(trial,rep)] = ...
                    elicitBCFS(window, responseHandler,...
                    stims.tex, data.eyes{trial},...
                    keys_response, mondrians, expParams,...
                    constants, data.RoboRT{trial}(rep),...
                    data.transparency{trial}(rep), data.jitter{trial}(rep), data.roboBCFS{trial,rep}, ...
                    expt, domEye, nTicks, []);
                Screen('Close', stims.tex);
                
                % handle exitFlag, based on responses given
                [data.pas(trial,rep), sa, esc] = wrapper_bCFS_exitFlag(data.exitFlag{trial,rep}, data.tType_study{trial}, data.rt{trial}(rep),...
                    data.response{trial,rep}, sa, window, keys, constants, responseHandler);
                if esc
                    return;
                end
                
                % inter-trial-interval
                iti(window, expParams.iti);
            end
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
    
    % make 50 noise textures to use on this list
    noiseTexes = makeNoiseTex(window);
    
    
    %% go through test phase of this list
    for item = 1:expParams.nTrialsPerList
        
        trial = item + (expParams.nTrialsPerList*(list-1));
        
        stims = makeTexs(data.item_test(trial), window, 'NAME',data.pair_test(trial));
        keys_response = keys.enter+keys.escape+keys.name+keys.bkspace+keys.space;
        [data.response_cue(trial), data.rt_cue(trial),...
            data.tStart_cue(trial), data.tEnd_cue(trial),...
            data.exitFlag_cue(trial)] = elicitCueName(window, ...
            responseHandler, stims.tex,...
            keys_response, constants, [data.name_test{trial},'\ENTER']);
        Screen('Close', stims.tex);
        switch data.exitFlag_cue{trial}
            case 'ESCAPE'
                return;
        end
        
        
        showPromptAndWaitForResp(window, 'Press Enter only if you see an object',...
            keys, constants, responseHandler);
        
        switch data.gonogo_answer{trial}
            case 'go'
                answer = '\ENTER';
                maxAlpha = 1;
            case 'nogo'
                answer = ' ';
                maxAlpha = 0;
        end
        stims = makeTexs(data.item_test(trial), window, 'NOISE', data.pair_test(trial));
        keys_response = keys.enter+keys.escape;
        iti(window, expParams.iti);
        
        % function that presents stim and collects response
        [data.response_noise(trial), data.rt_noise(trial),...
            data.tStart_noise(trial), data.tEnd_noise(trial),...
            ~, ~,...
            data.exitFlag_noise(trial)] = ...
            elicitBCFS(window, responseHandler,...
            stims.tex, [1, 1],...
            keys_response, noiseTexes, expParams,...
            constants, data.RoboRT_noise{trial},...
            maxAlpha, data.jitter_noise(trial), answer, ...
            'noise', domEye, expParams.nTicks_noise,...
            'Press Enter only if you see an object');
        Screen('Close', stims.tex);
        
        %         [data.response_noise(trial), data.rt_noise(trial),...
        %             data.tStart_noise(trial), data.tEnd_noise(trial),...
        %             ~, ~,...
        %             data.exitFlag_noise(trial)] = elicitNoise2(window, ...
        %             responseHandler, stims.tex, keys_response, expParams,...
        %             constants, data.RoboRT_noise{trial}, 1, data.jitter_noise(trial), answer, noisetex,...
        %             'Press Enter only if you see an object');
        
        % handle exitFlag, based on responses given
        switch data.exitFlag_noise{trial}
            case 'ESCAPE'
                return;
            case 'CAUGHT'
                showPromptAndWaitForResp(window, 'Please only respond when an image is present!',...
                    keys, constants, responseHandler);
            otherwise
                switch data.response_noise{trial}
                    case 'Return'
                        switch data.gonogo_answer{trial}
                            case 'go'
                                prompt = 'Correct! There was an object';
                            otherwise
                                prompt = 'Incorrect! The was no object';
                        end
                    case 'NO RESPONSE'
                        switch data.gonogo_answer{trial}
                            case 'nogo'
                                prompt = 'Correct! There was no object';
                            otherwise
                                prompt = 'Incorrect! There was an object';
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
    noiseTexes = struct2array(noiseTexes);
    Screen('Close', noiseTexes);
end

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    % prompt participant to respond
    DrawFormattedText(window.pointer, ['That is the end of the experiment.\n',...
        'Thanks for participating!'], 'center', 'center');
end
Screen('Flip', window.pointer);

WaitSecs(2);

end
