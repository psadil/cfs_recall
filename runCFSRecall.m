function data = runCFSRecall( input, constants, window, responseHandler, mondrians, domEye, sa )


expParams = setupExpParams(input.debugLevel, 'CFSRecall');
tInfo = setupTInfo(expParams, input.debugLevel);

data = setupDataTable(expParams, input, domEye, 'CFSRecall');
keys = setupKeys('CFSRecall');

%% main experimental loop
giveInstruction(window, keys, responseHandler, constants, 'staircase');

for list = 1:expParams.nLists
    
    
    for rep = 1:expParams.nStudyReps
        
        %% go through study phase of this list
        for trial_study = 1:expParams.nTrialsPerList
            if strcmp(data.tType(trial_study), 'NOT STUDIED')
                continue
            end
            
            [data.transparency(trial_study), sa.values.trial] =...
                wrapper_SA(data, trial_study, sa, sa.values.trial, expParams);
            [data.RoboRT(trial_study), data.meanRoboRT(trial_study)] = ...
                setupRobotResponses(data.transparency(trial_study),...
                sa, expParams, data.jitter(trial_study), data.tType{trial_study});
            
            % make texture for this trial (function is setup to hopefully handle
            % creation of many textures if graphics card could handle that
            stims = makeTexs(data.item(trial_study), window);
            
            % function that presents stim and collects response
            [data.response(trial_study), data.rt(trial_study),...
                data.tStart(trial_study), data.tEnd(trial_study),...
                tInfo.vbl(tInfo.trial==trial_study), tInfo.missed(tInfo.trial==trial_study),...
                data.exitFlag(trial_study)] = ...
                elicitBCFS(window, responseHandler,...
                stims.tex, data.eyes{trial_study},...
                keys, mondrians, expParams, constants, data.RoboRT(trial_study),...
                data.transparency(trial_study), data.jitter(trial_study));
            Screen('Close', stims.tex);
            
            
            % handle exitFlag, based on responses given
            switch data.exitFlag{trial_study}
                case 'ESCAPE'
                    break;
                case 'CAUGHT'
                    showPromptAndWaitForResp(window, 'Please only hit ENTER when an image is present!',...
                        keys, constants, responseHandler);
                case 'SPACE'
                    if strcmp(data.tType{trial_study},'NULL')
                        showPromptAndWaitForResp(window, 'Correct! No object was going to appear.',...
                            keys, constants, responseHandler);
                    elseif strcmp(data.tType{trial_study},'CFS')
                        showPromptAndWaitForResp(window, 'Incorrect! An object was appearing.',...
                            keys, constants, responseHandler);
                    end
                case 'OK'
                    if strcmp(data.response{trial_study},'Return')
                        [data.pas(trial_study),~,~] = getPAS(window, keys.pas, '2', constants, responseHandler);
                        showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                            keys, constants, responseHandler);
                    end
            end
            
            % inter-trial-interval
            iti(window, expParams.iti);
        end
    end
    
    %% go through test phase of this list
    for trial_test = 1:expParams.nTrialsPerList
        
        stims = makeTexs(data.item(trial_test), window);
        
        elicitCueName(stims);
        elicitRespFromNoise(stims);
        
        % inter-trial-interval
        iti(window, expParams.iti);
    end
    
end




% end of the experiment
structureCleanup(constants, tInfo, expParams, input, sa);

end
