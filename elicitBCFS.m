function [ response, rt, tStart, tEnd, vbl, missed, exitFlag ] =...
    elicitBCFS( window, responseHandler, tex, eyes,...
    keys, mondrians, expParams, constants,...
    roboRT_preJitter, maxAlpha, jitter, answer, expt, maskEye )
%collectResponses Show arrow until participant makes response, and collect
%that response
response = {'NO RESPONSE'};
rt = NaN;
exitFlag = {'OK'};
tStart = NaN;
vbl = NaN(expParams.nTicks+1,1);
missed = NaN(expParams.nTicks+1,1);

switch expt
    case 'occularDominance'
        where=[];
    otherwise
        where=window.imagePlace;
end

% transparency of texture increases at constant rate, up to a given trial's
% maximum value
alpha.tex = [repelem(0, jitter), 0:(1/expParams.mondrianHertz):maxAlpha];
% transparency of mondrians is typically locked at 1
alpha.mondrian = [repelem(1,jitter), expParams.alpha.mondrian];
% both transparencies needed to have additional jitter added to beginning

roboRT = roboRT_preJitter + (jitter*(1/expParams.mondrianHertz));

prompt = [];
slack = .5;
goRobo = 0;

KbQueueCreate(constants.device, keys);
whichMondrian = selectMondrian(size(mondrians,2));
alpha_stim = selectTexAlpha(alpha.tex, 1);
drawFixation(window);
% Screen('PreloadTextures',window.pointer,tex);
[vbl(1), ~, ~, missed(1)] = Screen('Flip', window.pointer); % Display cue and prompt
for tick = 0:(expParams.nTicks-1)
    
    % for each tick, pick out one of the mondrians to draw
    drawMaskedStimulus(window, prompt, eyes,...
        tex, mondrians(whichMondrian).tex,... %  mondrians(mod(tick,size(mondrians,2))+1).tex,
        1,... %         alpha.mondrian(min(length(alpha.mondrian), tick+1)), ...
        alpha_stim, where, maskEye);
    
    % flip only in sync with mondrian presentation rate
    [vbl(tick+2), ~, ~, missed(tick+2)] =...
        Screen('Flip', window.pointer, vbl(tick+1) + (expParams.mondrianHertz-slack)*window.ifi );
    if tick == 0
        tStart = vbl(2);
        KbQueueStart(constants.device);
    end
    if (vbl(tick+2) - tStart) > roboRT
        goRobo = 1;
    end
    
    [keys_pressed, press_times] = responseHandler(constants.device, answer, goRobo);
    if ~isempty(keys_pressed)
        [response, rt] = ...
            wrapper_keyProcess(keys_pressed, press_times, tStart, expt);
        break;
    end
    %grab mondrian for next trial
    whichMondrian = selectMondrian(size(mondrians,2), whichMondrian);
    alpha_stim = selectTexAlpha(alpha.tex, tick+2);
end
[vbl(tick+2), ~, ~, missed(tick+2)] =...
    Screen('Flip', window.pointer, vbl(tick+1) + (expParams.mondrianHertz-slack)*window.ifi );

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);
tEnd = vbl(find(isnan(vbl)==0,1,'last'));

if rt < jitter*(1/expParams.mondrianHertz) && ~strcmp(response,'space')
    exitFlag = {'CAUGHT'};
elseif strcmp(response,'space')
    exitFlag = {'SPACE'};
end

end
