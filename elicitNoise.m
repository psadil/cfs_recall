function [ response, rt, tStart, tEnd, vbl, missed, exitFlag ] =...
    elicitNoise( window, responseHandler, tex, keys,...
    expParams, constants, roboRT_preJitter, maxAlpha, jitter, answer, noisetex )
%collectResponses Show arrow until participant makes response, and collect
%that response
response = {'NO RESPONSE'};
rt = NaN;
exitFlag = {'OK'};
tStart = NaN;
vbl = NaN(expParams.nTicks+1,1);
missed = NaN(expParams.nTicks+1,1);

roboRT = roboRT_preJitter + (jitter*(1/expParams.mondrianHertz));

slack = .5;
goRobo = 0;

% transparency of texture increases at constant rate, up to a given trial's
% maximum value
alpha.tex = [repelem(0, jitter), 0:(1/expParams.mondrianHertz):maxAlpha];

% Size of the patch:
% contrast = [repelem(1, jitter), 0:(1/expParams.noiseHertz):1];
alpha.noise = 1;

alpha_stim = selectTexAlpha(alpha.tex, 1);

KbQueueCreate(constants.device, keys);
drawFixation(window);
noise_contrast = selectContrast(alpha.noise, 1);
[vbl(1), ~, ~, missed(1)] = Screen('Flip', window.pointer); % Display cue and prompt
for tick = 0:(expParams.nTicks_noise-1)
    
    % for each tick, pick out one of the mondrians to draw
    drawStimulus(window, tex, noisetex, noise_contrast, alpha_stim);
    
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
            wrapper_keyProcess(keys_pressed, press_times, tStart, 'cue');
        break;
    end
    
    alpha_stim = selectTexAlpha(alpha.tex, tick+2);
    noise_contrast = selectContrast(alpha.noise, tick+2);
end
[vbl(tick+2), ~, ~, missed(tick+2)] =...
    Screen('Flip', window.pointer, vbl(tick+1) + (expParams.mondrianHertz-slack)*window.ifi );

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);
tEnd = vbl(find(isnan(vbl)==0,1,'last'));

if strcmp(response,'ESCAPE')
    exitFlag = response;
elseif strcmp(response,'Return') && (selectTexAlpha(alpha.tex, tick+2) == 0)
    exitFlag = {'CAUGHT'};
end

end

function drawStimulus(window, tex, noisetex, contrast, alpha_stim)

seed = GetSecs;
tilt = 0;

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    
    Screen('DrawTexture', window.pointer, noisetex,...
        [], [], tilt, [], [], [], [], [], [contrast, seed, 0, 0]);
    Screen('DrawTexture', window.pointer, tex,[],window.imagePlace,[],[],alpha_stim);
    
    % small white fixation square
    Screen('DrawLines', window.pointer, window.fixCrossCoords,...
        2, window.white, window.center, 2);
     
    % prompt participant to respond
    DrawFormattedText(window.pointer, 'Match (p) or Mismatch (q)?', ...
        'center', window.winRect(4)*.8);
    
end
Screen('DrawingFinished',window.pointer);

end

function noise_contrast = selectContrast(contrast, tick)

if isempty(contrast)
    noise_contrast = 1;
else
    noise_contrast = contrast(min(length(contrast), tick));
end

end