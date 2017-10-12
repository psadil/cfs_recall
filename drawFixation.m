function [  ] = drawFixation( window )

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    Screen('DrawLines', window.pointer, window.fixCrossCoords,...
        2, window.white, window.center, 2);
end
Screen('DrawingFinished',window.pointer);
end

