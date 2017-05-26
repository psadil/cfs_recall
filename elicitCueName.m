function [ response, rt, tStart, tEnd, exitFlag ] =...
    elicitCueName( window, responseHandler, tex, keys, constants, answer )
%collectResponses Show arrow until participant makes response, and collect
%that response
response = {''};
rt = NaN;
exitFlag = {'OK'};

slack = .5;
% advance = 0;
KbQueueCreate(constants.device, keys);
drawFixation(window);
vbl= Screen('Flip', window.pointer);
firstFlip = 1;
while 1
    
    drawStimulus(window, response{1}, tex);
    
    vbl = Screen('Flip', window.pointer, vbl + (slack * window.ifi));
    if firstFlip
        tStart = vbl;
        KbQueueStart(constants.device);
        firstFlip = 0;
    end
%     KbQueueWait;
    [keys_pressed, press_times] = responseHandler(constants.device, answer);
    if ~isempty(keys_pressed)
        [keyName, rt, exitFlag] = ...
            wrapper_keyProcess(keys_pressed, press_times, tStart, 'name');
        
        switch keyName{1}
            case 'BackSpace'
                if ~isempty(response{1})
                    response = {response{1}(1:end-1)};
                end
            case 'space'
                response = {[response{1}, ' ']};
            case {'Return', 'ESCAPE'}
                break;
            otherwise
                response = {[response{1}, keyName{1}]};
        end
        % extra switch necessary for robot trials, where the last response
        % might not be just Return
        switch exitFlag{1}
            case {'Return', 'ESCAPE'}
                break;
        end
        
    end
end
tEnd = Screen('Flip', window.pointer, vbl + (0.5 * window.ifi));

if isempty(response{:})
    response = {'NO RESPONSE'};
end

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);

end

function drawStimulus(window, response, tex)

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    
    Screen('DrawTexture', window.pointer, tex, [], window.imagePlace);
    
    % prompt participant to respond
    DrawFormattedText(window.pointer, 'What is this a part of?', ...
        window.xCenter-300, window.winRect(4)*.8);
    DrawFormattedText(window.pointer, response, window.xCenter+100, window.winRect(4)*.8);
    DrawFormattedText(window.pointer, '[Press Enter to Continue]', ...
        'center', window.winRect(4)*.9);
    
end
Screen('DrawingFinished',window.pointer);

end
