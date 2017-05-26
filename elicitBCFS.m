function [ response, rt, tStart, tEnd, vbl, missed, exitFlag ] =...
    elicitBCFS( window, responseHandler, tex, eyes,...
    keys, mask, expParams, constants,...
    roboRT, maxAlpha, jitter, answer, expt, maskEye, nTicks, prompt )
%collectResponses Show arrow until participant makes response, and collect
%that response
response = {'NO RESPONSE'};
rt = NaN;
exitFlag = {'OK'};
tStart = NaN;
vbl = NaN(nTicks+1,1);
missed = NaN(nTicks+1,1);

switch expt
    case 'occularDominance'
        where_stim=[];
        where_mask = [];
        alpha.tex = [repelem(0, jitter), 0:(1/expParams.mondrianHertz):maxAlpha];
    case 'noise'
        where_stim = window.imagePlace;
        where_mask = window.noiseTexesRect;
        alpha.tex = [repelem(0, jitter), 0:(1/expParams.mondrianHertz)/expParams.noiseFadeInDur:maxAlpha];
    otherwise
        where_mask = [];
        where_stim = window.imagePlace;
        alpha.tex = [repelem(0, jitter), 0:(1/expParams.mondrianHertz):maxAlpha];
end

% transparency of texture increases at constant rate, up to a given trial's
% maximum value
alpha.tex = [repelem(0, jitter), 0:(1/expParams.mondrianHertz)/expParams.noiseFadeInDur:maxAlpha];
% transparency of mondrians is typically locked at 1
alpha.mondrian = [repelem(1,jitter), expParams.alpha.mondrian];
% both transparencies needed to have additional jitter added to beginning

slack = .5;
goRobo = 0;

KbQueueCreate(constants.device, keys);
whichMask = selectMask(size(mask,2));
alpha_stim = selectTexAlpha(alpha.tex, 1);

drawFixation(window);
% Screen('PreloadTextures',window.pointer,tex);
[vbl(1), ~, ~, missed(1)] = Screen('Flip', window.pointer); % Display cue and prompt
for tick = 0:(nTicks-1)
    
    % for each tick, pick out one of the mondrians to draw
    drawMaskedStimulus(window, prompt, eyes,...
        tex, mask(whichMask).tex,... %  mondrians(mod(tick,size(mondrians,2))+1).tex,
        1,... %         alpha.mondrian(min(length(alpha.mondrian), tick+1)), ...
        alpha_stim, where_stim, where_mask, maskEye);
    
    % flip only in sync with mondrian presentation rate
    [vbl(tick+2), ~, ~, missed(tick+2)] =...
        Screen('Flip', window.pointer, vbl(tick+1) + (expParams.mondrianHertz-slack)*window.ifi );
    if tick == jitter
        KbQueueStart(constants.device);
        tStart = vbl(tick+2);
    end
    if (vbl(tick+2) - tStart) > roboRT
        goRobo = 1;
    end
    
    [keys_pressed, press_times] = responseHandler(constants.device, answer, goRobo);
    if ~isempty(keys_pressed)
        [response, rt, exitFlag] = ...
            wrapper_keyProcess(keys_pressed, press_times, tStart, expt);
        break;
    end
    %grab mask for next trial
    whichMask = selectMask(size(mask,2), whichMask);
    alpha_stim = selectTexAlpha(alpha.tex, tick+2);
end
[vbl(tick+2), ~, ~, missed(tick+2)] =...
    Screen('Flip', window.pointer, vbl(tick+1) + (expParams.mondrianHertz-slack)*window.ifi );

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);
tEnd = vbl(find(isnan(vbl)==0,1,'last'));

% if strcmp(response,'ESCAPE')
%     exitFlag = {'ESCAPE'};
% % elseif rt < jitter*(1/expParams.mondrianHertz) && ~strcmp(response,'NO RESPONSE')
% %     exitFlag = {'CAUGHT'};
% end

end

function whichMask = selectMask(nMasks, varargin)

whichMask = randsample(1:nMasks,1);
if nargin == 2
    while varargin{1} == whichMask
        whichMask = randsample(1:nMasks,1);
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