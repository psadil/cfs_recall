function [] = showPromptAndWaitForResp(window, prompt, keys,constants,responseHandler, varargin)

if nargin > 5
    vbl = varargin{1};
else
    vbl = Screen('Flip', window.pointer);
end

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    DrawFormattedText(window.pointer,prompt,...
        'center', 'center');
    DrawFormattedText(window.pointer, '[Press Enter to Continue]', ...
        'center', window.winRect(4)*.8);
end
Screen('DrawingFinished',window.pointer);
Screen('Flip', window.pointer, vbl + window.ifi/2 );
waitForEnter(keys,constants,responseHandler);

end

