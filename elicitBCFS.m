function [ response, rt, tStart, tEnd, vbl, missed, exitFlag ] = elicitBCFS( window, responseHandler,...
    tex, eyes, keys, mondrians, expParams, constants, roboRT_preJitter, maxAlpha, jitter )
%collectResponses Show arrow until participant makes response, and collect
%that response
response = {'NO RESPONSE'};
rt = NaN;
exitFlag = {'OK'};
vbl = NaN(expParams.nTicks+1,1);
missed = NaN(expParams.nTicks+1,1);

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

KbQueueCreate(constants.device, keys.enter+keys.escape+keys.space);
whichMondrian = selectMondrian(size(mondrians,2));
alpha_tex = selectTexAlpha(alpha.tex, 1);
drawFixation(window);
% Screen('PreloadTextures',window.pointer,tex);
[vbl(1), ~, ~, missed(1)] = Screen('Flip', window.pointer); % Display cue and prompt
for tick = 0:(expParams.nTicks-1)
    
    % for each tick, pick out one of the mondrians to draw
    drawStimulus(window, prompt, eyes,...
        tex, mondrians(whichMondrian).tex,... %  mondrians(mod(tick,size(mondrians,2))+1).tex,
        1,... %         alpha.mondrian(min(length(alpha.mondrian), tick+1)), ...
        alpha_tex);
    
    % flip only in sync with mondrian presentation rate
    [vbl(tick+2), ~, ~, missed(tick+2)] = Screen('Flip', window.pointer, vbl(tick+1) + (expParams.mondrianHertz-slack)*window.ifi );
    if tick == 0
        tStart = vbl(2);
        KbQueueStart(constants.device);
    end
    if (vbl(tick+2) - tStart) > roboRT
        goRobo = 1;
    end
    
    [keys_pressed, press_times] = responseHandler(constants.device, '\ENTER', goRobo);
    if ~isempty(keys_pressed)
        [response, rt, exitFlag] = ...
            wrapper_keyLogic(keys_pressed, press_times, tStart);
        break;
    end
    %grab mondrian for next trial
    whichMondrian = selectMondrian(size(mondrians,2), whichMondrian);
    alpha_tex = selectTexAlpha(alpha.tex, tick+2);
end

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);
tEnd = vbl(find(isnan(vbl)==0,1,'last'));

if strcmp(response,'Return') && (selectTexAlpha(alpha.tex, tick+2) == 0)
    exitFlag = {'CAUGHT'};
end

end

function drawStimulus(window, prompt, eyes, imageTex, mondrianTex, alpha_mondrian, alpha_tex)

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    
%     % draw Mondrians
%     Screen('DrawTexture', window.pointer, mondrianTex,[],[],[],[],alpha_mondrian);
    
    if eyes(eye)
        Screen('DrawTexture', window.pointer, imageTex,[],window.imagePlace,[],[],alpha_tex);
    else
        % draw Mondrians
        Screen('DrawTexture', window.pointer, mondrianTex,[],[],[],[],alpha_mondrian);
    end
    
    % small white fixation square
    Screen('DrawLines', window.pointer, window.fixCrossCoords,...
        2, window.white, window.center, 2);
    
    % prompt participant to respond
    DrawFormattedText(window.pointer, prompt, 'center');
end
Screen('DrawingFinished',window.pointer);

end

function whichMondrian = selectMondrian(nMondrians, varargin)

whichMondrian = randsample(1:nMondrians,1);
if nargin == 2
    while varargin{1} == whichMondrian
        whichMondrian = randsample(1:nMondrians,1);
    end
end
end

function alpha_tex = selectTexAlpha(alphas, tick)

if isempty(alphas)
   alpha_tex = 0;
else 
   alpha_tex = alphas(min(length(alphas), tick)); 
end

end