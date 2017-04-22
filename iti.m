function iti(window, dur, varargin)

if nargin > 2
    vbl = varargin{1};
else
    vbl = Screen('Flip', window.pointer);
end

drawFixation(window);
vbl = Screen('Flip', window.pointer, vbl + window.ifi/2 );
WaitSecs(dur);
drawFixation(window);
Screen('Flip', window.pointer, vbl + window.ifi/2);

end
